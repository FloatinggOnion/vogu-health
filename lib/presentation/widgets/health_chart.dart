import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vogu_health/models/api_models.dart';

class HealthChart extends StatelessWidget {
  final List<dynamic> data;
  final String title;
  final String valueLabel;
  final String? secondaryValueLabel;
  final Color primaryColor;
  final Color? secondaryColor;
  final bool showSecondaryAxis;
  final double Function(dynamic) getPrimaryValue;
  final double Function(dynamic)? getSecondaryValue;
  final DateTime Function(dynamic) getTimestamp;

  const HealthChart({
    Key? key,
    required this.data,
    required this.title,
    required this.valueLabel,
    this.secondaryValueLabel,
    required this.primaryColor,
    this.secondaryColor,
    this.showSecondaryAxis = false,
    required this.getPrimaryValue,
    this.getSecondaryValue,
    required this.getTimestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort data by timestamp
    final sortedData = List.from(data)
      ..sort((a, b) => getTimestamp(a).compareTo(getTimestamp(b)));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: showSecondaryAxis
                        ? AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          )
                        : AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedData.length) {
                            return const Text('');
                          }
                          final date = getTimestamp(sortedData[value.toInt()]);
                          return Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Primary value line
                    LineChartBarData(
                      spots: _createSpots(sortedData, getPrimaryValue),
                      isCurved: true,
                      color: primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryColor.withOpacity(0.1),
                      ),
                    ),
                    // Secondary value line (if applicable)
                    if (showSecondaryAxis && getSecondaryValue != null)
                      LineChartBarData(
                        spots: _createSpots(sortedData, getSecondaryValue!),
                        isCurved: true,
                        color: secondaryColor ?? Colors.grey,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final data = sortedData[spot.x.toInt()];
                          final date = getTimestamp(data);
                          String tooltipText = '${DateFormat('MM/dd HH:mm').format(date)}\n'
                              '$valueLabel: ${spot.y.toStringAsFixed(1)}';
                          
                          if (showSecondaryAxis && getSecondaryValue != null) {
                            final secondaryValue = getSecondaryValue!(data);
                            tooltipText += '\n$secondaryValueLabel: ${secondaryValue.toStringAsFixed(1)}';
                          }
                          
                          return LineTooltipItem(
                            tooltipText,
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<dynamic> data, double Function(dynamic) getValue) {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), getValue(data[index]));
    });
  }
} 