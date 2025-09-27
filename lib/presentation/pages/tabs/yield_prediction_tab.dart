import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';
import '../../../core/utils/chart_utilities.dart';

class YieldPredictionTab extends StatelessWidget {
  final WeatherEntity weather;

  const YieldPredictionTab({super.key, required this.weather});

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
                const Icon(Icons.trending_up, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Yield Potential & Risk Assessment',
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
                  _buildStressFactorsChart(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildYieldPotentialGauge()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStressMetrics()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildYieldFactorsBreakdown(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressFactorsChart() {
    return Container(
      height: 450, // Increased height for better visibility
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
            'Crop Stress Factors Impact on Yield',
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
                          horizontalInterval: 10,
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
                              interval: 10,
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
                        maxY: 110, // Added padding to prevent obstruction at 100%
                        lineBarsData: [
                          _buildHeatStressLine(),
                          _buildWaterStressLine(),
                          _buildOverallStressLine(),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true, // Important for scroll compatibility
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(12), // Increased tooltip padding
                            tooltipMargin: 16, // Added margin around tooltip
                            getTooltipColor: (touchedSpot) => Colors.white.withValues(alpha: 0.95),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                if (spot.x.toInt() < weather.dailyForecast.length) {
                                  final date = DateTime.parse(weather.dailyForecast[spot.x.toInt()].date);
                                  String label = '';
                                  Color color = Colors.black;
                                  
                                  // Determine which line was touched based on color
                                  if (spot.barIndex == 0) {
                                    label = 'Heat Stress';
                                    color = Colors.red;
                                  } else if (spot.barIndex == 1) {
                                    label = 'Water Stress';
                                    color = Colors.blue;
                                  } else if (spot.barIndex == 2) {
                                    label = 'Overall Stress';
                                    color = Colors.purple;
                                  }
                                  
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\n$label: ${spot.y.toStringAsFixed(1)}%',
                                    TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13, // Slightly larger text
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
                                  color: Colors.white.withValues(alpha: 0.8),
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
          _buildStressLegend(),
        ],
      ),
    );
  }

  Widget _buildStressLegend() {
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
              _buildLegendItem(Colors.red, 'Heat Stress'),
              _buildLegendItem(Colors.blue, 'Water Stress'),
              _buildLegendItem(Colors.purple, 'Overall Stress'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Higher stress levels reduce yield potential • Monitor conditions closely',
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

  Widget _buildYieldPotentialGauge() {
    double yieldPotential = AgriculturalCalculations.calculateYieldPotential(weather.dailyForecast);
    
    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ChartUtilities.getStatusColor(yieldPotential).withValues(alpha: 0.8),
            ChartUtilities.getStatusColor(yieldPotential).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ChartUtilities.getStatusColor(yieldPotential), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Season Yield Potential',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: yieldPotential / 100,
                      strokeWidth: 15,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${yieldPotential.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AgriculturalCalculations.getYieldPotentialLabel(yieldPotential),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressMetrics() {
    final heatStress = _calculateAverageHeatStress();
    final waterStress = _calculateAverageWaterStress();
    
    return Column(
      children: [
        Container(
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.withValues(alpha: 0.8),
                Colors.red.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 1.5),
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
                  const Icon(Icons.thermostat, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Heat Stress Risk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${heatStress.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (heatStress / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withValues(alpha: 0.8),
                Colors.blue.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue, width: 1.5),
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
                  const Icon(Icons.water_drop, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Water Stress Risk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${waterStress.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (waterStress / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYieldFactorsBreakdown() {
    final factors = _calculateYieldFactors();
    
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
              const Icon(Icons.analytics, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Yield Impact Factors Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...factors.entries.map((factor) {
            Color impactColor = factor.value > 0 ? Colors.green : Colors.red;
            IconData impactIcon = factor.value > 0 ? Icons.trending_up : Icons.trending_down;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    impactColor.withValues(alpha: 0.3),
                    impactColor.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: impactColor.withValues(alpha: 0.6),
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
                      color: impactColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: impactColor.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(impactIcon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      factor.key,
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
                      color: impactColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: impactColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${factor.value > 0 ? '+' : ''}${factor.value.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  LineChartBarData _buildHeatStressLine() {
    return LineChartBarData(
      spots: _getHeatStressSpots(),
      isCurved: true,
      color: Colors.red,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: Colors.red,
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
            Colors.red.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildWaterStressLine() {
    return LineChartBarData(
      spots: _getWaterStressSpots(),
      isCurved: true,
      color: Colors.blue,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: Colors.blue,
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
            Colors.blue.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildOverallStressLine() {
    return LineChartBarData(
      spots: _getOverallStressSpots(),
      isCurved: true,
      color: Colors.purple,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6, // Largest dots for the main line
            color: Colors.purple,
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
            Colors.purple.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getHeatStressSpots() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      double heatStress = AgriculturalCalculations.calculateHeatStress(entry.value.temperatureMax);
      return FlSpot(entry.key.toDouble(), heatStress);
    }).toList();
  }

  List<FlSpot> _getWaterStressSpots() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      double waterStress = AgriculturalCalculations.calculateWaterStress(
        weather.dailyForecast.sublist(0, entry.key + 1)
      );
      return FlSpot(entry.key.toDouble(), waterStress);
    }).toList();
  }

  List<FlSpot> _getOverallStressSpots() {
    final heatStress = _getHeatStressSpots();
    final waterStress = _getWaterStressSpots();
    
    return heatStress.asMap().entries.map((entry) {
      double combinedStress = AgriculturalCalculations.calculateOverallStress(
        entry.value.y, 
        waterStress[entry.key].y
      );
      return FlSpot(entry.key.toDouble(), combinedStress);
    }).toList();
  }

  double _calculateAverageHeatStress() {
    final spots = _getHeatStressSpots();
    if (spots.isEmpty) return 0;
    
    double total = spots.fold(0, (sum, spot) => sum + spot.y);
    return total / spots.length;
  }

  double _calculateAverageWaterStress() {
    final spots = _getWaterStressSpots();
    if (spots.isEmpty) return 0;
    
    double total = spots.fold(0, (sum, spot) => sum + spot.y);
    return total / spots.length;
  }

  Map<String, double> _calculateYieldFactors() {
    final heatStress = _calculateAverageHeatStress();
    final waterStress = _calculateAverageWaterStress();
    final gddAccumulation = AgriculturalCalculations.calculateCumulativeGDD(
      weather.dailyForecast, 10
    );
    final precipitation = weather.dailyForecast
        .take(7)
        .map((f) => f.precipitationSum)
        .fold(0.0, (sum, p) => sum + p);

    return {
      'Temperature Stress': -heatStress * 0.8, // Negative impact
      'Water Availability': waterStress > 50 ? -waterStress * 0.6 : precipitation * 2,
      'Growing Conditions': gddAccumulation > 200 ? 15.0 : gddAccumulation * 0.075,
      'Weather Stability': _calculateWeatherStability(),
    };
  }

  double _calculateWeatherStability() {
    // Calculate temperature variance as a stability indicator
    final temps = weather.dailyForecast.map((f) => f.temperatureMax).toList();
    if (temps.length < 2) return 0.0;
    
    double mean = temps.fold(0.0, (sum, temp) => sum + temp) / temps.length;
    double variance = temps.map((temp) => (temp - mean) * (temp - mean))
        .fold(0.0, (sum, sq) => sum + sq) / temps.length;
    
    // Lower variance = higher stability = positive yield impact
    double stability = (100.0 - (variance * 2)).clamp(0.0, 100.0);
    return (stability - 50.0) * 0.3; // Convert to impact factor
  }
}