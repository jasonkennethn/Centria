"""
Centria Backend — Base Settings
Shared configuration for all environments.
"""
import os
from pathlib import Path
from datetime import timedelta
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent.parent
load_dotenv(BASE_DIR / '.env')

import secrets

SECRET_KEY = os.environ.get('SECRET_KEY', '')
if not SECRET_KEY:
    # Dynamically generate secure ephemeral key if not supplied in environment
    SECRET_KEY = secrets.token_urlsafe(50)

DEBUG = False
ALLOWED_HOSTS = []

# Application definition
INSTALLED_APPS = [
    'daphne',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third-party
    'channels',
    'rest_framework',
    'corsheaders',
    'django_q',
    # Centria apps
    'core',
    'projects',
    'documents',
    'ai_engine',
    'integrations',
    'approvals',
    'audit',
    'media_pipeline',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'core.middleware.CompanyIsolationMiddleware',
]

ROOT_URLCONF = 'centria_backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'centria_backend.wsgi.application'
ASGI_APPLICATION = 'centria_backend.asgi.application'

# Database — NeonDB
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'OPTIONS': {},
    }
}

# Parse DATABASE_URL
import urllib.parse
db_url = os.environ.get('DATABASE_URL', '')
if db_url:
    parsed = urllib.parse.urlparse(db_url)
    DATABASES['default'].update({
        'NAME': parsed.path.lstrip('/'),
        'USER': parsed.username,
        'PASSWORD': parsed.password,
        'HOST': parsed.hostname,
        'PORT': parsed.port or 5432,
    })
    qs = urllib.parse.parse_qs(parsed.query)
    if 'sslmode' in qs:
        DATABASES['default'].setdefault('OPTIONS', {})
        DATABASES['default']['OPTIONS']['sslmode'] = qs['sslmode'][0]

# Persistent database connections & health checks (eliminates 300-800ms handshake overhead per request)
DATABASES['default']['CONN_MAX_AGE'] = int(os.environ.get('DB_CONN_MAX_AGE', 600))
DATABASES['default']['CONN_HEALTH_CHECKS'] = True

# High-performance in-memory cache
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'centria-fast-cache',
        'TIMEOUT': 120,
    }
}

AUTH_USER_MODEL = 'core.User'

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STORAGES = {
    'staticfiles': {
        'BACKEND': 'whitenoise.storage.CompressedManifestStaticFilesStorage',
    },
}

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS
FRONTEND_URL = os.environ.get('FRONTEND_URL', 'http://localhost:8080')
BACKEND_URL = os.environ.get('BACKEND_URL', 'http://localhost:8000')

CORS_ALLOWED_ORIGINS = [
    FRONTEND_URL,
    'http://localhost:8080',
    'http://localhost:3000',
    'http://localhost:9845',
    'http://127.0.0.1:9845',
    'http://localhost:5000',
    'http://127.0.0.1:5000',
]
CORS_ALLOW_CREDENTIALS = True

# DRF
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 25,
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '30/minute',
        'user': '120/minute',
        'auth': '10/minute',
        'password_reset': '5/minute',
    },
}

# JWT
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# Neon Object Cloud (S3-compatible)
AWS_ENDPOINT_URL_S3 = os.environ.get('AWS_ENDPOINT_URL_S3', '')
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID', '')
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY', '')
AWS_REGION = os.environ.get('AWS_REGION', 'ap-southeast-1')
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME', 'centria-media')

# Brevo email
BREVO_API_KEY = os.environ.get('BREVO_API_KEY', '')
EMAIL_SENDER_NAME = 'Centria'
EMAIL_SENDER_ADDRESS = 'no-reply@celarox.com'

# Gemini AI
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'models/gemini-2.5-flash')
GEMINI_EMBEDDING_MODEL = os.environ.get('GEMINI_EMBEDDING_MODEL', 'models/gemini-embedding-001')

# Django-Q2 (uses DB as broker)
Q_CLUSTER = {
    'name': 'centria',
    'workers': 2,
    'recycle': 500,
    'timeout': 300,
    'retry': 360,
    'compress': True,
    'save_limit': 250,
    'queue_limit': 500,
    'cpu_affinity': 1,
    'orm': 'default',
}

# OTP settings
OTP_EXPIRY_MINUTES = 10
OTP_LENGTH = 6

# Realtime / WebSockets (Django Channels)
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}

# Neon Realtime DB configuration
NEON_REALTIME_URL = os.environ.get('NEON_REALTIME_URL', '')
NEON_REALTIME_TOKEN = os.environ.get('NEON_REALTIME_TOKEN', '')

# Platform Administrator Accounts (loaded securely from environment)
PLATFORM_ADMIN_EMAILS = [
    e.strip().lower() for e in os.environ.get('PLATFORM_ADMIN_EMAILS', '').split(',') if e.strip()
]
