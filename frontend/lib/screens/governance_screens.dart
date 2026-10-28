import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/components/buttons.dart';
import '../core/components/cards.dart';
import '../core/components/badges.dart';
import '../core/utils/feedback.dart';

/// 1. Sovereign Compliance & Regulatory Radar Screen
class ComplianceRadarScreen extends StatelessWidget {
  const ComplianceRadarScreen({super.key});

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
                    Text('Sovereign Compliance & Regulatory Radar', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Continuous Horizon Scanning, DORA, CSRD & Cross-Border Sovereign Obligations', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Ratify DORA Attestation',
                icon: Icons.fingerprint_rounded,
                onPressed: () {
                  CentriaFeedback.showBiometricConfirmationDialog(
                    context,
                    title: 'Ratify DORA Statutory Attestation',
                    actionLabel: 'DORA Compliance Pack Published',
                    consequenceText: 'Enclave verification confirmed for all ICT third-party vendors and statutory risk registers.',
                    onConfirm: () {},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _frameworkCard('DORA (Digital Operational Resilience Act)', 'EU Regulatory Requirement · Enclave Audit Complete', '99.8% READY', CentriaColors.verifiedFg),
          _frameworkCard('CSRD & EU Taxonomy Sustainability', 'Scope 1, 2, 3 Ledger Reconciled via Bureau Veritas', 'READY TO FILE', CentriaColors.primary900),
          _frameworkCard('Companies House UK Statutory Register', 'Confirmation Statement & PSC Register Locked', 'COMPLIANT', CentriaColors.verifiedFg),
        ],
      ),
    );
  }

  Widget _frameworkCard(String title, String desc, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CentriaCard(
        child: Row(
          children: [
            const Icon(Icons.radar_rounded, color: CentriaColors.primary900, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(desc, style: CentriaTypography.bodySm),
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

/// 2. Security & Compliance Registry Screen
class SecurityComplianceScreen extends StatelessWidget {
  const SecurityComplianceScreen({super.key});

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
                    Text('Compliance & Security', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('SOC2 Type II, ISO 27001 & Statutory Cyber Hygiene Certification', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Sign & File Staged Return',
                icon: Icons.draw_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Statutory Security Attestation Signed'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'SOC2 Type II Status',
                  value: 'Certified',
                  subtitle: 'KPMG Independent Audit',
                  icon: Icons.verified_user_rounded,
                  badge: const StatusBadge.verified(label: 'Unqualified Opinion'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'ISO 27001 Enclave',
                  value: 'Zero Findings',
                  subtitle: 'Continuous Hardware Guard',
                  icon: Icons.shield_rounded,
                  badge: const StatusBadge.verified(label: 'Level 4 FIPS'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3. Audit Trail & Immutable Forensics Ledger Screen
class AuditTrailScreen extends StatelessWidget {
  const AuditTrailScreen({super.key});

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
                    Text('Audit Trail & Immutable Forensics Ledger', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Cryptographically Sealed Blocks & Statutory Enclave Proofs', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Ratify Statutory Audit Lock',
                icon: Icons.lock_clock_rounded,
                onPressed: () {
                  CentriaFeedback.showBiometricConfirmationDialog(
                    context,
                    title: 'Ratify Audit Lock',
                    actionLabel: 'Statutory Audit Lock Ratified',
                    consequenceText: 'Locks block #1,048,592 against revisions for 7-year statutory archive period.',
                    onConfirm: () {},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _blockProofTile('Block #1,048,592', '0x8f2a...9c41', 'Cap-Table Share Issue & RemCo Vesting', 'Today, 09:12 UTC', true),
          _blockProofTile('Block #1,048,591', '0x4e1b...3a72', 'Forward Collar #FWD-882 Treasury Staging', 'Today, 08:30 UTC', true),
          _blockProofTile('Block #1,048,590', '0x1c9d...5f08', 'Delaware Franchise Tax Annual Return Sign-Off', 'Yesterday, 17:45 UTC', true),
        ],
      ),
    );
  }

  Widget _blockProofTile(String block, String hash, String desc, String timestamp, bool verified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CentriaColors.surfaceInset,
                borderRadius: CentriaRadii.componentRadius,
              ),
              child: const Icon(Icons.tag_rounded, size: 20, color: CentriaColors.primary900),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(block, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text(hash, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: CentriaTypography.bodySm),
                  const SizedBox(height: 2),
                  Text(timestamp, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const StatusBadge.verified(label: 'Merkle Verified'),
          ],
        ),
      ),
    );
  }
}

/// 4. Audit & Statutory Tax Console Screen
class AuditStatutoryTaxScreen extends StatelessWidget {
  const AuditStatutoryTaxScreen({super.key});

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
                    Text('Audit & Statutory Tax Console', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('MCA Forms AOC-4/MGT-7, GST GSTR-3B & Income Tax TDS Provisions', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Authorize MCA Filing',
                icon: Icons.fingerprint_rounded,
                onPressed: () {
                  CentriaFeedback.showBiometricConfirmationDialog(
                    context,
                    title: 'Authorize MCA Forms AOC-4 & MGT-7 Filing',
                    actionLabel: 'Statutory Pack Transmitted to MCA V3 Portal',
                    consequenceText: 'Publishes audited financial statements and director report to Registrar of Companies (ROC Bangalore).',
                    onConfirm: () {},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          AIProposalCard(
            title: 'BSR & Co. Tax Advisory: ₹18,40,250 Input Tax Credit',
            description:
                'Statutory computation identified qualifying AI Enclave engineering capital expenditure. Offset verified against GSTR-2B portal feed reduces direct tax liability to ₹35,00,000.',
            confidence: '99.4% conf',
            onAccept: () => CentriaFeedback.showAction(context, title: 'GST ITC offset staged for GSTR-3B return'),
            onReject: () => CentriaFeedback.showAction(context, title: 'Credit offset review requested'),
          ),
          const SizedBox(height: 20),

          _taxObligationTile('MCA Annual Filing (Forms AOC-4 & MGT-7)', 'Due Nov 05, 2026 · Statutory Audit Pack Signed by BSR & Co.', 'READY TO FILE'),
          _taxObligationTile('GST Monthly Return (GSTR-3B & GSTR-1)', 'Due Nov 20, 2026 · ₹18,40,250 Tax Liability offset with ITC', 'VERIFIED'),
          _taxObligationTile('Income Tax Q3 Advance Tax (ITD 26AS/TDS)', 'Due Dec 15, 2026 · ₹35,00,000 Provisioned', 'STAGED'),
          _taxObligationTile('EPFO & ESIC Monthly Remittance', 'Filed Oct 15, 2026 · ₹6,84,120 for 142 Employees · Ref #ECR-89214', 'FILED'),
        ],
      ),
    );
  }

  Widget _taxObligationTile(String title, String subtitle, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: CentriaColors.primary900, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: CentriaTypography.bodySm),
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

/// 5. Cap Table & Sovereign Equity Ledger Screen
class CapTableScreen extends StatelessWidget {
  const CapTableScreen({super.key});

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
                    Text('Cap Table & Sovereign Equity Ledger', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Fully Diluted Equity Register (10,000,000 Shares), Option Pools & Investor Rights', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Simulate Round',
                icon: Icons.science_outlined,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Series B Dilution Simulation Model Loaded'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Option Pool Capacity',
                  value: '8.40%',
                  subtitle: '840,000 Shares Remain',
                  icon: Icons.token_outlined,
                  badge: const StatusBadge.verified(label: 'Optimal Pool'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Ledger Integrity',
                  value: '100.0%',
                  subtitle: 'Zero Reconciliation Diff',
                  icon: Icons.verified_user_outlined,
                  badge: const StatusBadge.verified(label: 'Cryptographic Root'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Share Classes & Ownership', style: CentriaTypography.headlineSm),
          const SizedBox(height: 12),

          _shareholderTile('Ordinary Shares (Voting)', 'Founders & Executive Team', '5,420,000 Shares', '54.20%'),
          _shareholderTile('Series A Preferred', 'Index Ventures & Seedcamp', '2,850,000 Shares', '28.50%'),
          _shareholderTile('Series B Staged', 'Committed Lead Term Sheet', '890,000 Shares', '8.90%'),
          _shareholderTile('Unallocated ESOP Pool', 'Employee Stock Option Trust', '840,000 Shares', '8.40%'),
        ],
      ),
    );
  }

  Widget _shareholderTile(String shareClass, String holders, String count, String pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            const Icon(Icons.pie_chart_outline_rounded, color: CentriaColors.primary900, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shareClass, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(holders, style: CentriaTypography.bodySm),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(pct, style: CentriaTypography.headlineSm.copyWith(fontFamily: 'JetBrains Mono')),
                Text(count, style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 6. Inspect Block Merkle Proof Screen
class InspectMerkleProofScreen extends StatelessWidget {
  const InspectMerkleProofScreen({super.key});

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
                    Text('Inspect Block Merkle Proof #1,048,592', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Cryptographic Leaf Verification & SHA-256 Provenance Audit', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Copy Root Hash',
                icon: Icons.copy_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Merkle Root Copied to Clipboard'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_tree_rounded, color: CentriaColors.cognitiveDeep, size: 24),
                    const SizedBox(width: 12),
                    Text('Merkle Tree Depth: 4 Leaves Verified', style: CentriaTypography.headlineSm),
                    const Spacer(),
                    const StatusBadge.verified(label: 'MATCH 100% IMMUTABLE'),
                  ],
                ),
                const SizedBox(height: 16),
                _proofLine('BLOCK HEIGHT', '1,048,592'),
                _proofLine('ROOT HASH', '0x8f2a419c81b2e4d7a90192837461524310928374615243019283746152438102'),
                _proofLine('TIMESTAMP', '2026-10-28T09:12:44.819Z'),
                _proofLine('WITNESS ENCLAVE', 'FIPS 140-3 Hardware Key Verified (#SJ-EXEC-01)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proofLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: CentriaTypography.dataMonoBold.copyWith(color: CentriaColors.primary900)),
          ),
        ],
      ),
    );
  }
}
