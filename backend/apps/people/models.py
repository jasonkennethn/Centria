import uuid
from django.db import models
from django.conf import settings
from apps.companies.models import Company, Department, CompanyRole

class Employee(models.Model):
    """Employee record within a company (HRMS)."""

    EMPLOYMENT_TYPES = (
        ('FULL_TIME', 'Full-time Employee'),
        ('PART_TIME', 'Part-time Employee'),
        ('CONTRACTOR', 'Contractor / Specialist'),
        ('INTERN', 'Intern'),
    )

    STATUS_CHOICES = (
        ('ACTIVE', 'Active'),
        ('ON_LEAVE', 'On Leave'),
        ('PROBATION', 'Probation'),
        ('TERMINATED', 'Terminated'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='employees')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='employee_profiles')
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True, related_name='employees')
    company_role = models.ForeignKey(CompanyRole, on_delete=models.SET_NULL, null=True, blank=True, related_name='employees')

    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField()
    phone = models.CharField(max_length=30, blank=True)
    job_title = models.CharField(max_length=150)
    employee_code = models.CharField(max_length=50, blank=True)
    employment_type = models.CharField(max_length=30, choices=EMPLOYMENT_TYPES, default='FULL_TIME')
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default='ACTIVE')
    salary_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    joining_date = models.DateField(null=True, blank=True)
    emergency_contact = models.TextField(blank=True)
    skills = models.JSONField(default=list, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['first_name', 'last_name']

    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"

    def __str__(self):
        return f"{self.full_name} ({self.job_title}) - {self.company.name}"


class Attendance(models.Model):
    """Daily attendance and clock-in records."""

    STATUS_CHOICES = (
        ('PRESENT', 'Present'),
        ('REMOTE', 'Remote / Work From Home'),
        ('HALF_DAY', 'Half Day'),
        ('ABSENT', 'Absent'),
        ('ON_LEAVE', 'On Leave'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='attendance_records')
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='attendance_records')
    date = models.DateField()
    check_in = models.TimeField(null=True, blank=True)
    check_out = models.TimeField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PRESENT')
    work_notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('employee', 'date')
        ordering = ['-date']


class LeaveRequest(models.Model):
    """Employee leave applications and multi-tier approval."""

    LEAVE_TYPES = (
        ('CASUAL', 'Casual Leave'),
        ('SICK', 'Sick Leave'),
        ('PAID', 'Paid Annual Leave'),
        ('UNPAID', 'Unpaid Leave'),
        ('PARENTAL', 'Parental Leave'),
    )

    STATUS_CHOICES = (
        ('PENDING', 'Pending Approval'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
        ('CANCELLED', 'Cancelled'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='leave_requests')
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='leave_requests')
    leave_type = models.CharField(max_length=30, choices=LEAVE_TYPES, default='PAID')
    start_date = models.DateField()
    end_date = models.DateField()
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')

    approved_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    approver_comments = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']


class OnboardingTask(models.Model):
    """Onboarding checklist items for new hires."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='onboarding_tasks')
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='onboarding_tasks')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    is_completed = models.BooleanField(default=False)
    due_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
