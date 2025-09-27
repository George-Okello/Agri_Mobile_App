import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/disease_risk_calculator.dart';
import '../../../core/utils/spray_window_calculator.dart';

class DiseaseRiskTab extends StatelessWidget {
  final WeatherEntity weather;

  const DiseaseRiskTab({super.key, required this.weather});

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
                const Icon(Icons.bug_report, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Disease & Pest Risk Analysis',
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
            'Fungal Disease Risk Index',
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
                          _buildDiseaseRiskLine(),
                          _buildCriticalRiskLine(),
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
                                  final riskLevel = spot.y > 70 ? 'HIGH RISK' : spot.y > 50 ? 'MODERATE' : 'LOW RISK';
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)}%\n$riskLevel',
                                    TextStyle(
                                      color: spot.y > 70 ? Colors.red : spot.y > 50 ? Colors.orange : Colors.green,
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
          _buildRiskLegend(),
        ],
      ),
    );
  }

  Widget _buildRiskLegend() {
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
              _buildLegendItem(Colors.amber, 'Disease Risk'),
              _buildLegendItem(Colors.red, 'Critical Level (70%)'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Risk > 70%: High disease pressure • Monitor crops closely for symptoms',
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

  Widget _buildRiskMetrics() {
    final avgRisk = _calculateAverageRisk();
    final highRiskDays = _countHighRiskDays();
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: avgRisk < 30 
                  ? [
                      const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    ]
                  : avgRisk < 60
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
                color: avgRisk < 30 
                  ? const Color(0xFF4CAF50)
                  : avgRisk < 60 
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
                        'Average Risk',
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
                  '${avgRisk.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRiskLabel(avgRisk),
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
                colors: highRiskDays > 3 
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
                color: highRiskDays > 3 ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
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
                        'High Risk Days',
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
                  '$highRiskDays',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Next 7 days (>70%)',
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

  Widget _buildSprayWindowCalendar() {
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
              const Text(
                'Optimal Spray Windows (Next 7 Days)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
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
              statusText = sprayConditions['severity'] == 'high' ? 'AVOID' : 'CAUTION';
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    statusColor.withValues(alpha: 0.3),
                    statusColor.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.6),
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
                      Icon(statusIcon, color: statusColor, size: 20),
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
                          color: statusColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sprayConditions['reason'] ?? 'Good conditions for spraying',
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

  LineChartBarData _buildDiseaseRiskLine() {
    return LineChartBarData(
      spots: _getDiseaseRiskSpots(),
      isCurved: true,
      color: Colors.amber,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5, // Larger dots for better visibility
            color: Colors.amber,
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
            Colors.amber.withValues(alpha: 0.3),
            Colors.amber.withValues(alpha: 0.1),
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
    if (risk < 30) return 'Low Risk';
    if (risk < 50) return 'Moderate Risk';
    if (risk < 70) return 'High Risk';
    return 'Critical Risk';
  }
}