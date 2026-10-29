#!/usr/bin/env bash
set -e

# Centria Web Production Build Script
echo "=========================================="
echo " Building Centria Web for Production"
echo "=========================================="

# Flutter 3.24+ unified web builds on CanvasKit/Wasm.
# We build release mode with optimizations.
flutter build web --release

echo "✓ Production web build complete: build/web/"
