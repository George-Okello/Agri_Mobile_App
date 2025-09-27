import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';

class IrrigationTab extends StatelessWidget {
  final WeatherEntity weather;

  const IrrigationTab({super.key, required this.weather});

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
                const Icon(Icons.water_drop, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Advanced Irrigation Management',
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
                  _buildWaterBalanceChart(),
                  const SizedBox(height: 16),
                  _buildIrrigationMetrics(),
                  const SizedBox(height: 16),
                  _buildIrrigationSchedule(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterBalanceChart() {
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
            'Daily Water Balance (Input vs Loss)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                    child: BarChart(
                      BarChartData(
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
                              reservedSize: 70, // Increased reserved space
                              interval: 5,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}mm',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                        minY: -25, // Added padding at bottom
                        maxY: 35, // Added padding at top
                        barGroups: _getWaterBalanceBarGroups(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: true, // Important for scroll compatibility
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(12), // Increased tooltip padding
                            tooltipMargin: 16, // Added margin around tooltip
                            fitInsideHorizontally: true, // Keep tooltip inside chart bounds
                            fitInsideVertically: true, // Keep tooltip inside chart bounds
                            getTooltipColor: (group) => Colors.white.withValues(alpha: 0.98), // Higher opacity for better visibility
                            tooltipBorder: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (group.x >= weather.dailyForecast.length) return null;
                              final date = DateTime.parse(weather.dailyForecast[group.x.toInt()].date);
                              final value = rod.toY;
                              return BarTooltipItem(
                                '${DateFormat('MMM d').format(date)}\n${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}mm\n${value > 0 ? 'Surplus' : 'Deficit'}',
                                TextStyle(
                                  color: value > 0 ? Colors.green : Colors.red,
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
                            },
                          ),
                          touchExtraThreshold: EdgeInsets.all(10), // Increased touch area
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildWaterBalanceLegend(),
        ],
      ),
    );
  }

  Widget _buildWaterBalanceLegend() {
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
              _buildLegendItem(Colors.green, 'Water Surplus'),
              _buildLegendItem(Colors.red, 'Water Deficit'),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Positive values = irrigation not needed • Negative values = irrigation required',
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

  Widget _buildIrrigationMetrics() {
    final totalDeficit = _calculateTotalWaterDeficit();
    final avgET = _calculateAverageET();
    
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
                  totalDeficit > 0 ? const Color(0xFFB71C1C).withValues(alpha: 0.8) : const Color(0xFF1B5E20).withValues(alpha: 0.8),
                  totalDeficit > 0 ? const Color(0xFFD32F2F).withValues(alpha: 0.6) : const Color(0xFF2E7D32).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: totalDeficit > 0 ? const Color(0xFFFF5722) : const Color(0xFF81C784), 
                width: 1.5
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
                    Icon(
                      Icons.water_drop_outlined, 
                      color: totalDeficit > 0 ? Colors.red[300] : Colors.green[300], 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Water Deficit',
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
                  '${totalDeficit.toInt()}mm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalDeficit > 0 ? 'Irrigation needed' : 'Adequate moisture',
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
                colors: [
                  const Color(0xFF0D47A1).withValues(alpha: 0.8),
                  const Color(0xFF1976D2).withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
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
                    Icon(Icons.air, color: Colors.blue[300], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Avg Daily ET',
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
                  '${avgET.toStringAsFixed(1)}mm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Evapotranspiration',
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

  Widget _buildIrrigationSchedule() {
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
                'Smart Irrigation Schedule (Next 7 Days)',
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
            final recommendation = _getIrrigationRecommendation(forecast);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: recommendation['color'].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: recommendation['color'].withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        recommendation['icon'],
                        color: recommendation['color'],
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
                          color: recommendation['color'].withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recommendation['status'],
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
                    recommendation['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildWaterDetail('Precipitation', '${forecast.precipitationSum.toInt()}mm', Icons.water_drop),
                      const SizedBox(width: 16),
                      _buildWaterDetail('ET Loss', '${AgriculturalCalculations.estimateEvapotranspiration(forecast).toInt()}mm', Icons.air),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWaterDetail(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getWaterBalanceBarGroups() {
    return weather.dailyForecast.asMap().entries.map((entry) {
      double precipitation = entry.value.precipitationSum;
      double evapotranspiration = AgriculturalCalculations.estimateEvapotranspiration(entry.value);
      double balance = precipitation - evapotranspiration;
      
      Color barColor = balance > 0 ? Colors.green : Colors.red;
      
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: balance,
            color: barColor.withValues(alpha: 0.8),
            width: 25, // Increased bar width for better touch
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: balance > 0 
                ? [Colors.green.withValues(alpha: 0.6), Colors.green]
                : [Colors.red.withValues(alpha: 0.6), Colors.red],
            ),
          ),
        ],
      );
    }).toList();
  }

  double _calculateTotalWaterDeficit() {
    double totalDeficit = 0;
    
    for (var forecast in weather.dailyForecast.take(7)) {
      double precipitation = forecast.precipitationSum;
      double et = AgriculturalCalculations.estimateEvapotranspiration(forecast);
      double deficit = et - precipitation;
      
      if (deficit > 0) {
        totalDeficit += deficit;
      }
    }
    
    return totalDeficit;
  }

  double _calculateAverageET() {
    if (weather.dailyForecast.isEmpty) return 0;
    
    double totalET = 0;
    for (var forecast in weather.dailyForecast.take(7)) {
      totalET += AgriculturalCalculations.estimateEvapotranspiration(forecast);
    }
    
    return totalET / weather.dailyForecast.take(7).length;
  }

  Map<String, dynamic> _getIrrigationRecommendation(DailyForecast forecast) {
    double precipitation = forecast.precipitationSum;
    double et = AgriculturalCalculations.estimateEvapotranspiration(forecast);
    double balance = precipitation - et;
    
    if (precipitation > 10) {
      return {
        'text': 'Skip irrigation completely. Heavy rainfall will provide sufficient moisture and may cause waterlogging if combined with irrigation.',
        'status': 'SKIP',
        'color': Colors.blue,
        'icon': Icons.water_drop,
      };
    } else if (precipitation > 5) {
      return {
        'text': 'Reduce irrigation by 50-70%. Moderate rainfall will supplement soil moisture. Monitor soil conditions before next irrigation cycle.',
        'status': 'REDUCE',
        'color': Colors.lightBlue,
        'icon': Icons.opacity,
      };
    } else if (balance < -8) {
      return {
        'text': 'Increase irrigation by 25-50%. High evapotranspiration and low precipitation create significant water demand. Deep watering recommended.',
        'status': 'INCREASE',
        'color': Colors.red,
        'icon': Icons.warning,
      };
    } else if (balance < -4) {
      return {
        'text': 'Maintain normal irrigation schedule. Moderate water deficit requires standard irrigation practices. Check soil moisture at root zone.',
        'status': 'NORMAL',
        'color': Colors.orange,
        'icon': Icons.schedule,
      };
    } else {
      return {
        'text': 'Light irrigation or skip if soil moisture is adequate. Low water demand allows for reduced irrigation frequency.',
        'status': 'LIGHT',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }
  }
}