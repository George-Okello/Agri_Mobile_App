import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';
import '../../../core/utils/disease_risk_calculator.dart';
import '../../../core/utils/spray_window_calculator.dart';
import '../../../core/utils/chart_utilities.dart';

class DiseaseRiskTab extends StatelessWidget {
  final WeatherEntity weather;

  const DiseaseRiskTab({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ChartUtilities.buildGraphTitle(Icons.bug_report, 'Disease & Pest Risk Analysis'),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDiseaseRiskChart(),
                  const SizedBox(height: 16),
                  _buildRiskMetrics(),
                  const SizedBox(height: 16),
                  _buildSprayWindowCalendar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRiskChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        children: [
          const Text(
            'Fungal Disease Risk Index',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                gridData: ChartUtilities.buildGridData(10),
                titlesData: ChartUtilities.buildBasicTitles(weather.dailyForecast, '%'),
                borderData: ChartUtilities.buildBorderData(),
                minX: 0,
                maxX: (weather.dailyForecast.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  _buildDiseaseRiskLine(),
                  _buildCriticalRiskLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMetrics() {
    final avgRisk = _calculateAverageRisk();
    final highRiskDays = _countHighRiskDays();
    
    return Row(
      children: [
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Average Risk',
            value: '${avgRisk.toInt()}%',
            icon: Icons.assessment,
            color: ChartUtilities.getStatusColor(100 - avgRisk),
            subtitle: _getRiskLabel(avgRisk),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'High Risk Days',
            value: '$highRiskDays',
            icon: Icons.warning,
            color: highRiskDays > 3 ? Colors.red : Colors.green,
            subtitle: 'Next 7 days',
          ),
        ),
      ],
    );
  }

  Widget _buildSprayWindowCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimal Spray Windows (Next 7 Days)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(7).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final sprayConditions = SprayWindowCalculator.getSprayConditions(forecast);
            
            Color statusColor = Colors.green;
            IconData statusIcon = Icons.check_circle;
            String statusText = 'OPTIMAL';
            
            if (!sprayConditions['suitable']) {
              statusColor = sprayConditions['severity'] == 'high' ? Colors.red : Colors.orange;
              statusIcon = sprayConditions['severity'] == 'high' ? Icons.cancel : Icons.warning;
              statusText = 'AVOID';
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ChartUtilities.buildStatusCard(
                title: DateFormat('EEE, MMM d').format(date),
                status: statusText,
                statusColor: statusColor,
                statusIcon: statusIcon,
                description: sprayConditions['reason'],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  LineChartBarData _buildDiseaseRiskLine() {
    return LineChartBarData(
      spots: _getDiseaseRiskSpots(),
      isCurved: true,
      color: Colors.amber,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.3),
            Colors.amber.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildCriticalRiskLine() {
    return LineChartBarData(
      spots: List.generate(weather.dailyForecast.length, (index) => 
        FlSpot(index.toDouble(), 70)), // Critical risk level at 70%
      isCurved: false,
      color: Colors.red,
      barWidth: 2,
      dashArray: [5, 5],
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  List<FlSpot> _getDiseaseRiskSpots() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      double risk = DiseaseRiskCalculator.calculateFungalRisk(entry.value);
      return FlSpot(entry.key.toDouble(), risk);
    }).toList();
  }

  double _calculateAverageRisk() {
    final risks = _getDiseaseRiskSpots();
    if (risks.isEmpty) return 0;
    
    double total = risks.fold(0, (sum, spot) => sum + spot.y);
    return total / risks.length;
  }

  int _countHighRiskDays() {
    final risks = _getDiseaseRiskSpots();
    return risks.take(7).where((spot) => spot.y > 70).length;
  }

  String _getRiskLabel(double risk) {
    if (risk < 30) return 'Low';
    if (risk < 50) return 'Moderate';
    if (risk < 70) return 'High';
    return 'Critical';
  }
}