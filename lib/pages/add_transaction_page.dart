import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/supabase.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

Future<bool?> showAddTransactionSheet(BuildContext context, {TransactionModel? transaction}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTransactionSheet(transaction: transaction),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  final TransactionModel? transaction;
  const _AddTransactionSheet({this.transaction});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _repo = TransactionRepository();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'expense';
  bool _loading = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaction!;
      _amountController.text = t.amount.abs().toString();
      _descController.text = t.description;
      _type = t.type;
    }
  }

  void _switchType(String type) => setState(() => _type = type);

  Future<void> _save() async {
    if (_amountController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi nominal dan deskripsi'), backgroundColor: BudgetraColors.warning),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = SupabaseConfig.client.auth.currentUser!;
      final amount = int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

      if (_isEdit) {
        final t = widget.transaction!;
        await _repo.updateTransaction(
          TransactionModel(
            id: t.id,
            userId: user.id,
            categoryId: t.categoryId,
            amount: _type == 'expense' ? -amount : amount,
            description: _descController.text.trim(),
            type: _type,
            date: t.date,
          ),
        );
      } else {
        await _repo.addTransaction(
          TransactionModel(
            userId: user.id,
            amount: _type == 'expense' ? -amount : amount,
            description: _descController.text.trim(),
            type: _type,
            date: DateTime.now(),
          ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: BudgetraColors.lightCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchType('expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _type == 'expense'
                                  ? BudgetraColors.error.withValues(alpha: 0.1)
                                  : BudgetraColors.lightMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_upward_rounded, size: 16,
                                  color: _type == 'expense' ? BudgetraColors.error : BudgetraColors.lightMutedFg),
                                const SizedBox(width: 6),
                                Text('Pengeluaran', style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13,
                                  color: _type == 'expense' ? BudgetraColors.error : BudgetraColors.lightMutedFg)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchType('income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _type == 'income'
                                  ? BudgetraColors.primarySoft
                                  : BudgetraColors.lightMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_downward_rounded, size: 16,
                                  color: _type == 'income' ? BudgetraColors.primaryStrong : BudgetraColors.lightMutedFg),
                                const SizedBox(width: 6),
                                Text('Pemasukan', style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13,
                                  color: _type == 'income' ? BudgetraColors.primaryStrong : BudgetraColors.lightMutedFg)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: BudgetraColors.lightSurfaceLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text('Rp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: BudgetraColors.lightMutedFg)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.03),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3)),
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_amountController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => _amountController.clear(),
                            child: Icon(Icons.close_rounded, color: BudgetraColors.lightMutedFg, size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan deskripsi...',
                      hintStyle: TextStyle(color: BudgetraColors.lightMutedFg.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: BudgetraColors.lightSurfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetraColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
