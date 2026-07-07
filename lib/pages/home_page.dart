import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _repo = TransactionRepository();
  Map<String, dynamic> _summary = {};
  List<TransactionModel> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void refresh() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await _repo.getDailySummary();
      final recent = await _repo.getTransactions(limit: 5);
      if (mounted) {
        setState(() {
          _summary = summary;
          _recent = recent;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM', 'id').format(DateTime.now());
    final expense = _summary['todayExpense'] as int? ?? 0;
    final income = _summary['todayIncome'] as int? ?? 0;
    final avg = _summary['monthlyAvg'] as double? ?? 0;
    final diff = avg > 0 ? ((expense / avg - 1) * 100).round() : 0;
    final isBoros = expense > avg;

    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today[0].toUpperCase() + today.substring(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BudgetraColors.lightMutedFg),
                          ),
                          const SizedBox(height: 4),
                          Text('MyBudgetra', style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: BudgetraColors.primarySoft, borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text('MB', style: TextStyle(color: BudgetraColors.primaryStrong, fontWeight: FontWeight.w700, fontSize: 14))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [BudgetraColors.lightFg, BudgetraColors.primaryStrong, BudgetraColors.primary]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: BudgetraColors.lightFg.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ringkasan hari ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 0.05)),
                        const SizedBox(height: 8),
                        Text(
                          expense == 0 ? 'Uang Anda masih aman hari ini' : (isBoros ? 'Pengeluaran membengkak!' : 'Pengeluaran terkendali'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.03),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          expense == 0
                              ? 'Belum ada pengeluaran hari ini.'
                              : 'Pengeluaran hari ini Rp ${_format(expense)}, ${isBoros ? '$diff% di atas' : '${diff.abs()}% di bawah'} rata-rata.',
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _HeroStat(label: 'Saldo aktif', value: 'Rp ${_format(income - expense)}')),
                            const SizedBox(width: 8),
                            Expanded(child: _HeroStat(label: 'Pemasukan', value: 'Rp ${_format(income)}')),
                            const SizedBox(width: 8),
                            Expanded(child: _HeroStat(label: 'Pengeluaran', value: 'Rp ${_format(expense)}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaksi terbaru', style: Theme.of(context).textTheme.titleMedium),
                      if (_recent.isNotEmpty) TextButton(
                        onPressed: () {},
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _recent.isEmpty
                          ? Center(child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('Belum ada transaksi', style: TextStyle(color: BudgetraColors.lightMutedFg)),
                            ))
                          : Column(
                              children: _recent.map((t) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    CategoryIcon(category: t.categoryName ?? 'Umum'),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                                          Text(t.categoryName ?? 'Umum', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${t.isExpense ? '-' : '+'} Rp ${_format(t.amount.abs())}',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.isExpense ? BudgetraColors.lightFg : BudgetraColors.primary),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white, letterSpacing: -0.04)),
        ],
      ),
    );
  }
}
