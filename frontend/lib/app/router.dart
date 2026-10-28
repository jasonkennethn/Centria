import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth_screens.dart';
import '../screens/core_screens.dart';
import '../screens/operations_screens.dart';
import '../screens/governance_screens.dart';
import '../screens/enterprise_screens.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter centriaRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    // Auth routes (outside shell)
    GoRoute(
      path: '/splash',
      builder: (context, state) => const CentriaSplashScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const ExecutiveSignInScreen(),
    ),
    GoRoute(
      path: '/hardware-key-verify',
      builder: (context, state) => const HardwareKeyVerificationScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const EnterpriseOnboardingScreen(),
    ),

    // Application Workspace (Inside Shell)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Core Cockpit
        GoRoute(
          path: '/overview',
          builder: (context, state) => const CompanyOverviewScreen(),
        ),
        GoRoute(
          path: '/my-day',
          builder: (context, state) => const MyDayScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksProjectsScreen(),
        ),
        GoRoute(
          path: '/approvals',
          builder: (context, state) => const ApprovalsHubScreen(),
        ),
        GoRoute(
          path: '/inbox',
          builder: (context, state) => const InboxNotificationsScreen(),
        ),

        // Commercial & Capital
        GoRoute(
          path: '/finance',
          builder: (context, state) => const FinancialControlScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpenseCardControlsScreen(),
        ),
        GoRoute(
          path: '/treasury',
          builder: (context, state) => const TreasuryFxScreen(),
        ),
        GoRoute(
          path: '/people',
          builder: (context, state) => const PeopleOrgAccessScreen(),
        ),
        GoRoute(
          path: '/creation-studio',
          builder: (context, state) => const CreationStudioScreen(),
        ),

        // Sovereign Governance & Legal
        GoRoute(
          path: '/compliance-radar',
          builder: (context, state) => const ComplianceRadarScreen(),
        ),
        GoRoute(
          path: '/security-compliance',
          builder: (context, state) => const SecurityComplianceScreen(),
        ),
        GoRoute(
          path: '/audit-trail',
          builder: (context, state) => const AuditTrailScreen(),
        ),
        GoRoute(
          path: '/tax-console',
          builder: (context, state) => const AuditStatutoryTaxScreen(),
        ),
        GoRoute(
          path: '/cap-table',
          builder: (context, state) => const CapTableScreen(),
        ),
        GoRoute(
          path: '/legal-entities',
          builder: (context, state) => const LegalEntityScreen(),
        ),
        GoRoute(
          path: '/board-meeting',
          builder: (context, state) => const BoardMeetingScreen(),
        ),
        GoRoute(
          path: '/investor-relations',
          builder: (context, state) => const InvestorRelationsScreen(),
        ),
        GoRoute(
          path: '/ma-due-diligence',
          builder: (context, state) => const MADueDiligenceScreen(),
        ),
        GoRoute(
          path: '/crisis-management',
          builder: (context, state) => const CrisisManagementScreen(),
        ),
        GoRoute(
          path: '/esg-ledger',
          builder: (context, state) => const EsgLedgerScreen(),
        ),
        GoRoute(
          path: '/remco-console',
          builder: (context, state) => const ExecutiveCompScreen(),
        ),
        GoRoute(
          path: '/ip-patents',
          builder: (context, state) => const IpPatentsScreen(),
        ),
        GoRoute(
          path: '/risk-insurance',
          builder: (context, state) => const RiskInsuranceScreen(),
        ),
        GoRoute(
          path: '/integrations',
          builder: (context, state) => const IntegrationApiScreen(),
        ),
        GoRoute(
          path: '/merkle-proof',
          builder: (context, state) => const InspectMerkleProofScreen(),
        ),
      ],
    ),
  ],
);
