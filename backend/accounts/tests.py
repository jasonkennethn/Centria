from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from .models import User


class AccountsAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='testuser@example.com',
            password='TestPassword123!',
            first_name='Test',
            last_name='User',
        )

    def test_health_check(self):
        response = self.client.get('/api/auth/health/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get('status'), 'ok')

    def test_check_email_exists(self):
        response = self.client.post('/api/auth/check-email/', {'email': 'testuser@example.com'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('exists'))

    def test_check_email_not_exists(self):
        response = self.client.post('/api/auth/check-email/', {'email': 'newuser@example.com'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data.get('exists'))

    def test_login_successful(self):
        response = self.client.post(
            '/api/auth/login/',
            {'email': 'testuser@example.com', 'password': 'TestPassword123!'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['email'], 'testuser@example.com')

    def test_login_invalid_password(self):
        response = self.client.post(
            '/api/auth/login/',
            {'email': 'testuser@example.com', 'password': 'WrongPassword'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_register_new_user(self):
        response = self.client.post(
            '/api/auth/register/',
            {
                'email': 'brandnew@example.com',
                'password': 'SecurePass123!',
                'first_name': 'Jane',
                'last_name': 'Doe',
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['user']['email'], 'brandnew@example.com')
        self.assertTrue(User.objects.filter(email='brandnew@example.com').exists())
