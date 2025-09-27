import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';

class CropGrowthTab extends StatelessWidget {
  final WeatherEntity weather;

  const CropGrowthTab({super.key, required this.weather});

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
                const Icon(Icons.eco, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Crop Growth & Development Analysis',
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
                  _buildGrowingDegreeDaysChart(),
                  const SizedBox(height: 16),
                  _buildGrowthMetrics(),
                  const SizedBox(height: 16),
                  _buildCropStagesTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowingDegreeDaysChart() {
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
            'Growing Degree Days (GDD) Accumulation',
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
                          horizontalInterval: 50,
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
                              interval: 50,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}°D',
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
                        maxY: _getMaxGDD() + 100,
                        lineBarsData: [_buildGDDLine()],
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
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)}°D\nCumulative GDD',
                                    TextStyle(
                                      color: Colors.black,
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
          _buildGDDLegend(),
        ],
      ),
    );
  }

  Widget _buildGDDLegend() {
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
              _buildLegendItem(const Color(0xFFFF8F00), 'GDD Accumulation'),
              _buildLegendItem(const Color(0xFF4CAF50), 'Optimal Range'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Base Temperature: 10°C • Higher accumulation = faster crop development',
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

  Widget _buildGrowthMetrics() {
    final currentGDD = AgriculturalCalculations.calculateCumulativeGDD(
      weather.dailyForecast, 10
    );
    final avgStress = _calculateAverageStress();

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
                  const Color(0xFFFF8F00).withValues(alpha: 0.8),
                  const Color(0xFFFFB300).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
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
                        'Accumulated GDD',
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
                  '${currentGDD.toInt()}°D',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Base 10°C',
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
                colors: avgStress < 30 
                  ? [
                      const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    ]
                  : avgStress < 60
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
                color: avgStress < 30 
                  ? const Color(0xFF4CAF50)
                  : avgStress < 60 
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
                    const Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Growth Stress',
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
                  '${(100 - avgStress).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStressLabel(avgStress),
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

  Widget _buildCropStagesTimeline() {
    final currentGDD = AgriculturalCalculations.calculateCumulativeGDD(
      weather.dailyForecast, 10
    );
    final stages = AgriculturalCalculations.predictCropStages(currentGDD);

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
              const Icon(Icons.timeline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Crop Development Stages Forecast',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stages.map((stage) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: stage.isReached 
                    ? [
                        const Color(0xFF2E7D32).withValues(alpha: 0.4),
                        const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      ]
                    : [
                        const Color(0xFF37474F).withValues(alpha: 0.3),
                        const Color(0xFF455A64).withValues(alpha: 0.2),
                      ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stage.isReached 
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withValues(alpha: 0.3),
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
                      shape: BoxShape.circle,
                      color: stage.isReached ? const Color(0xFF4CAF50) : Colors.white.withValues(alpha: 0.3),
                      boxShadow: stage.isReached ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ] : [],
                    ),
                    child: Icon(
                      stage.isReached ? Icons.check : Icons.radio_button_unchecked,
                      color: stage.isReached ? Colors.white : Colors.white70,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.name,
                          style: TextStyle(
                            color: stage.isReached ? Colors.white : Colors.white70,
                            fontWeight: stage.isReached ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stage.requiredGDD.toInt()} GDD required',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!stage.isReached)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF8F00).withValues(alpha: 0.8),
                            const Color(0xFFFFB300).withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFFFB300), width: 1),
                      ),
                      child: Text(
                        '${(stage.requiredGDD - currentGDD).toInt()}°D left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  LineChartBarData _buildGDDLine() {
    return LineChartBarData(
      spots: _getGDDSpots(),
      isCurved: true,
      color: const Color(0xFFFF8F00),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: const Color(0xFFFF8F00),
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
            const Color(0xFFFF8F00).withValues(alpha: 0.3),
            const Color(0xFFFF8F00).withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getGDDSpots() {
    double cumulativeGDD = 0;
    const double baseTemp = 10;
    
    return weather.dailyForecast.asMap().entries.map((entry) {
      double dailyGDD = AgriculturalCalculations.calculateGDD(
        entry.value.temperatureMax, 
        entry.value.temperatureMin, 
        baseTemp
      );
      cumulativeGDD += dailyGDD;
      return FlSpot(entry.key.toDouble(), cumulativeGDD);
    }).toList();
  }

  double _getMaxGDD() {
    final spots = _getGDDSpots();
    return spots.isEmpty ? 100 : spots.last.y;
  }

  double _calculateAverageStress() {
    double totalStress = 0;
    int count = 0;
    
    for (var forecast in weather.dailyForecast) {
      double heatStress = AgriculturalCalculations.calculateHeatStress(forecast.temperatureMax);
      totalStress += heatStress;
      count++;
    }
    
    return count > 0 ? totalStress / count : 0;
  }

  String _getStressLabel(double stress) {
    if (stress < 20) return 'Low Stress';
    if (stress < 40) return 'Moderate Stress';
    if (stress < 60) return 'High Stress';
    return 'Critical Stress';
  }
}