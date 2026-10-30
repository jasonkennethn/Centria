"""Production settings for Centria."""
import os
from .base import *  # noqa: F401,F403

DEBUG = False

raw_hosts = os.environ.get('ALLOWED_HOSTS', 'localhost,127.0.0.1,centria-enterprise.onrender.com')
ALLOWED_HOSTS = [h.strip() for h in raw_hosts.split(',') if h.strip()]

if not SECRET_KEY or SECRET_KEY == 'change-me-in-production' or 'insecure' in SECRET_KEY.lower():
    raise ValueError("A secure SECRET_KEY must be configured in production environment (cannot be empty, default, or insecure).")

# Security settings for production
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = os.environ.get('SECURE_SSL_REDIRECT', 'True').lower() in ('true', '1')
SECURE_HSTS_SECONDS = int(os.environ.get('SECURE_HSTS_SECONDS', '31536000'))  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
