#!/bin/bash
set -e

echo "=== Configuring Git Safe Directory ==="
git config --global --add safe.directory "*" || true

echo "=== Installing Flutter SDK ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

echo "=== Pre-caching Flutter Web Artifacts ==="
flutter config --no-analytics
flutter config --enable-web
flutter precache --web

echo "=== Installing Flutter Dependencies ==="
flutter pub get

echo "=== Compiling Flutter Web Application ==="
flutter build web --release --no-tree-shake-icons

echo "=== Flutter Web Build Completed Successfully ==="
