// widgets/daurah_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hotmul_quran/model/daurah_graph_report.dart';

class DaurahPieChart extends StatelessWidget {
  final List<DaurahData> daurahList;

  const DaurahPieChart({Key? key, required this.daurahList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: _createSections(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final totalParticipants = daurahList.fold(
      0,
      (sum, item) => sum + item.participants,
    );

    return daurahList.asMap().entries.map((entry) {
      final index = entry.key;
      final daurah = entry.value;
      final percentage = (daurah.participants / totalParticipants) * 100;

      return PieChartSectionData(
        color: _getColor(index),
        value: daurah.participants.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
