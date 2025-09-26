import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
          ChartUtilities.buildGraphTitle(Icons.trending_up, 'Yield Potential & Risk Assessment'),
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
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        children: [
          const Text(
            'Crop Stress Factors Impact on Yield',
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
                  _buildHeatStressLine(),
                  _buildWaterStressLine(),
                  _buildOverallStressLine(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildStressLegend(),
        ],
      ),
    );
  }

  Widget _buildYieldPotentialGauge() {
    double yieldPotential = AgriculturalCalculations.calculateYieldPotential(weather.dailyForecast);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
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
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: yieldPotential / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ChartUtilities.getStatusColor(yieldPotential),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${yieldPotential.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AgriculturalCalculations.getYieldPotentialLabel(yieldPotential),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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
        ChartUtilities.buildProgressBar(
          label: 'Heat Stress Risk',
          value: heatStress,
          color: Colors.red,
          unit: '%',
        ),
        const SizedBox(height: 12),
        ChartUtilities.buildProgressBar(
          label: 'Water Stress Risk',
          value: waterStress,
          color: Colors.blue,
          unit: '%',
        ),
      ],
    );
  }

  Widget _buildYieldFactorsBreakdown() {
    final factors = _calculateYieldFactors();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yield Impact Factors Analysis',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...factors.entries.map((factor) {
            Color impactColor = factor.value > 0 ? Colors.green : Colors.red;
            IconData impactIcon = factor.value > 0 ? Icons.trending_up : Icons.trending_down;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: impactColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: impactColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(impactIcon, color: impactColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      factor.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${factor.value > 0 ? '+' : ''}${factor.value.toInt()}%',
                    style: TextStyle(
                      color: impactColor,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStressLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChartUtilities.buildLegendItem(Colors.red, 'Heat Stress'),
        ChartUtilities.buildLegendItem(Colors.blue, 'Water Stress'),
        ChartUtilities.buildLegendItem(Colors.purple, 'Overall Stress'),
      ],
    );
  }

  LineChartBarData _buildHeatStressLine() {
    return LineChartBarData(
      spots: _getHeatStressSpots(),
      isCurved: true,
      color: Colors.red,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  LineChartBarData _buildWaterStressLine() {
    return LineChartBarData(
      spots: _getWaterStressSpots(),
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }

  LineChartBarData _buildOverallStressLine() {
    return LineChartBarData(
      spots: _getOverallStressSpots(),
      isCurved: true,
      color: Colors.purple,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
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
        .fold(0.0, (sum, p) => sum + p); // Changed to explicitly use 0.0 as initial value

    return {
      'Temperature Stress': -heatStress * 0.8, // Negative impact
      'Water Availability': waterStress > 50 ? -waterStress * 0.6 : precipitation * 2,
      'Growing Conditions': gddAccumulation > 200 ? 15.0 : gddAccumulation * 0.075, // Added .0 to make it explicit double
      'Weather Stability': _calculateWeatherStability(),
    };
  }

  double _calculateWeatherStability() {
    // Calculate temperature variance as a stability indicator
    final temps = weather.dailyForecast.map((f) => f.temperatureMax).toList();
    if (temps.length < 2) return 0.0; // Changed to 0.0
    
    double mean = temps.fold(0.0, (sum, temp) => sum + temp) / temps.length; // Changed to 0.0
    double variance = temps.map((temp) => (temp - mean) * (temp - mean))
        .fold(0.0, (sum, sq) => sum + sq) / temps.length; // Changed to 0.0
    
    // Lower variance = higher stability = positive yield impact
    double stability = (100.0 - (variance * 2)).clamp(0.0, 100.0); // Made all values explicit doubles
    return (stability - 50.0) * 0.3; // Convert to impact factor
  }
}