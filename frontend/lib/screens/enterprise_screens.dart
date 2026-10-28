import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/components/buttons.dart';
import '../core/components/cards.dart';
import '../core/components/badges.dart';
import '../core/utils/feedback.dart';

/// 1. Legal Entity & Subsidiary Governance
class LegalEntityScreen extends StatelessWidget {
  const LegalEntityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Legal Entity & Subsidiary Governance', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Corporate Registry Compliance, KVK Filings & Intercompany Agreements', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Execute Biometric Sign-Off',
                icon: Icons.fingerprint_rounded,
                onPressed: () {
                  CentriaFeedback.showBiometricConfirmationDialog(
                    context,
                    title: 'Authorize KVK Annual Director Filing',
                    actionLabel: 'KVK Filing Transmitted to Amsterdam Chamber of Commerce',
                    consequenceText: 'Signs statutory corporate resolution for Acme EU Technologies B.V.',
                    onConfirm: () {},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _entityTile('🇬🇧 Acme Global Ltd', 'UK Parent Holding · Companies House #0912481', 'ACTIVE SOVEREIGN', CentriaColors.verifiedFg),
          _entityTile('🇳🇱 Acme EU Technologies B.V.', 'EU Operating Hub · Amsterdam KVK #84910294', 'KVK UBO DUE', CentriaColors.pendingFg),
          _entityTile('🇺🇸 Acme US Inc.', 'Delaware C-Corp · File #DE-9821419', 'GOOD STANDING', CentriaColors.verifiedFg),
        ],
      ),
    );
  }

  Widget _entityTile(String name, String sub, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: CentriaColors.primary900, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(sub, style: CentriaTypography.bodySm),
                ],
              ),
            ),
            StatusBadge.verified(label: status),
          ],
        ),
      ),
    );
  }
}

/// 2. Board Meeting & Investor Data Room
class BoardMeetingScreen extends StatelessWidget {
  const BoardMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Board Meeting & Investor Data Room', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Q4 Staged Board Pack, Unanimous Written Consents & Sealed Governance Records', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Sign Board Resolution',
                icon: Icons.verified_user_rounded,
                onPressed: () {
                  CentriaFeedback.showBiometricConfirmationDialog(
                    context,
                    title: 'Sign Board Resolution #RES-2026-Q4',
                    actionLabel: 'Board Resolution Unanimously Ratified',
                    consequenceText: 'Enclave signature recorded for all 5 voting board members.',
                    onConfirm: () {},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Q4 Staged Agenda Items', style: CentriaTypography.headlineSm),
                const SizedBox(height: 12),
                _agendaItem('1. FY26 Sovereign Budget & Treasury Allocation (€15M Inflow)', 'UNANIMOUS APPROVAL'),
                _agendaItem('2. Series B Term Sheet Ratification & Expansion of Option Pool', 'READY TO VOTE'),
                _agendaItem('3. Appointment of Independent Statutory Auditor (KPMG UK)', 'EXECUTED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _agendaItem(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: CentriaTypography.labelMd)),
          StatusBadge.info(label: status),
        ],
      ),
    );
  }
}

