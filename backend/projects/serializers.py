from rest_framework import serializers
from core.serializers import UserSerializer
from projects.models import Project, Task, TaskComment, Customer


class ProjectSerializer(serializers.ModelSerializer):
    lead_details = UserSerializer(source='lead', read_only=True)
    task_count = serializers.IntegerField(read_only=True, default=0)
    open_task_count = serializers.IntegerField(read_only=True, default=0)

    class Meta:
        model = Project
        fields = [
            'id', 'company', 'name', 'key', 'description', 'status',
            'lead', 'lead_details', 'start_date', 'target_date',
            'is_archived', 'task_count', 'open_task_count', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'company', 'created_at', 'updated_at']


class TaskCommentSerializer(serializers.ModelSerializer):
    author_details = UserSerializer(source='author', read_only=True)

    class Meta:
        model = TaskComment
        fields = ['id', 'task', 'author', 'author_details', 'content', 'created_at']
        read_only_fields = ['id', 'author', 'created_at']


class TaskSerializer(serializers.ModelSerializer):
    assignee_details = UserSerializer(source='assignee', read_only=True)
    creator_details = UserSerializer(source='creator', read_only=True)
    project_key = serializers.CharField(source='project.key', read_only=True)
    key = serializers.CharField(read_only=True)
    comments = TaskCommentSerializer(many=True, read_only=True)

    class Meta:
        model = Task
        fields = [
            'id', 'company', 'project', 'project_key', 'task_number', 'key',
            'title', 'description', 'task_type', 'status', 'priority',
            'assignee', 'assignee_details', 'creator', 'creator_details',
            'due_date', 'custom_fields', 'comments', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'company', 'task_number', 'key', 'created_at', 'updated_at']


class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = [
            'id', 'company', 'name', 'email', 'phone', 'company_name',
            'status', 'notes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'company', 'created_at', 'updated_at']
