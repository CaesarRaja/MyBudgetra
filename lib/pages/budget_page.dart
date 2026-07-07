import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/envelope_model.dart';
import '../models/category_model.dart';
import '../repositories/envelope_repository.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/stats_card.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _envRepo = EnvelopeRepository();
  final _txRepo = TransactionRepository();
  List<EnvelopeModel> _envelopes = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _envRepo.getEnvelopes(),
        _txRepo.getCategories(),
      ]);
      if (mounted) {
        setState(() {
          _envelopes = results[0] as List<EnvelopeModel>;
          _categories = results[1] as List<CategoryModel>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final result = await _showFormDialog(null);
    if (result == true) _load();
  }

  Future<void> _edit(EnvelopeModel e) async {
    final result = await _showFormDialog(e);
    if (result == true) _load();
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Amplop'),
        content: const Text('Yakin ingin menghapus amplop ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: BudgetraColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await _envRepo.deleteEnvelope(id);
      _load();
    }
  }

  Future<void> _useManually(EnvelopeModel e) async {
    final ctrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pakai ${e.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(ctrl.text.replaceAll('.', ''));
              if (amount == null || amount <= 0) return;
              await _envRepo.markUsage(e.id!, amount, note: noteCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Pakai'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    noteCtrl.dispose();
    if (result == true) _load();
  }

  Future<bool?> _showFormDialog(EnvelopeModel? existing) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    String? categoryId = existing?.categoryId;
    final expenseCats = _categories.where((c) => c.type == 'expense').toList();

    return showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Amplop' : 'Amplop Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Nama amplop', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Nominal budget', prefixText: 'Rp ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: categoryId,
                  decoration: InputDecoration(
                    labelText: 'Link ke kategori (opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: const Text('Manual (tanpa link)')),
                    ...expenseCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setDialogState(() => categoryId = v),
                ),
                if (categoryId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Realisasi otomatis dari transaksi kategori ini', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final amount = int.tryParse(amountCtrl.text.replaceAll('.', ''));
                if (name.isEmpty || amount == null || amount <= 0) return;
                try {
                  if (isEdit) {
                    await _envRepo.updateEnvelope(existing.id!, name: name, amount: amount, icon: existing.icon, color: existing.color, categoryId: categoryId);
                  } else {
                    await _envRepo.createEnvelope(name, amount, icon: 'wallet', color: '#12B981', categoryId: categoryId);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error));
                  }
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Buat'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = _envelopes.fold<int>(0, (s, e) => s + e.amount);
    final totalSpent = _envelopes.fold<int>(0, (s, e) => s + e.spent);
    final overallPct = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

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
                    Text('Budget', style: Theme.of(context).textTheme.headlineMedium),
                    GestureDetector(
                      onTap: _create,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: BudgetraColors.primary, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${_envelopes.length} amplop aktif', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
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
                              Text('Total Budget', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text('${(overallPct * 100).round()}% terpakai', style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: BudgetraColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Text('Sisa', style: TextStyle(fontSize: 11, color: BudgetraColors.primaryStrong)),
                                Text('Rp ${_format(totalBudget - totalSpent < 0 ? 0 : totalBudget - totalSpent)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: BudgetraColors.primaryStrong)),
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
                          Expanded(child: StatsCard(label: 'Amplop', value: '${_envelopes.length}', icon: Icons.mail_rounded)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_envelopes.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.mail_outline_rounded, size: 48, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('Belum ada amplop budget', style: TextStyle(fontSize: 16, color: BudgetraColors.lightMutedFg)),
                          const SizedBox(height: 8),
                          Text('Tekan + untuk membuat amplop', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  ),
                ..._envelopes.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EnvelopeCard(
                    envelope: e,
                    onTap: () => _edit(e),
                    onDelete: () => _delete(e.id!),
                    onUse: () => _useManually(e),
                  ),
                )),
              ],
            ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _EnvelopeCard extends StatelessWidget {
  final EnvelopeModel envelope;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onUse;
  const _EnvelopeCard({required this.envelope, required this.onTap, required this.onDelete, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(envelope.color);
    final pct = envelope.progress;
    final statusColor = pct >= 0.9 ? BudgetraColors.error : pct >= 0.8 ? BudgetraColors.warning : BudgetraColors.primary;
    final isLinked = envelope.categoryId != null;

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
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_iconData(envelope.icon), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(envelope.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(
                          isLinked ? 'Auto: ${envelope.categoryName ?? ''}' : 'Manual',
                          style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: BudgetraColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.delete_rounded, size: 16, color: BudgetraColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Rp ${_format(envelope.spent)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.03)),
                  const SizedBox(width: 8),
                  Text('dari Rp ${_format(envelope.amount)}', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        BudgetProgressBar(percentage: pct, color: statusColor),
                        const SizedBox(height: 4),
                        Text('Sisa Rp ${_format(envelope.remaining)}', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onUse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: BudgetraColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('Pakai', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: BudgetraColors.primary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return BudgetraColors.primary;
    }
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'wallet': return Icons.wallet_rounded;
      case 'shopping_bag': return Icons.shopping_bag_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'car': return Icons.directions_car_rounded;
      case 'home': return Icons.home_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'school': return Icons.school_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'pets': return Icons.pets_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
