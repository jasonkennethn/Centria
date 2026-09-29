from rest_framework import status, views, permissions
from rest_framework.response import Response
from django.contrib.auth import authenticate, get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from .models import OTPVerification
from .serializers import (
    UserSerializer, RegisterSerializer, LoginSerializer,
    RequestOTPSerializer, VerifyOTPSerializer
)
from .services.brevo_service import send_otp_email

User = get_user_model()

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Send welcome & verification OTP via Brevo
            otp = OTPVerification.generate_otp(user.email, purpose='REGISTER')
            send_otp_email(user.email, otp.otp_code, user.full_name)

            tokens = get_tokens_for_user(user)
            return Response({
                'message': 'User registered successfully. Verification OTP sent.',
                'user': UserSerializer(user).data,
                'tokens': tokens
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        user = authenticate(request, email=email, password=password)
        if not user:
            return Response({'detail': 'Invalid email or password.'}, status=status.HTTP_401_UNAUTHORIZED)

        tokens = get_tokens_for_user(user)
        return Response({
            'message': 'Login successful.',
            'user': UserSerializer(user).data,
            'tokens': tokens
        }, status=status.HTTP_200_OK)


class RequestOTPView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RequestOTPSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        purpose = serializer.validated_data['purpose']

        user = User.objects.filter(email=email).first()
        name = user.full_name if user else "Centria User"

        otp = OTPVerification.generate_otp(email, purpose=purpose)
        email_sent = send_otp_email(email, otp.otp_code, name)

        return Response({
            'message': f'OTP verification code sent to {email}.',
            'email_sent': email_sent,
            'otp_preview_for_dev': otp.otp_code if True else None
        }, status=status.HTTP_200_OK)


class VerifyOTPView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        otp_code = serializer.validated_data['otp_code']
        purpose = serializer.validated_data['purpose']

        otp = OTPVerification.objects.filter(
            email=email,
            otp_code=otp_code,
            purpose=purpose,
            is_used=False
        ).first()

        if not otp or not otp.is_valid():
            return Response({'detail': 'Invalid or expired OTP code.'}, status=status.HTTP_400_BAD_REQUEST)

        otp.is_used = True
        otp.save()

        # If user exists, mark verified and return auth tokens
        user = User.objects.filter(email=email).first()
        if user:
            user.is_email_verified = True
            user.save()
            tokens = get_tokens_for_user(user)
            return Response({
                'message': 'OTP verification successful.',
                'user': UserSerializer(user).data,
                'tokens': tokens
            }, status=status.HTTP_200_OK)

        return Response({'message': 'OTP verified successfully.'}, status=status.HTTP_200_OK)


class UserProfileView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
