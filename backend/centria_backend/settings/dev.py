"""Development settings."""
from .base import *  # noqa: F401,F403

DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '0.0.0.0', 'testserver', '*']

CORS_ALLOWED_ORIGINS = [
    'http://localhost:8080',
    'http://localhost:3000',
    'http://localhost:5000',
    'http://127.0.0.1:8080',
]
CORS_ALLOW_ALL_ORIGINS = True  # Dev only
