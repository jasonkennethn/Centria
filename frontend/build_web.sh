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

# Build with production CanvasKit & retain full MaterialIcons font table
flutter build web --no-tree-shake-icons

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

# Mirror FontManifest and AssetManifest to web root to ensure zero 404s
cp -f build/web/assets/FontManifest.json build/web/FontManifest.json 2>/dev/null || true
cp -f build/web/assets/AssetManifest* build/web/ 2>/dev/null || true

# Generate AssetManifest.json fallback for any legacy asset loaders
python3 -c "
import json
manifest = {
    'assets/fonts/MaterialIcons-Regular.otf': ['assets/fonts/MaterialIcons-Regular.otf'],
    'fonts/MaterialIcons-Regular.otf': ['fonts/MaterialIcons-Regular.otf'],
    'packages/cupertino_icons/assets/CupertinoIcons.ttf': ['packages/cupertino_icons/assets/CupertinoIcons.ttf'],
    'assets/images/logo.png': ['assets/images/logo.png']
}
with open('build/web/assets/AssetManifest.json', 'w') as f:
    json.dump(manifest, f)
with open('build/web/AssetManifest.json', 'w') as f:
    json.dump(manifest, f)
" 2>/dev/null || true

# Verify full MaterialIcons font is preserved in all path variants
if [ -f "build/web/assets/fonts/MaterialIcons-Regular.otf" ]; then
    mkdir -p build/web/fonts build/web/assets/assets/fonts
    cp -f "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/fonts/MaterialIcons-Regular.otf" 2>/dev/null || true
    cp -f "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/assets/assets/fonts/MaterialIcons-Regular.otf" 2>/dev/null || true
    cp -f "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/assets/fonts/MaterialIcons-Regular.ttf" 2>/dev/null || true
    cp -f "build/web/assets/fonts/MaterialIcons-Regular.otf" "build/web/fonts/MaterialIcons-Regular.ttf" 2>/dev/null || true
fi

# Neutralize Flutter service worker to eliminate browser cache locks completely
if [ -f "build/web/flutter_bootstrap.js" ]; then
    python3 -c "
import re
with open('build/web/flutter_bootstrap.js', 'r') as f:
    c = f.read()
c = re.sub(r'serviceWorkerSettings:\s*\{[^}]*\}', 'serviceWorkerSettings: null', c)
with open('build/web/flutter_bootstrap.js', 'w') as f:
    f.write(c)
" 2>/dev/null || true
fi

cat << 'EOF' > build/web/flutter_service_worker.js
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.map((k) => caches.delete(k))))
      .then(() => self.registration.unregister())
  );
});
EOF

echo "✓ Production Web (CanvasKit) build complete: build/web/"
