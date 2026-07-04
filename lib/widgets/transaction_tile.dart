import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'stats_card.dart';

class TransactionTile extends StatelessWidget {
  final String description;
  final String category;
  final int amount;
  final bool isExpense;
  final String time;
  final bool isAutoDetected;

  const TransactionTile({
    super.key,
    required this.description,
    required this.category,
    required this.amount,
    this.isExpense = true,
    required this.time,
    this.isAutoDetected = false,
  });

  @override
  Widget build(BuildContext context) {
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? BudgetraColors.lightFg : BudgetraColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CategoryIcon(category: category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: BudgetraColors.lightMutedFg,
                      ),
                    ),
                    Text(' \u2022 ', style: TextStyle(color: BudgetraColors.lightMutedFg)),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: BudgetraColors.lightMutedFg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign Rp ${_formatAmount(amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: color,
                ),
              ),
              if (isAutoDetected)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: LabelBadge(
                    text: 'Auto',
                    color: BudgetraColors.success,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
