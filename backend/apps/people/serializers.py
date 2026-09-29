from rest_framework import serializers
from .models import Employee, Attendance, LeaveRequest, OnboardingTask

class EmployeeSerializer(serializers.ModelSerializer):
    department_name = serializers.ReadOnlyField(source='department.name')
    company_role_name = serializers.ReadOnlyField(source='company_role.name')
    full_name = serializers.ReadOnlyField()

    class Meta:
        model = Employee
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class AttendanceSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='employee.full_name')

    class Meta:
        model = Attendance
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class LeaveRequestSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='employee.full_name')
    employee_email = serializers.ReadOnlyField(source='employee.email')

    class Meta:
        model = LeaveRequest
        fields = '__all__'
        read_only_fields = ('id', 'created_at')


class OnboardingTaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = OnboardingTask
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
