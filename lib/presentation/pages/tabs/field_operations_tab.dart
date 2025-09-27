import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/field_operations_calculator.dart';

class FieldOperationsTab extends StatelessWidget {
  final WeatherEntity weather;

  const FieldOperationsTab({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1B5E20).withValues(alpha: 0.8),
                  const Color(0xFF2E7D32).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF81C784), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Smart Field Operations Planning',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      height: 450, // Increased height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B5E20).withValues(alpha: 0.8),
            const Color(0xFF2E7D32).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Field Working Conditions Index',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive width based on number of data points
                final dataPoints = weather.dailyForecast.length;
                final minChartWidth = constraints.maxWidth;
                // Increased spacing for better touch interaction
                final calculatedWidth = (dataPoints * 80.0).clamp(minChartWidth, dataPoints * 120.0);
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: calculatedWidth,
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10), // Increased padding
                    child: LineChart(
                      LineChartData(
                        backgroundColor: Colors.transparent,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.3),
                            strokeWidth: 0.8,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < weather.dailyForecast.length) {
                                  final date = DateTime.parse(weather.dailyForecast[value.toInt()].date);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        DateFormat('M/d').format(date),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 80, // Increased reserved space
                              interval: 20,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        ),
                        minX: 0,
                        maxX: (weather.dailyForecast.length - 1).toDouble(),
                        minY: 0,
                        maxY: 120, // Added padding to prevent obstruction
                        lineBarsData: [
                          _buildFieldConditionsLine(),
                          _buildOptimalThresholdLine(),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true, // Important for scroll compatibility
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(12), // Increased tooltip padding
                            tooltipMargin: 16, // Added margin around tooltip
                            fitInsideHorizontally: true, // Keep tooltip inside chart bounds
                            fitInsideVertically: true, // Keep tooltip inside chart bounds
                            getTooltipColor: (touchedSpot) => Colors.white.withValues(alpha: 0.98), // Higher opacity for better visibility
                            tooltipBorder: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                if (spot.x.toInt() < weather.dailyForecast.length) {
                                  final date = DateTime.parse(weather.dailyForecast[spot.x.toInt()].date);
                                  final condition = spot.y >= 80 ? 'EXCELLENT' : 
                                                  spot.y >= 70 ? 'GOOD' : 
                                                  spot.y >= 50 ? 'FAIR' : 'POOR';
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)}%\n$condition',
                                    TextStyle(
                                      color: spot.y >= 70 ? Colors.green : spot.y >= 50 ? Colors.orange : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13, // Slightly larger text
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          offset: const Offset(0.5, 0.5),
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                          touchSpotThreshold: 25, // Increased touch sensitivity
                          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                            return spotIndexes.map((spotIndex) {
                              return TouchedSpotIndicatorData(
                                FlLine(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  strokeWidth: 2,
                                  dashArray: [5, 5],
                                ),
                                FlDotData(
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 8, // Larger touch indicator
                                    color: barData.color ?? Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: Colors.white,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildConditionsLegend(),
        ],
      ),
    );
  }

  Widget _buildConditionsLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF263238).withValues(alpha: 0.9),
            const Color(0xFF37474F).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF90A4AE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, 'Field Conditions'),
              _buildLegendItem(Colors.orange, 'Optimal Threshold (70%)'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Conditions > 70%: Good for operations • Consider weather, soil moisture & wind',
            style: TextStyle(fontSize: 10, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalMetrics() {
    final workableDays = _countWorkableDays();
    final avgConditions = _calculateAverageConditions();
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: workableDays >= 5 
                  ? [
                      const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    ]
                  : workableDays >= 3
                    ? [
                        const Color(0xFFFF8F00).withValues(alpha: 0.8),
                        const Color(0xFFFFB300).withValues(alpha: 0.6),
                      ]
                    : [
                        const Color(0xFFD32F2F).withValues(alpha: 0.8),
                        const Color(0xFFF44336).withValues(alpha: 0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: workableDays >= 5 
                  ? const Color(0xFF4CAF50)
                  : workableDays >= 3 
                    ? const Color(0xFFFFB300)
                    : const Color(0xFFF44336),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Workable Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$workableDays',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Next 7 days',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: avgConditions >= 80 
                  ? [
                      const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    ]
                  : avgConditions >= 60
                    ? [
                        const Color(0xFFFF8F00).withValues(alpha: 0.8),
                        const Color(0xFFFFB300).withValues(alpha: 0.6),
                      ]
                    : [
                        const Color(0xFFD32F2F).withValues(alpha: 0.8),
                        const Color(0xFFF44336).withValues(alpha: 0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: avgConditions >= 80 
                  ? const Color(0xFF4CAF50)
                  : avgConditions >= 60 
                    ? const Color(0xFFFFB300)
                    : const Color(0xFFF44336),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assessment, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Avg Conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${avgConditions.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getConditionsLabel(avgConditions),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOperationsSchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B5E20).withValues(alpha: 0.9),
            const Color(0xFF2E7D32).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Daily Field Operations Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(7).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final operations = _getOperationsRecommendations(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    operations['color'].withValues(alpha: 0.3),
                    operations['color'].withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: operations['color'].withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      const SizedBox(width: 12),
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
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: operations['color'].withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          operations['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    operations['description'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  if (operations['operations'] != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (operations['operations'] as List<String>)
                          .map((op) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  op,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptimalTimingRecommendations() {
    final timing = FieldOperationsCalculator.getTimingRecommendations(weather.dailyForecast);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B5E20).withValues(alpha: 0.9),
            const Color(0xFF2E7D32).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Optimal Operation Timing (Next 7 Days)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...timing.entries.map((entry) {
            IconData icon = Icons.schedule;
            Color color = Colors.green;
            
            switch (entry.key) {
              case 'spray':
                icon = Icons.water_drop;
                color = Colors.blue;
                break;
              case 'harvest':
                icon = Icons.agriculture;
                color = Colors.orange;
                break;
              case 'tillage':
                icon = Icons.landscape;
                color = Colors.brown;
                break;
              case 'planting':
                icon = Icons.eco;
                color = Colors.green;
                break;
            }
            
            if (entry.value == 'No suitable days') {
              color = Colors.red;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${entry.key.toUpperCase()} Operations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  LineChartBarData _buildFieldConditionsLine() {
    return LineChartBarData(
      spots: _getFieldConditionsSpots(),
      isCurved: true,
      color: Colors.green,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: Colors.green,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.withValues(alpha: 0.3),
            Colors.green.withValues(alpha: 0.1),
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
      description = 'Optimal conditions for all field operations. Perfect weather window for major tasks.';
    } else if (suitability >= 60) {
      color = Colors.lightGreen;
      icon = Icons.check_circle_outline;
      status = 'GOOD';
      description = 'Good conditions for most operations. Some restrictions may apply for sensitive tasks.';
    } else if (suitability >= 40) {
      color = Colors.orange;
      icon = Icons.warning;
      status = 'LIMITED';
      description = 'Marginal conditions - limited operations only. Monitor weather closely.';
    } else {
      color = Colors.red;
      icon = Icons.cancel;
      status = 'AVOID';
      description = 'Poor conditions - avoid field work. Risk of equipment damage or crop injury.';
    }
    
    // Add specific weather warnings
    if (forecast.precipitationSum > 10) {
      description += ' Heavy rain expected - soil compaction risk.';
    } else if (forecast.windSpeedMax > 20) {
      description += ' High winds forecast - drift risk for spraying.';
    } else if (forecast.temperatureMax < 0) {
      description += ' Frozen ground conditions - equipment limitations.';
    }
    
    return {
      'color': color,
      'icon': icon,
      'status': status,
      'description': description,
      'operations': operations.length > 1 ? operations.take(4).toList() : null,
    };
  }
}