from django.urls import path
from . import views

urlpatterns = [
    path('check-email/', views.check_email, name='check_email'),
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('health/', views.health, name='health'),
]
