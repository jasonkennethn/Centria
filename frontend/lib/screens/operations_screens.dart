import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/components/buttons.dart';
import '../core/components/cards.dart';
import '../core/components/badges.dart';
import '../core/utils/feedback.dart';

/// 1. Financial Control & Cash Screen
class FinancialControlScreen extends StatelessWidget {
  const FinancialControlScreen({super.key});

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
                    Text('Financial Control & Cash', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Multi-Jurisdiction Sovereign Bank Accounts & Balance Sheet Reconciliation', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Reconcile Bank Feeds',
                icon: Icons.sync_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Bank Feeds Reconciled with Sovereign Ledger'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Multi-Currency Breakdown
          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Consolidated Treasury Balance', style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
                    const Spacer(),
                    const StatusBadge.verified(label: 'Real-Time Sync'),
                  ],
                ),
                const SizedBox(height: 6),
                Text('₹5,84,21,000', style: CentriaTypography.display.copyWith(fontFamily: 'JetBrains Mono', color: CentriaColors.primary900)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: CentriaRadii.componentRadius,
                  child: Row(
                    children: [
                      Expanded(flex: 83, child: Container(height: 8, color: CentriaColors.primary900)),
                      Expanded(flex: 17, child: Container(height: 8, color: CentriaColors.primary500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _currencyPill('INR (₹)', '₹4,84,21,000', '83%', CentriaColors.primary900),
                    _currencyPill('USD (\$)', '\$120,000', '17%', CentriaColors.primary500),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Sovereign Bank Enclaves', style: CentriaTypography.headlineSm),
          const SizedBox(height: 12),

          _bankAccountTile('HDFC Bank Corporate Current', 'IFSC HDFC0000240 · Acc •••• 8920', '₹3,42,15,000', 'Bengaluru Hub', Icons.account_balance),
          _bankAccountTile('ICICI Bank Treasury Enclave', 'IFSC ICIC0000002 · Acc •••• 4102', '₹1,42,06,000', 'Mumbai Hub', Icons.account_balance),
          _bankAccountTile('State Bank of India (SBI) Operational', 'IFSC SBIN0000800 · Acc •••• 1198', '₹1,00,00,000', 'Bengaluru Hub', Icons.account_balance),
        ],
      ),
    );
  }

  Widget _currencyPill(String code, String amount, String share, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$code $amount ($share)', style: CentriaTypography.labelSm),
      ],
    );
  }

  Widget _bankAccountTile(String name, String sub, String balance, String hub, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            Icon(icon, color: CentriaColors.primary900, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(sub, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
                ],
              ),
            ),
            StatusBadge.info(label: hub),
            const SizedBox(width: 16),
            Text(balance, style: CentriaTypography.headlineSm.copyWith(fontFamily: 'JetBrains Mono')),
          ],
        ),
      ),
    );
  }
}

