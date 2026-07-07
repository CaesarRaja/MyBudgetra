import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../repositories/transaction_repository.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  final _repo = TransactionRepository();
  bool _loading = true;

  Map<String, dynamic> _monthly = {};
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _weekly = [];
  List<Map<String, dynamic>> _categoryExpense = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void refresh() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.getMonthlyReport(),
        _repo.getMonthlyHistory(),
        _repo.getWeeklyExpense(),
        _repo.getExpenseByCategory(),
      ]);
      if (mounted) {
        setState(() {
          _monthly = results[0] as Map<String, dynamic>;
          _history = results[1] as List<Map<String, dynamic>>;
          _weekly = results[2] as List<Map<String, dynamic>>;
          _categoryExpense = results[3] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = _monthly['income'] as int? ?? 0;
    final expense = _monthly['expense'] as int? ?? 0;
    final balance = _monthly['balance'] as int? ?? 0;
    final savingsRate = _monthly['savingsRate'] as int? ?? 0;
    final topCat = _monthly['topCategory'] as String? ?? '-';
    final topCatPct = _monthly['topCategoryPct'] as int? ?? 0;
    final frugalDay = _monthly['frugalDay'] as String? ?? '-';
    final frugalAmount = _monthly['frugalAmount'] as int? ?? 0;
    final hasData = income > 0 || expense > 0;

    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Text('Laporan keuangan', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Visualisasi mingguan & bulanan', style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg)),
                  const SizedBox(height: 20),
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
                        Text('Ringkasan bulan ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 0.05)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _HeroStat(label: 'Pemasukan', value: 'Rp ${_format(income)}')),
                            const SizedBox(width: 8),
                            Expanded(child: _HeroStat(label: 'Pengeluaran', value: 'Rp ${_format(expense)}')),
                            const SizedBox(width: 8),
                            Expanded(child: _HeroStat(label: 'Saldo', value: 'Rp ${_format(balance)}', negative: balance < 0)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              hasData
                                  ? savingsRate >= 20
                                      ? 'Anda hemat bulan ini! 🎉'
                                      : savingsRate > 0
                                          ? 'Mulai menabung lebih banyak.'
                                          : 'Pengeluaran melebihi pemasukan.'
                                  : 'Belum ada data bulan ini.',
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ChartCard(
                    title: 'Distribusi',
                    subtitle: hasData ? '${_categoryExpense.length} kategori' : '-',
                    icon: Icons.pie_chart_rounded,
                    height: 280,
                    child: hasData ? Column(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: _pieSections(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        _buildLegend(),
                      ],
                    ) : Center(child: Text('Belum ada data', style: TextStyle(color: BudgetraColors.lightMutedFg))),
                  ),
                  const SizedBox(height: 20),
                  _ChartCard(
                    title: 'Tren 7 hari',
                    subtitle: 'Mingguan',
                    icon: Icons.show_chart_rounded,
                    height: 260,
                    child: hasData ? LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _lineInterval(),
                          getDrawingHorizontalLine: (value) => FlLine(color: BudgetraColors.lightBorder.withValues(alpha: 0.3), strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (val, _) {
                              if (val == 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(_formatShort(val.toInt()), style: TextStyle(fontSize: 9, color: BudgetraColors.lightMutedFg)),
                              );
                            },
                          )),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (val, _) {
                              final i = val.toInt();
                              if (i < 0 || i >= _weekly.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(_weekly[i]['label'] as String, style: TextStyle(fontSize: 10, color: BudgetraColors.lightMutedFg)),
                              );
                            },
                          )),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                              return LineTooltipItem(
                                'Rp ${_format(spot.y.toInt())}',
                                TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _lineSpots(),
                            isCurved: true,
                            color: BudgetraColors.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: true, getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2, strokeColor: BudgetraColors.primary)),
                            belowBarData: BarAreaData(show: true, color: BudgetraColors.primarySoft),
                          ),
                        ],
                      ),
                    ) : Center(child: Text('Belum ada data', style: TextStyle(color: BudgetraColors.lightMutedFg))),
                  ),
                  const SizedBox(height: 20),
                  _ChartCard(
                    title: 'Arus bulanan',
                    subtitle: 'Pemasukan vs Pengeluaran',
                    icon: Icons.bar_chart_rounded,
                    height: 220,
                    child: hasData ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _barMaxY(),
                        barGroups: _barGroups(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final i = val.toInt();
                              if (i < 0 || i >= _history.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(_history[i]['label'] as String, style: TextStyle(fontSize: 10, color: BudgetraColors.lightMutedFg)),
                              );
                            },
                          )),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _barInterval(),
                          getDrawingHorizontalLine: (value) => FlLine(color: BudgetraColors.lightBorder.withValues(alpha: 0.3), strokeWidth: 1),
                        ),
                      ),
                    ) : Center(child: Text('Belum ada data', style: TextStyle(color: BudgetraColors.lightMutedFg))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _MiniCard(
                        label: 'Kategori terbesar',
                        value: topCat,
                        sub: hasData ? '$topCatPct% dari pengeluaran' : 'Belum ada data.',
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniCard(
                        label: 'Hari paling hemat',
                        value: frugalDay,
                        sub: hasData ? 'Rp ${_format(frugalAmount)}' : 'Belum ada data.',
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniCard(
                        label: 'Tabungan',
                        value: hasData ? '$savingsRate%' : '-',
                        sub: hasData ? 'Rp ${_format(balance < 0 ? 0 : balance)}' : 'Belum ada data.',
                      )),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _pieSections() {
    if (_categoryExpense.isEmpty) return [];
    final total = _categoryExpense.fold<int>(0, (s, e) => s + (e['amount'] as int));
    if (total == 0) return [];
    final colors = [
      BudgetraColors.primary, BudgetraColors.info, BudgetraColors.warning,
      BudgetraColors.error, const Color(0xFF8B5CF6), BudgetraColors.lightMuted,
    ];
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < _categoryExpense.length && i < 5; i++) {
      final e = _categoryExpense[i];
      final pct = (e['amount'] as int) / total;
      sections.add(PieChartSectionData(
        value: pct * 100,
        color: colors[i % colors.length],
        title: '${(pct * 100).round()}%',
        titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        radius: 45,
      ));
    }
    if (_categoryExpense.length > 5) {
      final others = _categoryExpense.skip(5).fold<int>(0, (s, e) => s + (e['amount'] as int));
      final pct = others / total;
      sections.add(PieChartSectionData(
        value: pct * 100,
        color: BudgetraColors.lightMuted,
        title: '${(pct * 100).round()}%',
        titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
        radius: 45,
      ));
    }
    return sections;
  }

  Widget _buildLegend() {
    if (_categoryExpense.isEmpty) return const SizedBox();
    final total = _categoryExpense.fold<int>(0, (s, e) => s + (e['amount'] as int));
    if (total == 0) return const SizedBox();
    final colors = [
      BudgetraColors.primary, BudgetraColors.info, BudgetraColors.warning,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (int i = 0; i < _categoryExpense.length && i < 3; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(
                '${_categoryExpense[i]['name']} (${((_categoryExpense[i]['amount'] as int) / total * 100).round()}%)',
                style: TextStyle(fontSize: 10, color: BudgetraColors.lightMutedFg),
              ),
            ],
          ),
        if (_categoryExpense.length > 3)
          Text('+${_categoryExpense.length - 3} lain', style: TextStyle(fontSize: 10, color: BudgetraColors.lightMutedFg)),
      ],
    );
  }

  List<FlSpot> _lineSpots() {
    return _weekly.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['amount'] as int).toDouble())).toList();
  }

  double _barMaxY() {
    double max = 0;
    for (final h in _history) {
      final income = (h['income'] as int).toDouble();
      final expense = (h['expense'] as int).toDouble();
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max > 0 ? max * 1.2 : 10;
  }

  double _barInterval() {
    final maxY = _barMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 100) return 20;
    if (maxY <= 1000) return 200;
    if (maxY <= 100000) return 20000;
    if (maxY <= 1000000) return 200000;
    return 500000;
  }

  List<BarChartGroupData> _barGroups() {
    return _history.asMap().entries.map((e) {
      final i = e.key;
      final h = e.value;
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: (h['income'] as int).toDouble(), color: BudgetraColors.primary, width: 12, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: (h['expense'] as int).toDouble(), color: BudgetraColors.error, width: 12, borderRadius: BorderRadius.circular(4)),
      ]);
    }).toList();
  }

  double _lineInterval() {
    double maxVal = 0;
    for (final w in _weekly) {
      final v = (w['amount'] as int).toDouble();
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 1000) return 200;
    if (maxVal <= 10000) return 2000;
    if (maxVal <= 100000) return 20000;
    return 50000;
  }

  String _formatShort(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return n.toString();
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final bool negative;
  const _HeroStat({required this.label, required this.value, this.negative = false});

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
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: negative ? BudgetraColors.error : Colors.white, letterSpacing: -0.04)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double height;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.icon, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                    Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                Icon(icon, color: BudgetraColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(height: height - 60, child: child),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _MiniCard({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
              const Spacer(),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                overflow: TextOverflow.ellipsis, maxLines: 1),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
