"""
Gunicorn configuration for Centria (backend directory).
Ensures Gunicorn binds to Render's dynamic $PORT on 0.0.0.0.
"""
import os
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

# Default bind settings for Render (Render defaults to port 10000)
port = os.environ.get('PORT', '10000')
bind = f"0.0.0.0:{port}"
workers = int(os.environ.get('WEB_CONCURRENCY', '2'))
threads = int(os.environ.get('GUNICORN_THREADS', '4'))
worker_class = 'gthread'
keepalive = 65
timeout = 120
