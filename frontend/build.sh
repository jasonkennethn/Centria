#!/bin/bash
set -e

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release
