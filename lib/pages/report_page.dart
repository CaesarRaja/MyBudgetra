import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Laporan keuangan',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Visualisasi mingguan & bulanan',
            style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BudgetraColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BudgetraColors.lightBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insight utama',
                        style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Belum ada data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mulai catat transaksi untuk melihat insight.',
                        style: TextStyle(fontSize: 13, color: BudgetraColors.lightMutedFg),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: BudgetraColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text('Skor ritme', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BudgetraColors.primaryStrong)),
                      const SizedBox(height: 2),
                      Text('-', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: BudgetraColors.primaryStrong)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Distribusi', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                            Icon(Icons.pie_chart_rounded, color: BudgetraColors.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Pie Chart', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(value: 100, color: BudgetraColors.lightMuted.withValues(alpha: 0.5), title: '', radius: 40),
                                  ],
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 50,
                                ),
                              ),
                              Text(
                                '0%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: BudgetraColors.lightMutedFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Distribusi kategori',
                          style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tren 7 hari', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                            Icon(Icons.show_chart_rounded, color: BudgetraColors.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Mingguan', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: BudgetraColors.lightBorder.withValues(alpha: 0.3),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
                                  isCurved: true,
                                  color: BudgetraColors.primary,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: BudgetraColors.primarySoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pengeluaran mingguan',
                          style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
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
                          Text('Arus bulanan', style: TextStyle(fontSize: 12, color: BudgetraColors.lightMutedFg)),
                          Text('Pemasukan vs Pengeluaran', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Icon(Icons.bar_chart_rounded, color: BudgetraColors.primary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barGroups: List.generate(6, (i) {
                          return BarChartGroupData(x: i, barRods: [
                            BarChartRodData(toY: 0, color: BudgetraColors.primary, width: 12, borderRadius: BorderRadius.circular(4)),
                            BarChartRodData(toY: 0, color: BudgetraColors.error, width: 12, borderRadius: BorderRadius.circular(4)),
                          ]);
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: BudgetraColors.lightBorder.withValues(alpha: 0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        barTouchData: BarTouchData(enabled: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori terbesar', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                        const SizedBox(height: 4),
                        const Text('Makan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('0%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.03, color: BudgetraColors.primary)),
                        Text('Belum ada data.', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hari paling hemat', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                        const SizedBox(height: 4),
                        const Text('-', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('Rp 0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.03)),
                        Text('Belum ada data.', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target tabungan', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                        const SizedBox(height: 4),
                        const Text('On track', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('0%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.03)),
                        Text('Belum ada target.', style: TextStyle(fontSize: 11, color: BudgetraColors.lightMutedFg)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
