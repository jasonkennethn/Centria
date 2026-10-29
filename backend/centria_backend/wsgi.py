"""WSGI config for Centria project."""
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria_backend.settings.dev')
application = get_wsgi_application()
