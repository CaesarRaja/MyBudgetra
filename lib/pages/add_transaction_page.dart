import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/supabase.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/stats_card.dart';
import 'manage_category_page.dart';

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
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  String? _selectedCategoryId;

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
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repo.getCategories();
      setState(() {
        _categories = cats;
        _applyFilter();
        if (_isEdit && widget.transaction!.categoryId != null) {
          _selectedCategoryId = widget.transaction!.categoryId;
        }
      });
    } catch (_) {}
  }

  void _applyFilter() {
    _filteredCategories = _categories.where((c) => c.type == _type).toList();
    if (_selectedCategoryId != null && !_filteredCategories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }
  }

  void _switchType(String type) {
    setState(() {
      _type = type;
      _applyFilter();
      if (_filteredCategories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _filteredCategories.first.id;
      }
    });
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty || _descController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi nominal, kategori, dan deskripsi'), backgroundColor: BudgetraColors.warning),
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
            categoryId: _selectedCategoryId,
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
            categoryId: _selectedCategoryId,
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
                  Row(
                    children: [
                      Text('Pilih kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BudgetraColors.lightMutedFg)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await showManageCategorySheet(context);
                          _loadCategories();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: BudgetraColors.lightMuted, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.settings_rounded, size: 16, color: BudgetraColors.lightMutedFg),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (ctx, i) {
                        final cat = _filteredCategories[i];
                        final selected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? BudgetraColors.primary.withValues(alpha: 0.1)
                                  : BudgetraColors.lightSurfaceLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? BudgetraColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CategoryIcon(category: cat.name),
                                const SizedBox(height: 4),
                                Text(
                                  cat.name.length > 7 ? '${cat.name.substring(0, 6)}.' : cat.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: selected ? BudgetraColors.primary : BudgetraColors.lightFg,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