/// 3. Investor Relations Screen
class InvestorRelationsScreen extends StatelessWidget {
  const InvestorRelationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Investor Relations & Stakeholders', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Institutional Shareholder Communications & Quarterly Amortization Updates', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize Q3 Shareholder Memo',
                icon: Icons.campaign_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Q3 Shareholder Memo Dispatched to Cap Table Leads'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Text(
              'Quarterly Investor Summary: Net revenue growth 48% YoY, Cash runway 18.4 months, zero statutory defaults.',
              style: CentriaTypography.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. M&A Due Diligence Screen
class MADueDiligenceScreen extends StatelessWidget {
  const MADueDiligenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mergers & Acquisitions', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Confidential Acquisition Data Room, LOI Addendums & Valuation Models', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Sign LOI Addendum',
                icon: Icons.fingerprint_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'LOI Addendum Signed with Enclave Biometrics'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Text(
              'Target Acquisition "Project Titan": Red-line legal review completed by Covington & Burling. IP transfer warranties verified.',
              style: CentriaTypography.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Crisis Management & Incident Response Console
class CrisisManagementScreen extends StatelessWidget {
  const CrisisManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Crisis Management & Incident Response', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Statutory Emergency Dispatch & Automated Infrastructure Hardening', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton.critical(
                label: 'Deploy Hardened Isolation Filter',
                icon: Icons.emergency_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Hardened Network Isolation Filter Activated Across All Clusters'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            backgroundColor: CentriaColors.surfaceCard,
            border: const BorderSide(color: CentriaColors.criticalBorder),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusBadge.critical(label: 'ZERO ACTIVE CRITICAL INCIDENTS'),
                const SizedBox(height: 8),
                Text('All Enclave nodes operating within nominal statutory tolerances. Failover hot-standby active in Dublin and Frankfurt.',
                    style: CentriaTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. ESG & Sustainability Ledger Screen
class EsgLedgerScreen extends StatelessWidget {
  const EsgLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESG & Sustainability Ledger', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('CSRD Corporate Sustainability Reporting, Scope 1-3 Audits & Carbon Provenance', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize CSRD Filing',
                icon: Icons.fingerprint_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'CSRD Sustainability Filing Signed with Biometrics'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Scope 1 & 2 Emissions',
                  value: '42.1 tCO2e',
                  subtitle: '-18% reduction YoY',
                  icon: Icons.eco_outlined,
                  badge: const StatusBadge.verified(label: 'Carbon Neutral'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Cloud Green Energy',
                  value: '99.4%',
                  subtitle: 'Frankfurt Hydro Facility',
                  icon: Icons.bolt_outlined,
                  badge: const StatusBadge.verified(label: 'Renewable 24/7'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 7. Executive Compensation Remuneration Committee Console
class ExecutiveCompScreen extends StatelessWidget {
  const ExecutiveCompScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Executive Compensation & RemCo Console', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('LTIP Tranche Vesting, Radford Benchmark Governance & Equity Settlement', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize RemCo Resolution',
                icon: Icons.fingerprint_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'RemCo FY25 LTIP Vesting Resolution Ratified'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FY25 Executive LTIP Tranche 3 Vesting & Performance Gates', style: CentriaTypography.headlineSm),
                const SizedBox(height: 8),
                Text('Performance Gate 1: Arr > €10M (Achieved: €12.4M) · Gate 2: Net Retention > 115% (Achieved: 122%)',
                    style: CentriaTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 8. Intellectual Property & Patent Portfolio Screen
class IpPatentsScreen extends StatelessWidget {
  const IpPatentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Intellectual Property & Patent Portfolio', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('USPTO, EPO & PCT National Phase Docketing & Cryptographic Claim Inventories', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize National Phase Filing',
                icon: Icons.fingerprint_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'PCT National Phase Filing Authorized with Bird & Bird Counsel'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Sovereign Patents (4 Granted, 2 Staged)', style: CentriaTypography.headlineSm),
                const SizedBox(height: 8),
                Text('US Patent #11,842,910: Sovereign Enclave Balance Sheet Cryptographic Verification Engine.',
                    style: CentriaTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 9. Sovereign Risk & Enterprise Insurance Screen
class RiskInsuranceScreen extends StatelessWidget {
  const RiskInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sovereign Risk & Enterprise Insurance', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('D&O Liability, Cyber Re-insurance & Underwriter Covenant Audits', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize Policy Renewal',
                icon: Icons.fingerprint_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Lloyds of London D&O Policy Renewal Authorized'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Text(
              'Active Policies: €20M Directors & Officers Liability (Chubb UK), €10M Enterprise Cyber Re-insurance (Lloyds Syndicate 2001).',
              style: CentriaTypography.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}

/// 10. Integrations & API Ecosystem Screen
class IntegrationApiScreen extends StatelessWidget {
  const IntegrationApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Integrations & API Ecosystem', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('mTLS Signed Webhooks, AWS STS Ingestion Enclaves & Banking Connectors', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Rotate mTLS Key Immediately',
                icon: Icons.sync_lock_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Banking Webhook mTLS Key Rotated in Enclave'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Connected Connectors',
                  value: '14 Active',
                  subtitle: '100% Health Check',
                  icon: Icons.hub_rounded,
                  badge: const StatusBadge.verified(label: 'All Healthy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Webhook Stream',
                  value: '99.98% SLA',
                  subtitle: '142,890 events / 24h',
                  icon: Icons.stream_rounded,
                  badge: const StatusBadge.info(label: 'Live Relay'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
