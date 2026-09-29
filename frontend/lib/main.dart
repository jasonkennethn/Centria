import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/omnibar_dialog.dart';

import 'modules/public/home_page.dart';
import 'modules/public/privacy_policy_page.dart';
import 'modules/public/terms_of_service_page.dart';
import 'modules/auth/login_page.dart';
import 'modules/auth/register_page.dart';
import 'modules/auth/otp_verify_page.dart';
import 'modules/genesis/genesis_wizard_page.dart';
import 'modules/dashboard/dashboard_page.dart';
import 'modules/people/people_page.dart';
import 'modules/workflows/workflows_page.dart';
import 'modules/documents/documents_page.dart';
import 'modules/governance/governance_page.dart';
import 'modules/operations/operations_page.dart';
import 'modules/finance/finance_page.dart';
import 'modules/analytics/analytics_page.dart';
import 'modules/ai_copilot/copilot_page.dart';
import 'modules/customization/customization_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CentriaApp());
}

class CentriaApp extends StatefulWidget {
  const CentriaApp({super.key});

  @override
  State<CentriaApp> createState() => _CentriaAppState();
}

class _CentriaAppState extends State<CentriaApp> {
  String _currentRoute = '/';
  dynamic _routeArgs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(String route, {dynamic arguments}) {
    setState(() {
      _currentRoute = route;
      _routeArgs = arguments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} — ${AppConstants.appTagline}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
            OmnibarDialog.show(context);
          },
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
            OmnibarDialog.show(context);
          },
        },
        child: Focus(
          autofocus: true,
          child: _buildAppRouter(),
        ),
      ),
    );
  }

  Widget _buildAppRouter() {
    // Standalone Public & Auth Pages (No Sidebar)
    if (_currentRoute == '/') {
      return HomePage(onNavigate: _navigate);
    }
    if (_currentRoute == '/privacy-policy') {
      return PrivacyPolicyPage(onNavigate: _navigate);
    }
    if (_currentRoute == '/terms-of-service') {
      return TermsOfServicePage(onNavigate: _navigate);
    }
    if (_currentRoute == '/login') {
      return LoginPage(onNavigate: _navigate);
    }
    if (_currentRoute == '/register') {
      return RegisterPage(onNavigate: _navigate);
    }
    if (_currentRoute == '/otp-verify') {
      return OtpVerifyPage(
        email: _routeArgs is String ? _routeArgs : 'admin@celarox.com',
        onNavigate: _navigate,
      );
    }
    if (_currentRoute == '/genesis') {
      return GenesisWizardPage(onNavigate: _navigate);
    }

    // Authenticated Workspace Shell with Sidebar + Content
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.darkBg,
          drawer: !isDesktop
              ? Drawer(
                  backgroundColor: AppTheme.darkCard,
                  child: AppSidebar(
                    activeRoute: _currentRoute,
                    onNavigate: (r) {
                      Navigator.pop(context);
                      _navigate(r);
                    },
                  ),
                )
              : null,
          body: Row(
            children: [
              if (isDesktop)
                AppSidebar(
                  activeRoute: _currentRoute,
                  onNavigate: _navigate,
                ),
              Expanded(
                child: _buildMainModuleView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainModuleView() {
    void openDrawer() => _scaffoldKey.currentState?.openDrawer();

    switch (_currentRoute) {
      case '/dashboard':
        return DashboardPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/people':
        return PeoplePage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/workflows':
        return WorkflowsPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/documents':
        return DocumentsPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/governance':
        return GovernancePage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/operations':
        return OperationsPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/finance':
        return FinancePage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/analytics':
        return AnalyticsPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/copilot':
        return CopilotPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      case '/customization':
        return CustomizationPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
      default:
        return DashboardPage(onNavigate: _navigate, onOpenDrawer: openDrawer);
    }
  }
}
