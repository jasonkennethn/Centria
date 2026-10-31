#!/usr/bin/env bash
set -e

# Centria Web Production Build Script
echo "=========================================="
echo " Building Centria Web for Production"
echo "=========================================="

# Include local flutter if present
if [ -d "$HOME/flutter/bin" ]; then
    export PATH="$HOME/flutter/bin:$PATH"
fi

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
flutter build web --wasm --no-tree-shake-icons

# Ensure mobile release assets are present in web output root & assets
if [ -d "assets" ]; then
    mkdir -p build/web/assets
    cp -u assets/centria_v* build/web/ 2>/dev/null || true
    cp -u assets/centria_v* build/web/assets/ 2>/dev/null || true
fi

echo "✓ Production WebAssembly (Wasm + Skwasm) build complete: build/web/"
