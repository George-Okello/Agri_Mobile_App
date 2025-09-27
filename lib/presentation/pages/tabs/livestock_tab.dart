import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';

class LivestockTab extends StatelessWidget {
  final WeatherEntity weather;

  const LivestockTab({super.key, required this.weather});

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
                const Icon(Icons.pets, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Livestock Comfort & Management',
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
            'Temperature Humidity Index (THI)',
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
                          horizontalInterval: 5,
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
                              interval: 5,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
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
                        minY: 45, // Adjusted to provide padding
                        maxY: 90, // Adjusted to provide padding
                        lineBarsData: [
                          _buildTHILine(),
                          _buildTHICriticalLine(),
                          _buildTHISevereLine(),
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
                                  final stressLevel = spot.y > 78 ? 'SEVERE STRESS' : 
                                                     spot.y > 72 ? 'HEAT STRESS' : 
                                                     spot.y < 60 ? 'COLD STRESS' : 'COMFORTABLE';
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\nTHI: ${spot.y.toStringAsFixed(1)}\n$stressLevel',
                                    TextStyle(
                                      color: spot.y > 78 ? Colors.red : 
                                             spot.y > 72 ? Colors.orange : 
                                             spot.y < 60 ? Colors.blue : Colors.green,
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
          _buildTHILegend(),
        ],
      ),
    );
  }

  Widget _buildTHILegend() {
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
              _buildLegendItem(Colors.lightBlue, 'THI Index'),
              _buildLegendItem(Colors.orange, 'Heat Stress (72)'),
              _buildLegendItem(Colors.red, 'Severe (78)'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'THI > 72: Heat stress risk • THI > 78: Severe heat stress • Monitor closely',
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
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildComfortMetrics() {
    final avgTHI = _calculateAverageTHI();
    final stressfulDays = _countStressfulDays();
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getTHIColor(avgTHI).withValues(alpha: 0.8),
                  _getTHIColor(avgTHI).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTHIColor(avgTHI), width: 1.5),
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
                    const Icon(Icons.thermostat, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Average THI',
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
                  avgTHI.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTHILabel(avgTHI),
                  style: const TextStyle(
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
                colors: stressfulDays > 2 
                  ? [
                      const Color(0xFFD32F2F).withValues(alpha: 0.8),
                      const Color(0xFFF44336).withValues(alpha: 0.6),
                    ]
                  : [
                      const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: stressfulDays > 2 ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
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
                    const Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Heat Stress Days',
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
                  '$stressfulDays',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Next 7 days (THI>72)',
                  style: TextStyle(
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

  Widget _buildLivestockRecommendations() {
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
              const Expanded( // Fixed: Wrap text in Expanded to prevent overflow
                child: Text(
                  'Livestock Management Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis, // Fixed: Add ellipsis for very small screens
                  maxLines: 2, // Fixed: Allow wrapping to 2 lines if needed
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weather.dailyForecast.take(5).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final recommendations = _getLivestockRecommendations(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    recommendations['color'].withValues(alpha: 0.3),
                    recommendations['color'].withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: recommendations['color'].withValues(alpha: 0.6),
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
                        recommendations['icon'],
                        color: recommendations['color'],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: recommendations['color'].withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recommendations['status'],
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
                    recommendations['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
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

  LineChartBarData _buildTHILine() {
    return LineChartBarData(
      spots: _getTHISpots(),
      isCurved: true,
      color: Colors.lightBlue,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: Colors.lightBlue,
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
            Colors.lightBlue.withValues(alpha: 0.3),
            Colors.lightBlue.withValues(alpha: 0.1),
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
      color: Colors.orange,
      barWidth: 2,
      dashArray: [5, 5],
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  LineChartBarData _buildTHISevereLine() {
    return LineChartBarData(
      spots: List.generate(weather.dailyForecast.length, (index) => 
        FlSpot(index.toDouble(), 78)), // Severe THI level for cattle
      isCurved: false,
      color: Colors.red,
      barWidth: 2,
      dashArray: [3, 3],
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
        'text': 'Severe heat stress risk - Provide cooling systems, extra shade, and increase water access. Consider adjusting feeding times to cooler periods. Monitor animals closely.',
        'status': 'CRITICAL',
        'color': Colors.red,
        'icon': Icons.dangerous,
      };
    } else if (thi > 72) {
      return {
        'text': 'Heat stress risk - Ensure adequate shade and ventilation. Increase water availability and monitor animals for signs of distress. Avoid moving livestock during peak heat.',
        'status': 'WARNING',
        'color': Colors.orange,
        'icon': Icons.warning,
      };
    } else if (forecast.temperatureMin < 0) {
      return {
        'text': 'Cold weather protection - Provide windbreaks, extra bedding, and check water systems for freezing. Increase feed energy content for warmth.',
        'status': 'COLD',
        'color': Colors.blue,
        'icon': Icons.ac_unit,
      };
    } else if (forecast.precipitationSum > 10) {
      return {
        'text': 'Heavy rain expected - Ensure dry shelter areas and proper drainage. Check feed storage for moisture and maintain hoof health protocols.',
        'status': 'WET',
        'color': Colors.lightBlue,
        'icon': Icons.umbrella,
      };
    } else {
      return {
        'text': 'Comfortable conditions for livestock. Normal management practices apply. Good opportunity for routine health checks and maintenance.',
        'status': 'GOOD',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }
  }
}