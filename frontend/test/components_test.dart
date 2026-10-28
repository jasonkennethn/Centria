import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centria/core/components/buttons.dart';
import 'package:centria/core/components/badges.dart';
import 'package:centria/core/components/cards.dart';
import 'package:centria/core/components/demo_mode_banner.dart';
import 'package:centria/core/theme/app_theme.dart';

void main() {
  testWidgets('Core components render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CentriaTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const DemoModeBanner(),
                const StatusBadge.verified(label: 'Verified Sync'),
                const StatusBadge.pending(label: 'Pending Approval'),
                const StatusBadge.critical(label: 'Breach Blocker'),
                CentriaButton(
                  label: 'Execute Action',
                  onPressed: () {},
                ),
                CentriaButton.secondary(
                  label: 'Secondary Action',
                  onPressed: () {},
                ),
                CentriaButton.cognitive(
                  label: 'AI Mutation',
                  onPressed: () {},
                ),
                AIProposalCard(
                  title: 'Tax Offsetting',
                  description: 'Offset €94,200 in R&D credit.',
                  confidence: '99% conf',
                  onAccept: () {},
                  onReject: () {},
                ),
                const MetricCard(
                  label: 'Consolidated Cash',
                  value: '€5,842,100',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('DEMO MODE ACTIVE'), findsOneWidget);
    expect(find.text('Verified Sync'), findsOneWidget);
    expect(find.text('Pending Approval'), findsOneWidget);
    expect(find.text('Breach Blocker'), findsOneWidget);
    expect(find.text('Execute Action'), findsOneWidget);
    expect(find.text('Secondary Action'), findsOneWidget);
    expect(find.text('AI Mutation'), findsOneWidget);
    expect(find.text('Tax Offsetting'), findsOneWidget);
    expect(find.text('€5,842,100'), findsOneWidget);
  });
}
