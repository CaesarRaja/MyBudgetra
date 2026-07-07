import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/budget_repository.dart';
import '../widgets/stats_card.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _txRepo = TransactionRepository();
  final _budgetRepo = BudgetRepository();
  List<_BudgetItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final categories = await _txRepo.getCategories();
      final expenseCats = categories.where((c) => c.type == 'expense').toList();
      final budgets = await _budgetRepo.getBudgets();
      final realisasi = await _budgetRepo.getRealisasi();

      final budgetMap = {for (final b in budgets) b.categoryId: b.amount};
      final items = expenseCats.map((cat) => _BudgetItem(
        category: cat,
        budget: budgetMap[cat.id] ?? 0,
        spent: realisasi[cat.id] ?? 0,
      )).toList();

      items.sort((a, b) => b.spent.compareTo(a.spent));

      if (mounted) setState(() => _items = items);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setBudget(_BudgetItem item) async {
    final controller = TextEditingController(text: item.budget > 0 ? item.budget.toString() : '');
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Budget ${item.category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nominal budget',
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.replaceAll('.', ''));
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Masukkan nominal valid'), backgroundColor: BudgetraColors.warning),
                );
                return;
              }
              Navigator.pop(ctx, val);
            },
            child: Text(item.budget > 0 ? 'Simpan' : 'Set Budget'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (amount != null && amount > 0) {
      try {
        await _budgetRepo.upsertBudget(item.category.id, amount);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = _items.fold<int>(0, (s, i) => s + i.budget);
    final totalSpent = _items.fold<int>(0, (s, i) => s + i.spent);
    final overallPct = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final remaining = totalBudget - totalSpent;

    String rawanKategori = '-';
    if (_items.any((i) => i.budget > 0 && i.spent >= i.budget * 0.9)) {
      final rawan = _items.where((i) => i.budget > 0 && i.spent >= i.budget * 0.9).length;
      rawanKategori = '$rawan kategori';
    }

    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                Text('Budget per kategori', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('Kontrol budget bulanan', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
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
                                style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(overallPct * 100).round()}% budget telah terpakai',
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
                            child: Column(
                              children: [
                                Text('Sisa total', style: TextStyle(fontSize: 11, color: BudgetraColors.primaryStrong)),
                                Text(
                                  'Rp ${_format(remaining < 0 ? 0 : remaining)}',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: BudgetraColors.primaryStrong),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BudgetProgressBar(percentage: overallPct),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: StatsCard(label: 'Total budget', value: 'Rp ${_format(totalBudget)}', icon: Icons.account_balance_wallet_rounded)),
                          const SizedBox(width: 8),
                          Expanded(child: StatsCard(label: 'Terserap', value: 'Rp ${_format(totalSpent)}', icon: Icons.trending_up_rounded)),
                          const SizedBox(width: 8),
                          Expanded(child: StatsCard(label: 'Kategori rawan', value: rawanKategori, icon: Icons.warning_rounded, color: BudgetraColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ..._items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryBudgetCard(
                    item: item,
                    onTap: () => _setBudget(item),
                  ),
                )),
              ],
            ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _BudgetItem {
  final CategoryModel category;
  final int budget;
  final int spent;

  _BudgetItem({required this.category, required this.budget, required this.spent});
}

class _CategoryBudgetCard extends StatelessWidget {
  final _BudgetItem item;
  final VoidCallback onTap;

  const _CategoryBudgetCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = item.budget > 0 ? item.spent / item.budget : 0.0;
    final statusColor = pct >= 0.9
        ? BudgetraColors.error
        : pct >= 0.8
            ? BudgetraColors.warning
            : BudgetraColors.primary;
    final statusText = item.budget > 0
        ? '${(pct * 100).round()}%'
        : 'Belum diatur';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                      CategoryIcon(category: item.category.name),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.category.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          SizedBox(height: 2),
                          if (item.budget > 0 && item.spent > 0)
                            Text('Rp ${_format(item.spent)} / Rp ${_format(item.budget)}', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                        ],
                      ),
                    ],
                  ),
                  LabelBadge(text: statusText, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              if (item.budget > 0) ...[
                Row(
                  children: [
                    Text('Rp ${_format(item.spent > item.budget ? item.spent : item.spent)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.03)),
                    const SizedBox(width: 8),
                    Text('dari Rp ${_format(item.budget)}', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                  ],
                ),
                const SizedBox(height: 8),
                BudgetProgressBar(percentage: pct, color: statusColor),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Set budget untuk kategori ini', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
