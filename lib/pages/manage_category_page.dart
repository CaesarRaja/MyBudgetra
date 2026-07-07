import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/stats_card.dart';

Future<void> showManageCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ManageCategorySheet(),
  );
}

class _ManageCategorySheet extends StatefulWidget {
  const _ManageCategorySheet();

  @override
  State<_ManageCategorySheet> createState() => _ManageCategorySheetState();
}

class _ManageCategorySheetState extends State<_ManageCategorySheet> {
  final _repo = TransactionRepository();
  List<CategoryModel> _categories = [];
  String _type = 'expense';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await _repo.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<CategoryModel> get _filtered => _categories.where((c) => c.type == _type).toList();

  Future<void> _add() async {
    final result = await _showFormDialog(context, null);
    if (result == true) _load();
  }

  Future<void> _edit(CategoryModel cat) async {
    final result = await _showFormDialog(context, cat);
    if (result == true) _load();
  }

  Future<void> _delete(CategoryModel cat) async {
    final canDelete = !cat.isDefault;
    if (!canDelete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori global tidak bisa dihapus'), backgroundColor: BudgetraColors.warning),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: BudgetraColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await _repo.deleteCategory(cat.id);
      if (mounted) {
        if (ok) {
          _load();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori masih digunakan oleh transaksi'), backgroundColor: BudgetraColors.warning),
          );
        }
      }
    }
  }

  Future<bool?> _showFormDialog(BuildContext context, CategoryModel? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final iconCtrl = TextEditingController(text: existing?.icon ?? 'restaurant');
    final colorCtrl = TextEditingController(text: existing?.color ?? '#12B981');
    String selectedType = existing?.type ?? _type;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: iconCtrl, decoration: InputDecoration(labelText: 'Icon (restaurant, car, dll)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: colorCtrl, decoration: InputDecoration(labelText: 'Warna (#12B981)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == 'expense' ? BudgetraColors.error.withValues(alpha: 0.1) : BudgetraColors.lightMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text('Expense', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selectedType == 'expense' ? BudgetraColors.error : BudgetraColors.lightMutedFg))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == 'income' ? BudgetraColors.primarySoft : BudgetraColors.lightMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text('Income', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selectedType == 'income' ? BudgetraColors.primaryStrong : BudgetraColors.lightMutedFg))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                try {
                  if (isEdit) {
                    await _repo.updateCategory(existing.id, nameCtrl.text.trim(), iconCtrl.text.trim(), colorCtrl.text.trim());
                  } else {
                    await _repo.addCategory(nameCtrl.text.trim(), iconCtrl.text.trim(), colorCtrl.text.trim(), selectedType);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error));
                  }
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: BudgetraColors.lightCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36, height: 4,
              decoration: BoxDecoration(color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kelola Kategori', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close_rounded, color: BudgetraColors.lightMutedFg, size: 22)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'expense'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == 'expense' ? BudgetraColors.error.withValues(alpha: 0.1) : BudgetraColors.lightMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _type == 'expense' ? BudgetraColors.error : BudgetraColors.lightMutedFg))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'income'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == 'income' ? BudgetraColors.primarySoft : BudgetraColors.lightMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _type == 'income' ? BudgetraColors.primaryStrong : BudgetraColors.lightMutedFg))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _loading
              ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
              : Flexible(
                  child: _filtered.isEmpty
                      ? Padding(padding: const EdgeInsets.all(40), child: Text('Belum ada kategori', style: TextStyle(color: BudgetraColors.lightMutedFg)))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final cat = _filtered[i];
                            return ListTile(
                              leading: CategoryIcon(category: cat.name),
                              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: cat.isDefault ? Text('Global', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)) : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _edit(cat),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: BudgetraColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.edit_rounded, size: 16, color: BudgetraColors.primaryStrong),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _delete(cat),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: BudgetraColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.delete_rounded, size: 16, color: BudgetraColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetraColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
