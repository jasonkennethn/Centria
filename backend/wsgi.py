"""
Top-level WSGI config forwarder for backend.
Enables deployments invoking `gunicorn wsgi:application`.
"""
from centria_backend.wsgi import application
