"""
Gunicorn configuration for Centria.
Ensures the backend directory is in sys.path and sets working directory appropriately.
"""
import os
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent
backend_dir = str(ROOT_DIR / 'backend')

if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

# Set working directory to backend
chdir = backend_dir

# Default bind settings for Render (Render defaults to port 10000)
port = os.environ.get('PORT', '10000')
bind = f"0.0.0.0:{port}"
workers = int(os.environ.get('WEB_CONCURRENCY', '1'))
timeout = 120
