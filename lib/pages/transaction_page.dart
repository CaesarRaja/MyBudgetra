import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/transaction_model.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getTransactions(limit: 50);
      if (mounted) setState(() => _transactions = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
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
    if (result == true) _load();
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
                  '${_transactions.length} transaksi tercatat',
                  style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: BudgetraColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BudgetraColors.lightBorder.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: BudgetraColors.lightMutedFg),
                      const SizedBox(width: 12),
                      Text('Cari transaksi', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
                    ],
                  ),
                ),
                if (_transactions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: _transactions.map((t) => Column(
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
                            if (t != _transactions.last) const Divider(height: 4),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ],
                if (_transactions.isEmpty && !_loading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('Belum ada transaksi', style: TextStyle(fontSize: 16, color: BudgetraColors.lightMutedFg)),
                            const SizedBox(height: 8),
                            Text('Tekan + untuk menambahkan', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.6))),
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
