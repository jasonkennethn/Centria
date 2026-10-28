# Centria — Sovereign Company Operating System (Frontend)

Cross-platform Flutter application for the Centria Sovereign Company OS, implemented according to the Executive Precision design specification and targeting Web, Android APK, and iOS.

---

## Architectural Highlights

- **Framework**: Flutter (Dart 3.7+ / Flutter 3.29+)
- **Design System**: "Executive Precision" institutional light theme (`#FBFBF9` canvas, `#0C4A45` primary teal, `#6D28D9` cognitive violet, `#E2E8F0` structural hairlines)
- **Routing**: `go_router` declarative navigation with full web deep linking and back/forward browser history
- **Typography**: Google Fonts `Inter` for UI typography and `JetBrains Mono` for tabular financial data, currency figures, and Merkle block proofs
- **Responsive Layout**: Adaptive layout shell scaling from mobile viewports (390–430px) to wide enterprise workstations (1440px+)
- **Demo Data Boundaries**: Unobtrusive `Demo Mode Active` banner with honest state feedback for all simulated biometric sign-offs

---

## Quick Start & Build Instructions

### 1. Prerequisites
Ensure Flutter 3.29+ is installed and on your `PATH`:
```bash
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

### 2. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 3. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### 4. Build for Web
```bash
flutter build web --release
```
The optimized web application bundle is generated in `build/web/`.

### 5. Build for Android (APK)
```bash
flutter build apk --debug
```
The Android APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`.

### 6. Build for iOS (IPA)
*Note: Requires macOS with Xcode and Apple Developer signing tools configured.*
```bash
flutter build ipa --release
```

---

## Documentation
- [Design Folder Inventory](docs/design_inventory.md)
- [Design-to-Code Traceability Matrix](docs/design_traceability.md)
- [Implementation Notes](docs/implementation_notes.md)
- [Verification Report](docs/verification_report.md)

---

## Author

**Jason Kenneth N**  
- **GitHub**: [@jasonkennethn](https://github.com/jasonkennethn)  
- **Repository**: [https://github.com/jasonkennethn/Centria](https://github.com/jasonkennethn/Centria)  
