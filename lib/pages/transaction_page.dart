import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';

class TransactionPage extends StatefulWidget {
  final VoidCallback? onTransactionAdded;

  const TransactionPage({super.key, this.onTransactionAdded});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _repo = TransactionRepository();
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;

  final _searchCtrl = TextEditingController();
  String _filterType = 'all';
  late int _filterMonth;
  late int _filterYear;
  String? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filterMonth = now.month;
    _filterYear = now.year;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.getTransactions(limit: 200),
        _repo.getCategories(),
      ]);
      if (mounted) {
        setState(() {
          _transactions = results[0] as List<TransactionModel>;
          _categories = results[1] as List<CategoryModel>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TransactionModel> get _filtered {
    return _transactions.where((t) {
      if (_searchCtrl.text.isNotEmpty &&
          !t.description.toLowerCase().contains(_searchCtrl.text.toLowerCase())) {
        return false;
      }
      if (_filterType == 'expense' && !t.isExpense) return false;
      if (_filterType == 'income' && t.isExpense) return false;
      if (t.date.month != _filterMonth || t.date.year != _filterYear) return false;
      if (_filterCategoryId != null && t.categoryId != _filterCategoryId) return false;
      return true;
    }).toList();
  }

  void _prevMonth() {
    setState(() {
      if (_filterMonth == 1) {
        _filterMonth = 12;
        _filterYear--;
      } else {
        _filterMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_filterMonth == 12) {
        _filterMonth = 1;
        _filterYear++;
      } else {
        _filterMonth++;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    final result = await showAddTransactionSheet(context);
    if (result == true) {
      _load();
      widget.onTransactionAdded?.call();
    }
  }

  Future<void> _editTransaction(TransactionModel t) async {
    final result = await showAddTransactionSheet(context, transaction: t);
    if (result == true) {
      _load();
      widget.onTransactionAdded?.call();
    }
  }

  Future<void> _deleteTransaction(TransactionModel t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus "${t.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: BudgetraColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _repo.deleteTransaction(t.id!);
        _load();
        widget.onTransactionAdded?.call();
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
    final filtered = _filtered;
    final monthLabel = DateFormat('MMMM yyyy', 'id').format(DateTime(_filterYear, _filterMonth));

    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                Text('Transaksi', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  filtered.length == _transactions.length
                      ? '${_transactions.length} transaksi tercatat'
                      : '${filtered.length} dari ${_transactions.length} transaksi',
                  style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: BudgetraColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BudgetraColors.lightBorder.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: BudgetraColors.lightMutedFg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Cari transaksi...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          child: Icon(Icons.close_rounded, size: 18, color: BudgetraColors.lightMutedFg),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _prevMonth,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: BudgetraColors.lightMuted, borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.chevron_left_rounded, size: 16, color: BudgetraColors.lightFg),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(monthLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: BudgetraColors.lightMuted, borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.chevron_right_rounded, size: 16, color: BudgetraColors.lightFg),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: BudgetraColors.lightCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BudgetraColors.lightBorder.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _filterCategoryId,
                            isExpanded: true,
                            isDense: true,
                            hint: Text('Semua kategori', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                            items: [
                              DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(fontSize: 12, color: BudgetraColors.lightFg))),
                              ..._categories.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, style: TextStyle(fontSize: 12, color: BudgetraColors.lightFg)),
                              )),
                            ],
                            onChanged: (v) => setState(() => _filterCategoryId = v),
                          ),
                        ),
                      ),
                    ),
                    if (_filterCategoryId != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filterCategoryId = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: BudgetraColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text('Reset', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BudgetraColors.error)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _FilterChip(label: 'Semua', selected: _filterType == 'all', onTap: () => setState(() => _filterType = 'all')),
                    const SizedBox(width: 6),
                    _FilterChip(label: 'Pemasukan', selected: _filterType == 'income', onTap: () => setState(() => _filterType = 'income')),
                    const SizedBox(width: 6),
                    _FilterChip(label: 'Pengeluaran', selected: _filterType == 'expense', onTap: () => setState(() => _filterType = 'expense')),
                  ],
                ),
                if (filtered.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: filtered.map((t) => Column(
                          children: [
                            Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: BudgetraColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
                              ),
                              confirmDismiss: (_) async {
                                await _deleteTransaction(t);
                                return false;
                              },
                              child: GestureDetector(
                                onTap: () => _editTransaction(t),
                                child: TransactionTile(
                                  description: t.description,
                                  category: t.categoryName ?? '',
                                  amount: t.amount.abs(),
                                  isExpense: t.isExpense,
                                  time: _formatDate(t.date),
                                ),
                              ),
                            ),
                            if (t != filtered.last) const Divider(height: 4),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ],
                if (filtered.isEmpty && !_loading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(_transactions.isEmpty ? 'Belum ada transaksi' : 'Tidak ada hasil filter', style: TextStyle(fontSize: 16, color: BudgetraColors.lightMutedFg)),
                            const SizedBox(height: 8),
                            Text(_transactions.isEmpty ? 'Tekan + untuk menambahkan' : 'Coba ubah filter pencarian', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Hari ini';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
      return 'Kemarin';
    }
    return '${d.day}/${d.month}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? BudgetraColors.primaryStrong.withValues(alpha: 0.1) : BudgetraColors.lightMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? BudgetraColors.primaryStrong : Colors.transparent, width: 1.5),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: selected ? BudgetraColors.primaryStrong : BudgetraColors.lightMutedFg,
        )),
      ),
    );
  }
}
