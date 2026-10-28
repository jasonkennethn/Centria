import 'package:flutter_test/flutter_test.dart';
import 'package:centria/app/app.dart';
import 'package:centria/app/router.dart';

void main() {
  testWidgets('Router supports navigation to key routes', (WidgetTester tester) async {
    await tester.pumpWidget(const CentriaApp());
    await tester.pumpAndSettle();

    // Verify initial route is Splash
    expect(find.text('CENTRIA'), findsOneWidget);

    // Deep link to /overview
    centriaRouter.go('/overview');
    await tester.pumpAndSettle();
    expect(find.text('Acme Global Ltd'), findsWidgets);
    expect(find.text('CONSOLIDATED CASH'), findsOneWidget);

    // Deep link to /my-day
    centriaRouter.go('/my-day');
    await tester.pumpAndSettle();
    expect(find.textContaining('Good morning'), findsOneWidget);

    // Deep link to /tasks
    centriaRouter.go('/tasks');
    await tester.pumpAndSettle();
    expect(find.text('Tasks & Projects'), findsOneWidget);

    // Deep link to /approvals
    centriaRouter.go('/approvals');
    await tester.pumpAndSettle();
    expect(find.text('Approvals Hub'), findsOneWidget);

    // Deep link to /finance
    centriaRouter.go('/finance');
    await tester.pumpAndSettle();
    expect(find.text('Financial Control & Cash'), findsOneWidget);

    // Deep link to /creation-studio
    centriaRouter.go('/creation-studio');
    await tester.pumpAndSettle();
    expect(find.text('Creation Studio'), findsOneWidget);

    // Deep link to /compliance-radar
    centriaRouter.go('/compliance-radar');
    await tester.pumpAndSettle();
    expect(find.text('Sovereign Compliance & Regulatory Radar'), findsOneWidget);
  });
}
