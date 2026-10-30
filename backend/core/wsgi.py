"""
WSGI config alias for core.wsgi.
Enables backward compatibility with deployments invoking `core.wsgi:application`.
Delegates to centria_backend.wsgi.
"""
import os
import sys
from pathlib import Path

# Ensure backend directory is in sys.path
BASE_DIR = Path(__file__).resolve().parent.parent
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria_backend.settings.prod')

from centria_backend.wsgi import application
