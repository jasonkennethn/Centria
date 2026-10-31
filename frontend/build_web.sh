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

# Generate static route directory fallbacks and 404.html so direct URL refresh works on any host
for route in dashboard projects tasks knowledge approvals admin splash; do
    mkdir -p "build/web/$route"
    cp -f build/web/index.html "build/web/$route/index.html" 2>/dev/null || true
done
cp -f build/web/index.html build/web/404.html 2>/dev/null || true

# Verify full MaterialIcons font is preserved
if [ -f "build/web/assets/fonts/MaterialIcons-Regular.otf" ]; then
    font_size=$(wc -c < "build/web/assets/fonts/MaterialIcons-Regular.otf")
    if [ "$font_size" -lt 500000 ]; then
        echo "Restoring full MaterialIcons font from Flutter artifacts..."
        sdk_font=$(find "$PWD/flutter" "$HOME/flutter" -name "MaterialIcons-Regular.otf" -size +1M 2>/dev/null | head -n 1 || true)
        if [ -n "$sdk_font" ]; then
            cp -f "$sdk_font" "build/web/assets/fonts/MaterialIcons-Regular.otf"
        fi
    fi
    mkdir -p build/web/fonts
    cp -f "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/fonts/MaterialIcons-Regular.otf" 2>/dev/null || true
fi

echo "✓ Production WebAssembly (Wasm + Skwasm) build complete: build/web/"
