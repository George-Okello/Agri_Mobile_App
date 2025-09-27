import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/weather_entity.dart';

class ChartUtilities {
  static Widget buildGraphTitle(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: buildGraphDecoration(),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration buildGraphDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B5E20).withValues(alpha: 0.8), // Dark green
          const Color(0xFF2E7D32).withValues(alpha: 0.6), // Medium green
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF81C784), width: 1.5), // Light green border
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static FlGridData buildGridData(double interval) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.white.withValues(alpha: 0.3),
        strokeWidth: 0.8,
      ),
    );
  }

  static FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
    );
  }

  static Widget buildDateTitle(double value, List<DailyForecast> dailyForecast) {
    if (value.toInt() < dailyForecast.length) {
      final date = DateTime.parse(dailyForecast[value.toInt()].date);
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          DateFormat('M/d').format(date),
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      );
    }
    return const Text('');
  }

  static FlTitlesData buildBasicTitles(
    List<DailyForecast> dailyForecast, 
    String yAxisUnit,
    {double? interval}
  ) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: interval ?? 2,
          getTitlesWidget: (value, meta) => buildDateTitle(value, dailyForecast),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}$yAxisUnit',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  static Widget buildLegendItem(Color color, String label) {
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

  static Widget buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
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
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
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
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildStatusCard({
    required String title,
    required String status,
    required Color statusColor,
    required IconData statusIcon,
    String? description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            blurRadius: 6,
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
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
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildProgressBar({
    required String label,
    required double value,
    required Color color,
    double maxValue = 100,
    String? unit,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toInt()}${unit ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  static Color getStatusColor(double value, {
    double goodThreshold = 70,
    double warningThreshold = 40,
  }) {
    if (value >= goodThreshold) return const Color(0xFF2E7D32); // Dark green
    if (value >= warningThreshold) return const Color(0xFFFF8F00); // Orange
    return const Color(0xFFD32F2F); // Red
  }

  static IconData getStatusIcon(double value, {
    double goodThreshold = 70,
    double warningThreshold = 40,
  }) {
    if (value >= goodThreshold) return Icons.check_circle;
    if (value >= warningThreshold) return Icons.warning;
    return Icons.error;
  }

  // Enhanced legend with container
  static Widget buildLegendContainer(List<Widget> legendItems) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF263238).withValues(alpha: 0.9), // Dark blue-grey
            const Color(0xFF37474F).withValues(alpha: 0.8), // Medium blue-grey
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: legendItems,
      ),
    );
  }
}
