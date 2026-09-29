import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centria/main.dart';
import 'package:centria/modules/public/home_page.dart';
import 'package:centria/modules/public/privacy_policy_page.dart';
import 'package:centria/modules/public/terms_of_service_page.dart';
import 'package:centria/modules/auth/login_page.dart';
import 'package:centria/modules/auth/register_page.dart';
import 'package:centria/modules/auth/otp_verify_page.dart';
import 'package:centria/modules/genesis/genesis_wizard_page.dart';
import 'package:centria/modules/dashboard/dashboard_page.dart';
import 'package:centria/modules/people/people_page.dart';
import 'package:centria/modules/workflows/workflows_page.dart';
import 'package:centria/modules/documents/documents_page.dart';
import 'package:centria/modules/governance/governance_page.dart';
import 'package:centria/modules/operations/operations_page.dart';
import 'package:centria/modules/finance/finance_page.dart';
import 'package:centria/modules/analytics/analytics_page.dart';
import 'package:centria/modules/ai_copilot/copilot_page.dart';
import 'package:centria/modules/customization/customization_page.dart';
import 'package:centria/widgets/omnibar_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Centria App Smoke Test & Public Navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const CentriaApp());
    expect(find.byType(CentriaApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Public Landing Page renders Hero & CTA buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String navigatedRoute = '';
    await tester.pumpWidget(MaterialApp(
      home: HomePage(onNavigate: (route) => navigatedRoute = route),
    ));

    expect(find.text('Centria'), findsWidgets);
    expect(find.text('Run Your Entire Company\nFrom One Intelligent Platform.'), findsOneWidget);

    final signInBtn = find.widgetWithText(OutlinedButton, 'Sign In');
    expect(signInBtn, findsOneWidget);
    await tester.tap(signInBtn);
    expect(navigatedRoute, '/login');
  });

  testWidgets('Privacy Policy and Terms of Service render correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(
      home: PrivacyPolicyPage(onNavigate: (_) {}),
    ));
    expect(find.text('Centria Enterprise Privacy Policy'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: TermsOfServicePage(onNavigate: (_) {}),
    ));
    expect(find.text('Centria Enterprise Terms of Service'), findsOneWidget);
  });

  testWidgets('Authentication Screens render correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(
      home: LoginPage(onNavigate: (route, {arguments}) {}),
    ));
    expect(find.text('Sign in to your Operating System'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(onNavigate: (route, {arguments}) {}),
    ));
    expect(find.text('Create Your Organization Workspace'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: OtpVerifyPage(email: 'test@example.com', onNavigate: (route, {arguments}) {}),
    ));
    expect(find.text('Verify Your Email'), findsOneWidget);
  });

  testWidgets('Company Genesis Wizard renders questions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(
      home: GenesisWizardPage(onNavigate: (_) {}),
    ));
    expect(find.text('60-Second Company Genesis Wizard'), findsOneWidget);
    expect(find.text('Company Legal Name'), findsOneWidget);
  });

  testWidgets('Core Modules instantiate without exceptions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(MaterialApp(home: DashboardPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(DashboardPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: PeoplePage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(PeoplePage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: WorkflowsPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(WorkflowsPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: DocumentsPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(DocumentsPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: GovernancePage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(GovernancePage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: OperationsPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(OperationsPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: FinancePage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(FinancePage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: AnalyticsPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(AnalyticsPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: CopilotPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(CopilotPage), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: CustomizationPage(onNavigate: (_) {}, onOpenDrawer: () {})));
    expect(find.byType(CustomizationPage), findsOneWidget);
  });

  testWidgets('Universal Omnibar Dialog renders search input', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: OmnibarDialog(),
      ),
    ));

    expect(find.byType(TextField), findsOneWidget);
  });
}
