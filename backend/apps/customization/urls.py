from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CustomFieldViewSet

router = DefaultRouter()
router.register(r'fields', CustomFieldViewSet, basename='custom_field')

urlpatterns = [
    path('', include(router.urls)),
]
