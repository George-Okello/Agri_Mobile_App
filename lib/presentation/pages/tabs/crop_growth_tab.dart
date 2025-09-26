import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/weather_entity.dart';
import '../../../core/utils/agricultural_calculations.dart';
import '../../../core/utils/chart_utilities.dart';

class CropGrowthTab extends StatelessWidget {
  final WeatherEntity weather;

  const CropGrowthTab({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ChartUtilities.buildGraphTitle(Icons.eco, 'Crop Growth & Development Analysis'),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildGrowingDegreeDaysChart(),
                  const SizedBox(height: 16),
                  _buildCropStagesTimeline(),
                  const SizedBox(height: 16),
                  _buildGrowthMetrics(),
                ],
              ),
            ),
          ),
          _buildCropGrowthLegend(),
        ],
      ),
    );
  }

  Widget _buildGrowingDegreeDaysChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
      child: Column(
        children: [
          const Text(
            'Growing Degree Days (GDD) Accumulation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.transparent,
                gridData: ChartUtilities.buildGridData(50),
                titlesData: ChartUtilities.buildBasicTitles(weather.dailyForecast, '°D'),
                borderData: ChartUtilities.buildBorderData(),
                minX: 0,
                maxX: (weather.dailyForecast.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxGDD() + 50,
                lineBarsData: [_buildGDDLine()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropStagesTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ChartUtilities.buildGraphDecoration(),
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
          _buildCropStagesList(),
        ],
      ),
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
          child: ChartUtilities.buildMetricCard(
            title: 'Accumulated GDD',
            value: '${currentGDD.toInt()}°D',
            icon: Icons.thermostat,
            color: const Color(0xFFFF8F00), // Orange
            subtitle: 'Base 10°C',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChartUtilities.buildMetricCard(
            title: 'Growth Stress',
            value: '${avgStress.toInt()}%',
            icon: Icons.warning,
            color: ChartUtilities.getStatusColor(100 - avgStress),
            subtitle: _getStressLabel(avgStress),
          ),
        ),
      ],
    );
  }

  Widget _buildCropStagesList() {
    final currentGDD = AgriculturalCalculations.calculateCumulativeGDD(
      weather.dailyForecast, 10
    );
    final stages = AgriculturalCalculations.predictCropStages(currentGDD);

    return Column(
      children: stages.map((stage) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: stage.isReached 
                ? [
                    const Color(0xFF2E7D32).withOpacity(0.4),
                    const Color(0xFF4CAF50).withOpacity(0.3),
                  ]
                : [
                    const Color(0xFF37474F).withOpacity(0.3),
                    const Color(0xFF455A64).withOpacity(0.2),
                  ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: stage.isReached 
                  ? const Color(0xFF4CAF50)
                  : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stage.isReached ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.3),
                  boxShadow: stage.isReached ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : [],
                ),
                child: Icon(
                  stage.isReached ? Icons.check : Icons.radio_button_unchecked,
                  color: stage.isReached ? Colors.white : Colors.white70,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.name,
                      style: TextStyle(
                        color: stage.isReached ? Colors.white : Colors.white70,
                        fontWeight: stage.isReached ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF8F00).withOpacity(0.8),
                        const Color(0xFFFFB300).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB300), width: 1),
                  ),
                  child: Text(
                    '${(stage.requiredGDD - currentGDD).toInt()}°D left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCropGrowthLegend() {
    return ChartUtilities.buildLegendContainer([
      ChartUtilities.buildLegendItem(const Color(0xFFFF8F00), 'GDD Accumulation'),
      ChartUtilities.buildLegendItem(const Color(0xFFD32F2F), 'Heat Stress'),
      ChartUtilities.buildLegendItem(const Color(0xFF1976D2), 'Water Stress'),
    ]);
  }

  LineChartBarData _buildGDDLine() {
    return LineChartBarData(
      spots: _getGDDSpots(),
      isCurved: true,
      color: const Color(0xFFFF8F00), // Orange
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
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
            const Color(0xFFFF8F00).withOpacity(0.3),
            const Color(0xFFFF8F00).withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getGDDSpots() {
    double cumulativeGDD = 0;
    const double baseTemp = 10; // Base temperature for GDD calculation
    
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
    if (stress < 20) return 'Low';
    if (stress < 40) return 'Moderate';
    if (stress < 60) return 'High';
    return 'Critical';
  }
}