// widgets/daurah_fl_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hotmul_quran/model/daurah_graph_report.dart';

class DaurahFlChart extends StatelessWidget {
  final List<DaurahData> daurahList;

  const DaurahFlChart({Key? key, required this.daurahList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 8,
            getTooltipItem:
                (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.toY.round().toString(),
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  );
                },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < daurahList.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "D $index",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        barGroups: _createBarGroups(),
        gridData: FlGridData(show: true),
      ),
    );
  }

  double _getMaxY() {
    if (daurahList.isEmpty) return 100;
    return daurahList
        .map((e) => e.participants.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _createBarGroups() {
    return daurahList.asMap().entries.map((entry) {
      final index = entry.key;
      final daurah = entry.value;
      //print(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: daurah.participants.toDouble(),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlue],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY() * 1.2,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
  }
}
