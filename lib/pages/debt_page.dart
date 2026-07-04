import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/debt_model.dart';
import '../repositories/debt_repository.dart';
import '../widgets/stats_card.dart';
import 'add_debt_page.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  final _repo = DebtRepository();
  List<DebtModel> _debts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getDebts();
      if (mounted) setState(() => _debts = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _add() async {
    final result = await showAddDebtSheet(context);
    if (result == true) _load();
  }

  Future<void> _edit(DebtModel d) async {
    final result = await showAddDebtSheet(context, debt: d);
    if (result == true) _load();
  }

  Future<void> _payDebt(DebtModel d) async {
    final remaining = d.remainingAmount;
    final controller = TextEditingController();

    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bayar Piutang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sisa piutang: Rp ${_format(remaining)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal bayar',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
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
            child: const Text('Bayar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (amount != null && amount > 0) {
      try {
        await _repo.payDebt(d.id!, amount);
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

  Future<void> _delete(DebtModel d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Piutang'),
        content: Text('Yakin ingin menghapus piutang "${d.debtorName}"?'),
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
        await _repo.deleteDebt(d.id!);
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

  int get _totalAmount => _debts.where((d) => !d.isPaid).fold(0, (s, d) => s + d.remainingAmount);
  int get _overdueCount => _debts.where((d) => d.isOverdue).length;
  int get _dueSoonCount => _debts.where((d) => d.isDueSoon).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Piutang aktif', style: Theme.of(context).textTheme.headlineMedium),
                        Text('Catatan utang orang ke Anda', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: BudgetraColors.primary, borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 22),
                        onPressed: _add,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: StatsCard(label: 'Total piutang', value: 'Rp ${_format(_totalAmount)}', icon: Icons.account_balance_wallet_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: StatsCard(label: 'Jatuh tempo dekat', value: '$_dueSoonCount orang', icon: Icons.schedule_rounded, color: BudgetraColors.warning)),
                    const SizedBox(width: 8),
                    Expanded(child: StatsCard(label: 'Overdue', value: '$_overdueCount orang', icon: Icons.error_outline_rounded, color: BudgetraColors.error)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_overdueCount > 0 || _dueSoonCount > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_overdueCount > 0 ? BudgetraColors.error : BudgetraColors.warning).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (_overdueCount > 0 ? BudgetraColors.error : BudgetraColors.warning).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _overdueCount > 0 ? Icons.warning_amber_rounded : Icons.info_rounded,
                          color: _overdueCount > 0 ? BudgetraColors.error : BudgetraColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _overdueCount > 0
                                    ? '$_overdueCount piutang overdue!'
                                    : '$_dueSoonCount piutang akan jatuh tempo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _overdueCount > 0 ? BudgetraColors.error : BudgetraColors.warning,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _overdueCount > 0
                                    ? 'Segera kirim pengingat.'
                                    : 'Jangan lupa kirim pengingat H-1.',
                                style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                if (_debts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daftar prioritas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BudgetraColors.lightMutedFg)),
                          Text('Urut berdasarkan jatuh tempo', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      LabelBadge(text: '${_debts.length} piutang'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: _debts.map((d) => Column(
                          children: [
                            Dismissible(
                              key: ValueKey(d.id),
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
                                await _delete(d);
                                return false;
                              },
                              child: GestureDetector(
                                onTap: () => _edit(d),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: d.isPaid
                                              ? BudgetraColors.success.withValues(alpha: 0.1)
                                              : d.isOverdue
                                                  ? BudgetraColors.error.withValues(alpha: 0.1)
                                                  : BudgetraColors.warning.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          d.isPaid ? Icons.check_circle_rounded
                                              : d.isOverdue ? Icons.warning_amber_rounded
                                                  : Icons.person_rounded,
                                          color: d.isPaid ? BudgetraColors.success
                                              : d.isOverdue ? BudgetraColors.error
                                                  : BudgetraColors.warning,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(d.debtorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
                                                ),
                                                _StatusBadge(d: d),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (d.description != null && d.description!.isNotEmpty)
                                              Text(d.description!, style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                                            Text(
                                              d.isPaid ? 'Lunas' : 'Jatuh tempo ${DateFormat('d MMMM', 'id').format(d.dueDate)}${d.isOverdue ? ' \u2022 ${d.daysOverdue} hari terlambat' : ''}',
                                              style: TextStyle(fontSize: 12, color: d.isOverdue ? BudgetraColors.error : BudgetraColors.lightMutedFg),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Rp ${_format(d.paidAmount)} / Rp ${_format(d.amount)}', style: TextStyle(
                                            fontWeight: FontWeight.w800, fontSize: 13,
                                            color: d.isPaid ? BudgetraColors.success : BudgetraColors.lightFg,
                                          )),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            width: 100,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: d.progress,
                                                minHeight: 6,
                                                backgroundColor: BudgetraColors.lightMutedFg.withValues(alpha: 0.2),
                                                valueColor: AlwaysStoppedAnimation(d.isPaid ? BudgetraColors.success : BudgetraColors.warning),
                                              ),
                                            ),
                                          ),
                                          if (!d.isPaid && !d.isFullyPaid)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: GestureDetector(
                                                onTap: () => _payDebt(d),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: BudgetraColors.success.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Text('Bayar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BudgetraColors.success)),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (d != _debts.last) const Divider(height: 4),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ],
                if (_debts.isEmpty && !_loading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.handshake_rounded, size: 48, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('Belum ada catatan piutang', style: TextStyle(fontSize: 16, color: BudgetraColors.lightMutedFg)),
                            const SizedBox(height: 8),
                            Text('Tekan + untuk menambahkan', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _StatusBadge extends StatelessWidget {
  final DebtModel d;
  const _StatusBadge({required this.d});

  @override
  Widget build(BuildContext context) {
    if (d.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: BudgetraColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Text('Lunas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BudgetraColors.success)),
      );
    }
    if (d.isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: BudgetraColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Text('Overdue', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BudgetraColors.error)),
      );
    }
    if (d.isDueSoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: BudgetraColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Text('H-${d.daysOverdue.abs()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BudgetraColors.warning)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: BudgetraColors.primarySoft, borderRadius: BorderRadius.circular(8)),
      child: Text('Aman', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BudgetraColors.primaryStrong)),
    );
  }
}
