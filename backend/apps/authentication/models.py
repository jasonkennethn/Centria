import random
from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils import timezone
from datetime import timedelta

class UserManager(BaseUserManager):
    """Define a model manager for User model with no username field."""

    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        """Create and save a User with the given email and password."""
        if not email:
            raise ValueError('The given email must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        """Create and save a regular User with the given email and password."""
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password, **extra_fields):
        """Create and save a SuperUser with the given email and password."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    """Custom User model with email authentication and RBAC."""

    ROLE_CHOICES = (
        ('SUPER_ADMIN', 'Super Admin / Owner'),
        ('ADMIN', 'Executive Admin'),
        ('MANAGER', 'Department Manager'),
        ('EMPLOYEE', 'Staff Employee'),
        ('CONTRACTOR', 'Contractor / Specialist'),
        ('CLIENT', 'External Client / Auditor'),
    )

    username = None
    email = models.EmailField('email address', unique=True)
    full_name = models.CharField(max_length=255, blank=True)
    phone_number = models.CharField(max_length=30, blank=True)
    avatar_url = models.URLField(max_length=1000, blank=True)
    role = models.CharField(max_length=30, choices=ROLE_CHOICES, default='SUPER_ADMIN')

    is_email_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    objects = UserManager()

    def __str__(self):
        return f"{self.email} ({self.role})"


class OTPVerification(models.Model):
    """OTP Verification codes sent via Brevo email."""

    PURPOSE_CHOICES = (
        ('LOGIN', 'Login Verification'),
        ('REGISTER', 'Registration Verification'),
        ('PASSWORD_RESET', 'Password Reset'),
    )

    email = models.EmailField()
    otp_code = models.CharField(max_length=6)
    purpose = models.CharField(max_length=20, choices=PURPOSE_CHOICES, default='LOGIN')
    is_used = models.BooleanField(default=False)
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def is_valid(self):
        return not self.is_used and timezone.now() <= self.expires_at

    @classmethod
    def generate_otp(cls, email: str, purpose: str = 'LOGIN'):
        # Invalidate existing active OTPs
        cls.objects.filter(email=email, is_used=False).update(is_used=True)
        code = f"{random.randint(100000, 999999)}"
        expires = timezone.now() + timedelta(minutes=10)
        return cls.objects.create(
            email=email,
            otp_code=code,
            purpose=purpose,
            expires_at=expires
        )
