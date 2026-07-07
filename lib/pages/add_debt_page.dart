import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/supabase.dart';
import '../models/debt_model.dart';
import '../repositories/debt_repository.dart';

Future<bool?> showAddDebtSheet(BuildContext context, {DebtModel? debt}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddDebtSheet(debt: debt),
  );
}

class _AddDebtSheet extends StatefulWidget {
  final DebtModel? debt;
  const _AddDebtSheet({this.debt});

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _repo = DebtRepository();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  bool get _isEdit => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.debt!;
      _nameController.text = d.debtorName;
      _amountController.text = d.amount.toString();
      _descController.text = d.description ?? '';
      _selectedDate = d.dueDate;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi nama dan nominal'), backgroundColor: BudgetraColors.warning),
      );
      return;
    }

    setState(() => _loading = true);
    bool navigated = false;
    try {
      final user = SupabaseConfig.client.auth.currentUser!;
      final amount = int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

      if (_isEdit) {
        final d = widget.debt!;
        await _repo.updateDebt(
          DebtModel(
            id: d.id,
            userId: user.id,
            debtorName: _nameController.text.trim(),
            amount: amount,
            description: _descController.text.trim(),
            dueDate: _selectedDate,
            status: d.status,
            reminderSent: d.reminderSent,
          ),
        );
      } else {
        await _repo.addDebt(
          DebtModel(
            userId: user.id,
            debtorName: _nameController.text.trim(),
            amount: amount,
            description: _descController.text.trim(),
            dueDate: _selectedDate,
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
        navigated = true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error),
        );
      }
    }
    if (!navigated && mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
              child: Column(
                children: [
                  Text(
                    _isEdit ? 'Edit Piutang' : 'Tambah Piutang',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Peminjam',
                      hintText: 'Contoh: Rina Pratiwi',
                      prefixIcon: const Icon(Icons.person_rounded),
                      filled: true,
                      fillColor: BudgetraColors.lightSurfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.w600),
                      hintText: '0',
                      prefixIcon: const Icon(Icons.money_rounded),
                      filled: true,
                      fillColor: BudgetraColors.lightSurfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Jatuh Tempo',
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                          filled: true,
                          fillColor: BudgetraColors.lightSurfaceLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: TextEditingController(
                          text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan (opsional)',
                      hintText: 'Misal: pinjaman pribadi',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      filled: true,
                      fillColor: BudgetraColors.lightSurfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
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
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Piutang',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
