import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';
import '../../../core/utils/chart_utilities.dart';

class LivestockTab extends StatelessWidget {
  final WeatherEntity weather;

  const LivestockTab({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ChartUtilities.buildGraphTitle(Icons.pets, 'Livestock Comfort & Management'),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTHIChart(),
                  const SizedBox(height: 16),
                  _buildComfortMetrics(),
                  const SizedBox(height: 16),
                  _buildLivestockRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTHIChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        children: [
          const Text(
            'Temperature Humidity Index (THI)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                gridData: ChartUtilities.buildGridData(5),
                titlesData: ChartUtilities.buildBasicTitles(weather.dailyForecast, ''),
                borderData: ChartUtilities.buildBorderData(),
                minX: 0,
                maxX: (weather.dailyForecast.length - 1).toDouble(),
                minY: 50,
                maxY: 85,
                lineBarsData: [
                  _buildTHILine(),
                  _buildTHICriticalLine(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTHILegend(),
        ],
      ),
    );
  }

  Widget _buildComfortMetrics() {
    final avgTHI = _calculateAverageTHI();
    final stressfulDays = _countStressfulDays();
    
    return Row(
      children: [
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Average THI',
            value: avgTHI.toStringAsFixed(1),
            icon: Icons.thermostat,
            color: _getTHIColor(avgTHI),
            subtitle: _getTHILabel(avgTHI),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Heat Stress Days',
            value: '$stressfulDays',
            icon: Icons.warning,
            color: stressfulDays > 2 ? Colors.red : Colors.green,
            subtitle: 'Next 7 days (THI>72)',
          ),
        ),
      ],
    );
  }

  Widget _buildLivestockRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Livestock Management Recommendations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(5).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final recommendations = _getLivestockRecommendations(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ChartUtilities.buildStatusCard(
                title: DateFormat('EEE, MMM d').format(date),
                status: recommendations['status'],
                statusColor: recommendations['color'],
                statusIcon: recommendations['icon'],
                description: recommendations['text'],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTHILegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ChartUtilities.buildLegendItem(Colors.lightBlue, 'THI Index'),
            ChartUtilities.buildLegendItem(Colors.red, 'Critical Level (72)'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'THI > 72: Heat stress risk for cattle. THI > 78: Severe heat stress.',
          style: TextStyle(fontSize: 11, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  LineChartBarData _buildTHILine() {
    return LineChartBarData(
      spots: _getTHISpots(),
      isCurved: true,
      color: Colors.lightBlue,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            Colors.lightBlue.withOpacity(0.3),
            Colors.lightBlue.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildTHICriticalLine() {
    return LineChartBarData(
      spots: List.generate(weather.dailyForecast.length, (index) => 
        FlSpot(index.toDouble(), 72)), // Critical THI level for cattle
      isCurved: false,
      color: Colors.red,
      barWidth: 2,
      dashArray: [5, 5],
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  List<FlSpot> _getTHISpots() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      // Estimate humidity based on weather conditions
      double estimatedHumidity = 65;
      if (entry.value.precipitationSum > 2) estimatedHumidity = 85;
      if (entry.value.weatherCode == 0) estimatedHumidity = 50;
      
      double avgTemp = (entry.value.temperatureMax + entry.value.temperatureMin) / 2;
      double thi = AgriculturalCalculations.calculateTHI(avgTemp, estimatedHumidity);
      return FlSpot(entry.key.toDouble(), thi);
    }).toList();
  }

  double _calculateAverageTHI() {
    final thiSpots = _getTHISpots();
    if (thiSpots.isEmpty) return 0;
    
    double total = thiSpots.fold(0, (sum, spot) => sum + spot.y);
    return total / thiSpots.length;
  }

  int _countStressfulDays() {
    return _getTHISpots().take(7).where((spot) => spot.y > 72).length;
  }

  Color _getTHIColor(double thi) {
    if (thi > 78) return Colors.red;
    if (thi > 72) return Colors.orange;
    if (thi < 60) return Colors.blue;
    return Colors.green;
  }

  String _getTHILabel(double thi) {
    if (thi > 78) return 'Severe Stress';
    if (thi > 72) return 'Heat Stress';
    if (thi < 60) return 'Cold Stress';
    return 'Comfortable';
  }

  Map<String, dynamic> _getLivestockRecommendations(DailyForecast forecast) {
    double avgTemp = (forecast.temperatureMax + forecast.temperatureMin) / 2;
    double estimatedHumidity = 65;
    if (forecast.precipitationSum > 2) estimatedHumidity = 85;
    if (forecast.weatherCode == 0) estimatedHumidity = 50;
    
    double thi = AgriculturalCalculations.calculateTHI(avgTemp, estimatedHumidity);
    
    if (thi > 78) {
      return {
        'text': 'Severe heat stress risk - Provide cooling systems, extra shade, and increase water access. Consider adjusting feeding times.',
        'status': 'CRITICAL',
        'color': Colors.red,
        'icon': Icons.dangerous,
      };
    } else if (thi > 72) {
      return {
        'text': 'Heat stress risk - Ensure adequate shade and ventilation. Monitor animals closely for signs of distress.',
        'status': 'WARNING',
        'color': Colors.orange,
        'icon': Icons.warning,
      };
    } else if (forecast.temperatureMin < 0) {
      return {
        'text': 'Cold weather protection - Provide windbreaks, extra bedding, and check water systems for freezing.',
        'status': 'COLD',
        'color': Colors.blue,
        'icon': Icons.ac_unit,
      };
    } else if (forecast.precipitationSum > 10) {
      return {
        'text': 'Heavy rain expected - Ensure dry shelter areas and proper drainage. Check feed storage.',
        'status': 'WET',
        'color': Colors.lightBlue,
        'icon': Icons.umbrella,
      };
    } else {
      return {
        'text': 'Comfortable conditions for livestock. Normal management practices apply.',
        'status': 'GOOD',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }
  }
}