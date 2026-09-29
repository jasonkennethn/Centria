from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Product, Project, Task, Milestone
from .serializers import (
    ProductSerializer, ProjectSerializer, TaskSerializer, MilestoneSerializer
)
from apps.ai_engine.services.gemini_service import predict_project_delay_risk

class ProductViewSet(viewsets.ModelViewSet):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Product.objects.filter(company__id=company_id)
        return Product.objects.filter(company__owner=self.request.user)


class ProjectViewSet(viewsets.ModelViewSet):
    serializer_class = ProjectSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        if company_id:
            return Project.objects.filter(company__id=company_id)
        return Project.objects.filter(company__owner=self.request.user)

    @action(detail=True, methods=['post'])
    def predict_risk(self, request, pk=None):
        project = self.get_object()
        tasks = project.tasks.all()
        tasks_data = [
            {'title': t.title, 'priority': t.priority, 'status': t.status, 'hours': float(t.estimated_hours)}
            for t in tasks
        ]

        prediction = predict_project_delay_risk(project.name, tasks_data)
        project.delay_risk_level = prediction.get('risk_level', 'LOW').upper()
        project.delay_risk_score = prediction.get('risk_score_percentage', 15)
        project.ai_risk_narrative = f"{prediction.get('primary_bottleneck', '')} Recommendation: {prediction.get('recommended_action', '')}"
        project.save()

        return Response({
            'prediction': prediction,
            'project': ProjectSerializer(project).data
        })


class TaskViewSet(viewsets.ModelViewSet):
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        company_id = self.request.query_params.get('company_id')
        project_id = self.request.query_params.get('project_id')
        status_param = self.request.query_params.get('status')

        qs = Task.objects.filter(company__owner=self.request.user)
        if company_id:
            qs = qs.filter(company__id=company_id)
        if project_id:
            qs = qs.filter(project__id=project_id)
        if status_param:
            qs = qs.filter(status=status_param.upper())
        return qs

    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        task = self.get_object()
        new_status = request.data.get('status')
        if new_status:
            task.status = new_status
            task.save()
            return Response(TaskSerializer(task).data)
        return Response({'detail': 'status field required.'}, status=status.HTTP_400_BAD_REQUEST)


class MilestoneViewSet(viewsets.ModelViewSet):
    serializer_class = MilestoneSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        project_id = self.request.query_params.get('project_id')
        if project_id:
            return Milestone.objects.filter(project__id=project_id)
        return Milestone.objects.filter(project__company__owner=self.request.user)
