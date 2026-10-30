"""
Site customization for Centria repository.
Automatically adds the backend directory to sys.path so any script or server
invoked from the root directory can resolve backend apps (core, centria_backend, etc.).
"""
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent
backend_dir = str(ROOT_DIR / 'backend')

if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)
