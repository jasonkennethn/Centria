#!/usr/bin/env bash
set -e

# Centria Web Production Build Script
echo "=========================================="
echo " Building Centria Web for Production"
echo "=========================================="

# Ensure Flutter is available
if ! command -v flutter &> /dev/null; then
    if [ ! -d "flutter" ]; then
        echo "Flutter SDK not found in PATH or local directory. Cloning stable channel..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
    fi
    export PATH="$PWD/flutter/bin:$PATH"
fi

echo "Using Flutter: $(which flutter)"
flutter --version
flutter build web --release

echo "✓ Production web build complete: build/web/"
