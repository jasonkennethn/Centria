"""
ASGI config alias for core.asgi.
Enables backward compatibility with deployments invoking `core.asgi:application`.
Delegates to centria_backend.asgi.
"""
import os
import sys
from pathlib import Path

# Ensure backend directory is in sys.path
BASE_DIR = Path(__file__).resolve().parent.parent
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'centria_backend.settings.prod')

from centria_backend.asgi import application
