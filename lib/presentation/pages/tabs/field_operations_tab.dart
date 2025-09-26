import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/field_operations_calculator.dart';
import '../../../core/utils/chart_utilities.dart';

class FieldOperationsTab extends StatelessWidget {
  final WeatherEntity weather;

  const FieldOperationsTab({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ChartUtilities.buildGraphTitle(Icons.agriculture, 'Smart Field Operations Planning'),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFieldConditionsChart(),
                  const SizedBox(height: 16),
                  _buildOperationalMetrics(),
                  const SizedBox(height: 16),
                  _buildDailyOperationsSchedule(),
                  const SizedBox(height: 16),
                  _buildEquipmentReadiness(),
                  const SizedBox(height: 16),
                  _buildOptimalTimingRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldConditionsChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        children: [
          const Text(
            'Field Working Conditions Index',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                gridData: ChartUtilities.buildGridData(20),
                titlesData: ChartUtilities.buildBasicTitles(weather.dailyForecast, '%'),
                borderData: ChartUtilities.buildBorderData(),
                minX: 0,
                maxX: (weather.dailyForecast.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  _buildFieldConditionsLine(),
                  _buildOptimalThresholdLine(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildConditionsLegend(),
        ],
      ),
    );
  }

  Widget _buildOperationalMetrics() {
    final workableDays = _countWorkableDays();
    final avgConditions = _calculateAverageConditions();
    
    return Row(
      children: [
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Workable Days',
            value: '$workableDays',
            icon: Icons.calendar_today,
            color: workableDays >= 5 ? Colors.green : workableDays >= 3 ? Colors.orange : Colors.red,
            subtitle: 'Next 7 days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Avg Conditions',
            value: '${avgConditions.toInt()}%',
            icon: Icons.assessment,
            color: ChartUtilities.getStatusColor(avgConditions),
            subtitle: _getConditionsLabel(avgConditions),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOperationsSchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Field Operations Recommendations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(7).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final operations = _getOperationsRecommendations(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: operations['color'].withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: operations['color'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        operations['icon'],
                        color: operations['color'],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: operations['color'].withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          operations['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    operations['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  if (operations['operations'] != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (operations['operations'] as List<String>)
                          .map((op) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  op,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEquipmentReadiness() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipment Operation Suitability',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(3).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final equipment = FieldOperationsCalculator.getEquipmentRecommendations(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, MMM d').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEquipmentStatus('Tractors', equipment['tractors']!.first, 
                            _getEquipmentColor(equipment['tractors']!.first)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEquipmentStatus('Sprayers', equipment['sprayers']!.first,
                            _getEquipmentColor(equipment['sprayers']!.first)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEquipmentStatus('Harvesters', equipment['harvesters']!.first,
                            _getEquipmentColor(equipment['harvesters']!.first)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEquipmentStatus('Planters', equipment['planters']!.first,
                            _getEquipmentColor(equipment['planters']!.first)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOptimalTimingRecommendations() {
    final timing = FieldOperationsCalculator.getTimingRecommendations(weather.dailyForecast);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimal Operation Timing (Next 7 Days)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...timing.entries.map((entry) {
            IconData icon = Icons.schedule;
            Color color = Colors.green;
            
            switch (entry.key) {
              case 'spray':
                icon = Icons.water_drop;
                break;
              case 'harvest':
                icon = Icons.agriculture;
                color = Colors.orange;
                break;
              case 'tillage':
                icon = Icons.landscape;
                color = Colors.brown;
                break;
            }
            
            if (entry.value == 'No suitable days') {
              color = Colors.red;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${entry.key.toUpperCase()} Operations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEquipmentStatus(String equipment, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            equipment,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChartUtilities.buildLegendItem(Colors.green, 'Field Conditions'),
        ChartUtilities.buildLegendItem(Colors.orange, 'Optimal Threshold (70%)'),
      ],
    );
  }

  LineChartBarData _buildFieldConditionsLine() {
    return LineChartBarData(
      spots: _getFieldConditionsSpots(),
      isCurved: true,
      color: Colors.green,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.green.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildOptimalThresholdLine() {
    return LineChartBarData(
      spots: List.generate(weather.dailyForecast.length, (index) => 
        FlSpot(index.toDouble(), 70)), // Optimal threshold at 70%
      isCurved: false,
      color: Colors.orange,
      barWidth: 2,
      dashArray: [5, 5],
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  List<FlSpot> _getFieldConditionsSpots() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      double suitability = FieldOperationsCalculator.calculateOperationsSuitability(entry.value);
      return FlSpot(entry.key.toDouble(), suitability);
    }).toList();
  }

  double _calculateAverageConditions() {
    final spots = _getFieldConditionsSpots();
    if (spots.isEmpty) return 0;
    
    double total = spots.fold(0, (sum, spot) => sum + spot.y);
    return total / spots.length;
  }

  int _countWorkableDays() {
    return _getFieldConditionsSpots()
        .take(7)
        .where((spot) => spot.y >= 70)
        .length;
  }

  String _getConditionsLabel(double conditions) {
    if (conditions >= 80) return 'Excellent';
    if (conditions >= 70) return 'Good';
    if (conditions >= 50) return 'Fair';
    if (conditions >= 30) return 'Poor';
    return 'Very Poor';
  }

  Map<String, dynamic> _getOperationsRecommendations(DailyForecast forecast) {
    double suitability = FieldOperationsCalculator.calculateOperationsSuitability(forecast);
    List<String> operations = FieldOperationsCalculator.getRecommendedOperations(forecast);
    
    Color color;
    IconData icon;
    String status;
    String description;
    
    if (suitability >= 80) {
      color = Colors.green;
      icon = Icons.check_circle;
      status = 'EXCELLENT';
      description = 'Optimal conditions for all field operations';
    } else if (suitability >= 60) {
      color = Colors.lightGreen;
      icon = Icons.check_circle_outline;
      status = 'GOOD';
      description = 'Good conditions for most operations';
    } else if (suitability >= 40) {
      color = Colors.orange;
      icon = Icons.warning;
      status = 'LIMITED';
      description = 'Marginal conditions - limited operations only';
    } else {
      color = Colors.red;
      icon = Icons.cancel;
      status = 'AVOID';
      description = 'Poor conditions - avoid field work';
    }
    
    // Add specific weather warnings
    if (forecast.precipitationSum > 10) {
      description += ' - Heavy rain expected';
    } else if (forecast.windSpeedMax > 20) {
      description += ' - High winds forecast';
    } else if (forecast.temperatureMax < 0) {
      description += ' - Frozen ground conditions';
    }
    
    return {
      'color': color,
      'icon': icon,
      'status': status,
      'description': description,
      'operations': operations.length > 1 ? operations.take(3).toList() : null,
    };
  }

  Color _getEquipmentColor(String status) {
    if (status.contains('Optimal') || status.contains('Excellent') || status.contains('suitable')) {
      return Colors.green;
    } else if (status.contains('Monitor') || status.contains('Acceptable') || status.contains('Good')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}