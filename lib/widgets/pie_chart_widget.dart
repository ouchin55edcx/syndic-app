import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, color: const Color.fromARGB(255, 87, 172, 215), title: 'Impayés'),
            PieChartSectionData(value: 60, color: const Color.fromARGB(255, 75, 160, 173), title: 'Payé'),
          ],
        ),
      ),
    );
  }
}
