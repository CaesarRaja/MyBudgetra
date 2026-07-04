import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/stats_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Budget per kategori',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Kontrol budget bulanan',
            style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BudgetraColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BudgetraColors.lightBorder.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penggunaan bulan ini',
                          style: TextStyle(
                            fontSize: 11,
                            color: BudgetraColors.lightMutedFg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '0% budget telah terpakai',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BudgetraColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text('Sisa total', style: TextStyle(fontSize: 11, color: BudgetraColors.primaryStrong)),
                          Text('Rp 0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: BudgetraColors.primaryStrong)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BudgetProgressBar(
                  percentage: 0,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: StatsCard(label: 'Total budget', value: 'Rp 0', icon: Icons.account_balance_wallet_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: StatsCard(label: 'Terserap', value: 'Rp 0', icon: Icons.trending_up_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: StatsCard(label: 'Kategori rawan', value: '-', icon: Icons.warning_rounded, color: BudgetraColors.warning)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _CategoryBudgetCard(
            label: 'Makan',
            subtitle: 'Konsumsi harian',
            spent: 0,
            total: 0,
            status: 'Belum diatur',
            color: BudgetraColors.primary,
          ),
          const SizedBox(height: 12),
          _CategoryBudgetCard(
            label: 'Transport',
            subtitle: 'Biaya commute',
            spent: 0,
            total: 0,
            status: 'Belum diatur',
            color: BudgetraColors.info,
          ),
          const SizedBox(height: 12),
          _CategoryBudgetCard(
            label: 'Tagihan',
            subtitle: 'Mendekati limit',
            spent: 0,
            total: 0,
            status: 'Belum diatur',
            color: BudgetraColors.warning,
          ),
          const SizedBox(height: 12),
          _CategoryBudgetCard(
            label: 'Belanja',
            subtitle: 'Kebutuhan rumah',
            spent: 0,
            total: 0,
            status: 'Belum diatur',
            color: BudgetraColors.error,
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final double spent;
  final double total;
  final String status;
  final Color color;

  const _CategoryBudgetCard({
    required this.label,
    required this.subtitle,
    required this.spent,
    required this.total,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? spent / total : 0.0;
    final statusColor = pct >= 0.9
        ? BudgetraColors.error
        : pct >= 0.8
            ? BudgetraColors.warning
            : BudgetraColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CategoryIcon(category: label, color: color),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                  ],
                ),
                LabelBadge(text: status, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Rp 0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.03)),
                const SizedBox(width: 8),
                Text('dari Rp 0', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
              ],
            ),
            const SizedBox(height: 8),
            BudgetProgressBar(percentage: pct, color: statusColor),
          ],
        ),
      ),
    );
  }
}
