import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centria/app/app.dart';
import 'package:centria/app/router.dart';

void main() {
  testWidgets('Router supports navigation to key routes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CentriaApp());
    await tester.pumpAndSettle();

    // Verify initial route is Splash
    expect(find.text('CENTRIA'), findsOneWidget);

    // Deep link to /overview
    centriaRouter.go('/overview');
    await tester.pumpAndSettle();
    expect(find.text('Centria Technologies India Pvt Ltd'), findsWidgets);
    expect(find.text('CONSOLIDATED CASH'), findsOneWidget);

    // Deep link to /my-day
    centriaRouter.go('/my-day');
    await tester.pumpAndSettle();
    expect(find.textContaining('Good morning'), findsOneWidget);

    // Deep link to /tasks
    centriaRouter.go('/tasks');
    await tester.pumpAndSettle();
    expect(find.text('Tasks & Projects'), findsWidgets);

    // Deep link to /approvals
    centriaRouter.go('/approvals');
    await tester.pumpAndSettle();
    expect(find.text('Approvals Hub'), findsWidgets);

    // Deep link to /finance
    centriaRouter.go('/finance');
    await tester.pumpAndSettle();
    expect(find.text('Financial Control & Cash'), findsOneWidget);

    // Deep link to /creation-studio
    centriaRouter.go('/creation-studio');
    await tester.pumpAndSettle();
    expect(find.text('Creation Studio'), findsWidgets);

    // Deep link to /compliance-radar
    centriaRouter.go('/compliance-radar');
    await tester.pumpAndSettle();
    expect(find.text('Sovereign Compliance & Regulatory Radar'), findsWidgets);
  });
}
