from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Employee, Attendance, LeaveRequest, OnboardingTask
from .serializers import (
    EmployeeSerializer, AttendanceSerializer,
    LeaveRequestSerializer, OnboardingTaskSerializer
)
from apps.authentication.services.brevo_service import send_brevo_email

class EmployeeViewSet(viewsets.ModelViewSet):
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Employee.objects.filter(company__id=company_id)
        return Employee.objects.filter(company__owner=self.request.user)

    @action(detail=True, methods=['post'])
    def generate_onboarding_tasks(self, request, pk=None):
        employee = self.get_object()
        default_tasks = [
            ("Sign NDA & Employee Contract", "Review and sign corporate confidentiality agreements"),
            ("Setup Work Email & Centria Credentials", "Provision access to systems"),
            ("Meet Department Lead", "Introductory sync and quarterly objectives"),
            ("Review Company Handbook & Security Policies", "Read and acknowledge IT security rules")
        ]
        created = []
        for title, desc in default_tasks:
            task = OnboardingTask.objects.create(
                company=employee.company,
                employee=employee,
                title=title,
                description=desc
            )
            created.append(OnboardingTaskSerializer(task).data)

        return Response({
            'message': f'Onboarding tasks generated for {employee.full_name}.',
            'tasks': created
        })


class AttendanceViewSet(viewsets.ModelViewSet):
    serializer_class = AttendanceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Attendance.objects.filter(company__id=company_id)
        return Attendance.objects.filter(company__owner=self.request.user)


class LeaveRequestViewSet(viewsets.ModelViewSet):
    serializer_class = LeaveRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return LeaveRequest.objects.filter(company__id=company_id)
        return LeaveRequest.objects.filter(company__owner=self.request.user)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        leave = self.get_object()
        leave.status = 'APPROVED'
        leave.approved_by = request.user
        leave.approver_comments = request.data.get('comments', 'Approved by manager.')
        leave.save()

        # Send confirmation email via Brevo
        send_brevo_email(
            to_email=leave.employee.email,
            to_name=leave.employee.full_name,
            subject=f"Leave Request Approved: {leave.start_date} to {leave.end_date}",
            html_content=f"<p>Hello {leave.employee.full_name},</p><p>Your leave request from <b>{leave.start_date}</b> to <b>{leave.end_date}</b> has been approved.</p>"
        )

        return Response({'message': 'Leave request approved.', 'leave': LeaveRequestSerializer(leave).data})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        leave = self.get_object()
        leave.status = 'REJECTED'
        leave.approved_by = request.user
        leave.approver_comments = request.data.get('comments', 'Rejected.')
        leave.save()
        return Response({'message': 'Leave request rejected.', 'leave': LeaveRequestSerializer(leave).data})


class OnboardingTaskViewSet(viewsets.ModelViewSet):
    serializer_class = OnboardingTaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        employee_id = self.request.query_params.get('employee_id')
        if employee_id:
            return OnboardingTask.objects.filter(employee__id=employee_id)
        return OnboardingTask.objects.filter(company__owner=self.request.user)
