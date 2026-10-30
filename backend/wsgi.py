"""
Top-level WSGI config forwarder for backend.
Enables deployments invoking `gunicorn wsgi:application`.
"""
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from centria_backend.wsgi import application
