import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? BudgetraColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: c, size: 18),
            const SizedBox(height: 6),
          ],
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: c,
              letterSpacing: -0.03,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class LabelBadge extends StatelessWidget {
  final String text;
  final Color color;

  const LabelBadge({
    super.key,
    required this.text,
    this.color = BudgetraColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.02,
        ),
      ),
    );
  }
}

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final Color? color;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? BudgetraColors.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percentage.clamp(0, 1),
        backgroundColor: BudgetraColors.lightMuted,
        color: c,
        minHeight: 10,
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String category;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.category,
    this.color,
  });

  IconData _icon() {
    switch (category.toLowerCase()) {
      case 'makan & minum':
      case 'makan':
        return Icons.restaurant_rounded;
      case 'transportasi':
      case 'transport':
        return Icons.directions_car_rounded;
      case 'tagihan':
        return Icons.receipt_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'hiburan':
        return Icons.sports_esports_rounded;
      case 'kesehatan':
        return Icons.favorite_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      case 'kebutuhan rumah':
        return Icons.home_rounded;
      case 'internet & pulsa':
        return Icons.wifi_rounded;
      case 'paket langganan':
        return Icons.subscriptions_rounded;
      case 'asuransi':
        return Icons.health_and_safety_rounded;
      case 'donasi & zakat':
        return Icons.volunteer_activism_rounded;
      case 'pakaian':
        return Icons.checkroom_rounded;
      case 'perawatan diri':
        return Icons.spa_rounded;
      case 'olahraga':
        return Icons.fitness_center_rounded;
      case 'liburan & travel':
        return Icons.flight_rounded;
      case 'hewan peliharaan':
        return Icons.pets_rounded;
      case 'lainnya':
        return Icons.more_horiz_rounded;
      case 'gaji':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'investasi':
        return Icons.trending_up_rounded;
      case 'bonus & thr':
        return Icons.card_giftcard_rounded;
      case 'bisnis':
        return Icons.analytics_rounded;
      case 'hadiah':
        return Icons.redeem_rounded;
      case 'pendapatan lain':
        return Icons.attach_money_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _color() {
    switch (category.toLowerCase()) {
      case 'makan & minum':
      case 'makan':
        return BudgetraColors.primary;
      case 'transportasi':
      case 'transport':
        return BudgetraColors.info;
      case 'tagihan':
        return BudgetraColors.warning;
      case 'belanja':
        return BudgetraColors.error;
      case 'hiburan':
        return const Color(0xFF8B5CF6);
      case 'kesehatan':
        return const Color(0xFFEC4899);
      case 'pendidikan':
        return const Color(0xFF06B6D4);
      case 'kebutuhan rumah':
        return const Color(0xFF14B8A6);
      case 'internet & pulsa':
        return const Color(0xFF0EA5E9);
      case 'paket langganan':
        return const Color(0xFFF43F5E);
      case 'asuransi':
        return const Color(0xFFEC4899);
      case 'donasi & zakat':
        return const Color(0xFFF97316);
      case 'pakaian':
        return const Color(0xFFA855F7);
      case 'perawatan diri':
        return const Color(0xFFF472B6);
      case 'olahraga':
        return const Color(0xFF22C55E);
      case 'liburan & travel':
        return const Color(0xFF06B6D4);
      case 'hewan peliharaan':
        return const Color(0xFFFB923C);
      case 'lainnya':
        return const Color(0xFF94A3B8);
      case 'gaji':
        return BudgetraColors.primary;
      case 'freelance':
        return const Color(0xFFF97316);
      case 'investasi':
        return const Color(0xFF06B6D4);
      case 'bonus & thr':
        return const Color(0xFFEF4444);
      case 'bisnis':
        return const Color(0xFF6366F1);
      case 'hadiah':
        return const Color(0xFFEC4899);
      case 'pendapatan lain':
        return const Color(0xFF94A3B8);
      default:
        return BudgetraColors.primary;
    }
  }

  Color get bgColor => color ?? _color();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_icon(), color: bgColor, size: 20),
    );
  }
}
