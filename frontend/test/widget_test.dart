import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centria/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CentriaApp(hasSeenSplash: true));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Centria'), findsWidgets);
  });

  testWidgets('Auth modal: Forgot password only at signin and OTP stages', (WidgetTester tester) async {
    // Set a wide viewport to ensure navbar elements are rendered cleanly
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CentriaApp(hasSeenSplash: true));
    await tester.pump(const Duration(milliseconds: 700));

    // Tap Get Started button to open Create Workspace modal
    final getStartedBtn = find.text('Get Started');
    expect(getStartedBtn, findsWidgets);
    await tester.tap(getStartedBtn.first);
    await tester.pumpAndSettle();

    // In Create Workspace mode:
    expect(find.text('Create Workspace'), findsWidgets);
    // Forgot password MUST NOT be present at create/sign-up
    expect(find.text('Forgot password?'), findsNothing);

    // Switch to Sign In mode
    final switchToSignIn = find.text('Already have an account? Sign in');
    expect(switchToSignIn, findsOneWidget);
    await tester.tap(switchToSignIn);
    await tester.pumpAndSettle();

    // Now in Sign In mode:
    expect(find.text('Sign In to Centria'), findsOneWidget);
    // Forgot password MUST be present at sign in
    expect(find.text('Forgot password?'), findsOneWidget);

    // Tap Forgot password
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    // Stage 1: Reset Password (email only, no new password/re-type yet)
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(find.text('6-digit OTP Code'), findsNothing);
    expect(find.text('New Password'), findsNothing);
    expect(find.text('Re-type New Password'), findsNothing);
  });
}