/// 2. Expense & Card Controls Screen
class ExpenseCardControlsScreen extends StatelessWidget {
  const ExpenseCardControlsScreen({super.key});

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
                    Text('Expense & Card Controls', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Policy Caps, Corporate Cards & Automated Receipt Forensic Reconciliation', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: '+ Issue Virtual Card',
                icon: Icons.add_card_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Virtual Card Provisioning Modal Opened'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Monthly Spend',
                  value: '₹14,28,000',
                  subtitle: '78% of Monthly Cap',
                  icon: Icons.credit_card_rounded,
                  badge: const StatusBadge.verified(label: 'In Policy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Active Cards',
                  value: '18 Cards',
                  subtitle: '4 Departments',
                  icon: Icons.badge_outlined,
                  badge: const StatusBadge.info(label: 'RuPay & Visa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Corporate Card Roster & Caps', style: CentriaTypography.headlineSm),
          const SizedBox(height: 12),

          _cardTile('Executive Travel & Legal', '•••• 4892 · Sarah Jenkins (RuPay)', '₹25,00,000 / mo', '₹4,21,000 Spent', Icons.credit_card),
          _cardTile('Engineering Cloud AWS & AI', '•••• 1024 · Michael Chen (Visa)', '₹60,00,000 / mo', '₹42,89,000 Spent', Icons.credit_card),
          _cardTile('Marketing & Commercial Ops', '•••• 9140 · Rahul Sharma (RuPay)', '₹15,00,000 / mo', '₹9,14,000 Spent', Icons.credit_card),
        ],
      ),
    );
  }

  Widget _cardTile(String dept, String cardInfo, String limit, String spent, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            Icon(icon, color: CentriaColors.primary900, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dept, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(cardInfo, style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(spent, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                Text('Limit: $limit', style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. Sovereign Treasury & FX Control Screen
class TreasuryFxScreen extends StatelessWidget {
  const TreasuryFxScreen({super.key});

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
                    Text('Sovereign Treasury & FX Control', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Autonomous Liquidity Sweeps, Foreign Exchange Collars & Value-at-Risk Hedging', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Simulate Scenarios',
                icon: Icons.insights_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Macro FX Stress Simulation Completed (VaR < 1%)'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          AIProposalCard(
            title: 'Cognitive Treasury Signal: Forward Collar #INR-FWD-401',
            description:
                'USD/INR volatility exceeded 1.8% threshold. Proposed hedge collar locks ₹8,50,00,000 (\$1M) at strike 84.15 to safeguard Q1 2027 operational runway.',
            confidence: '98% conf',
            onAccept: () {
              CentriaFeedback.showBiometricConfirmationDialog(
                context,
                title: 'Execute Forward Collar #INR-FWD-401',
                actionLabel: 'Forward Collar #INR-FWD-401 Executed with Biometrics',
                consequenceText: 'Notional amount ₹8,50,00,000 locked against HDFC Corporate Treasury enclave.',
                onConfirm: () {},
              );
            },
            onReject: () => CentriaFeedback.showAction(context, title: 'Forward Collar proposal dismissed'),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'FX Value-at-Risk (24h)',
                  value: '₹1,42,000',
                  subtitle: '99% Confidence Interval',
                  icon: Icons.analytics_outlined,
                  badge: const StatusBadge.verified(label: 'Safe Exposure'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'INR Liquid Reserve',
                  value: '7.15% APY',
                  subtitle: '₹3,38,86,500 Allocated',
                  icon: Icons.trending_up_rounded,
                  badge: const StatusBadge.info(label: 'T-Bills & Overnight'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4. People, Org & Access Matrix Screen
class PeopleOrgAccessScreen extends StatelessWidget {
  const PeopleOrgAccessScreen({super.key});

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
                    Text('People, Org & Access Matrix', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Enclave Cryptographic Keys, Hardware Passkeys & Zero-Trust Privilege Registers', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Audit Enclave Keys',
                icon: Icons.security_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Zero-Trust Enclave Key Audit Passed'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _memberRow('Sarah Jenkins', 'CEO / Executive Director', 'FIPS 140-3 Hardware Key', 'Full Enclave Sovereign', Icons.verified_user),
          _memberRow('David Vance', 'Chief Information Security Officer', 'FIDO2 / YubiKey 5Ci', 'Security & Infrastructure', Icons.security),
          _memberRow('Elena Rostova', 'General Counsel & Company Sec', 'Apple Enclave TouchID', 'Statutory Legal & KVK', Icons.gavel),
          _memberRow('Michael Chen', 'VP Engineering', 'YubiKey Bio 5', 'Production Cloud & STS', Icons.code),
        ],
      ),
    );
  }

  Widget _memberRow(String name, String role, String keyType, String privilege, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CentriaCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: CentriaColors.primary50,
              child: Icon(icon, color: CentriaColors.primary900, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(role, style: CentriaTypography.bodySm),
                  const SizedBox(height: 2),
                  Text('Token: $keyType', style: CentriaTypography.dataMono.copyWith(color: CentriaColors.textMuted)),
                ],
              ),
            ),
            StatusBadge.verified(label: privilege),
          ],
        ),
      ),
    );
  }
}

/// 5. Creation Studio Screen
class CreationStudioScreen extends StatelessWidget {
  const CreationStudioScreen({super.key});

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
                    Text('Creation Studio', style: CentriaTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text('Composable Enclave Entities, Declarative Workflow Automation & Schema Engines', style: CentriaTypography.bodySm),
                  ],
                ),
              ),
              CentriaButton(
                label: 'Dry-Run Mutation',
                icon: Icons.play_arrow_rounded,
                onPressed: () => CentriaFeedback.showAction(context, title: 'Dry-Run Schema Simulation: 0 Faults, 100% Spec Valid'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CentriaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_mosaic_rounded, color: CentriaColors.cognitiveDeep, size: 20),
                        const SizedBox(width: 8),
                        Text('Entity & Schema Registry (12 Defined)', style: CentriaTypography.headlineSm),
                      ],
                    ),
                    const StatusBadge.cognitive(label: 'Spec v4.2'),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Active Sovereign Schemas with Cryptographic Proof Integrity:', style: CentriaTypography.bodySm),
                const SizedBox(height: 12),
                _schemaItem('StatutoryTaxPack', 'MCA V3 & GSTN statutory filing records with Merkle root bindings'),
                _schemaItem('TreasuryCollarContract', 'ISDA bilateral forward hedging contracts & currency risk collars'),
                _schemaItem('RemCoLTIPTranche', 'Executive stock grants with multi-year milestone vesting gates'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _schemaItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CentriaColors.surfaceInset,
          borderRadius: CentriaRadii.componentRadius,
        ),
        child: Row(
          children: [
            Text(name, style: CentriaTypography.dataMonoBold.copyWith(color: CentriaColors.primary900)),
            const SizedBox(width: 12),
            Expanded(child: Text(desc, style: CentriaTypography.bodySm)),
          ],
        ),
      ),
    );
  }
}
