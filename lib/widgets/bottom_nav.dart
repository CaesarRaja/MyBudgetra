import 'package:flutter/material.dart';
import '../config/theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: MediaQuery.of(context).padding.bottom + 4),
      decoration: BoxDecoration(
        color: BudgetraColors.lightCard,
        border: Border(
          top: BorderSide(color: BudgetraColors.lightBorder.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Beranda', isActive: currentIndex == 0, onTap: () => onTap(0)),
          _NavItem(icon: Icons.receipt_long_rounded, label: 'Transaksi', isActive: currentIndex == 1, onTap: () => onTap(1)),
          _NavItem(icon: Icons.wallet_rounded, label: 'Budget', isActive: currentIndex == 2, onTap: () => onTap(2)),
          _NavItem(icon: Icons.handshake_rounded, label: 'Piutang', isActive: currentIndex == 3, onTap: () => onTap(3)),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Laporan', isActive: currentIndex == 4, onTap: () => onTap(4)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? BudgetraColors.primary : BudgetraColors.lightMutedFg.withValues(alpha: 0.6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? BudgetraColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
