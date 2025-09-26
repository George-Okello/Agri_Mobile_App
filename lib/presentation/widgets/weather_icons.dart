import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0: // Clear sky
        return Icons.wb_sunny;
      case 1: // Mainly clear
        return Icons.wb_sunny_outlined;
      case 2: // Partly cloudy
        return Icons.cloud_queue; // Fixed: changed from partly_cloudy_day to cloud_queue
      case 3: // Overcast
        return Icons.cloud;
      case 45: // Fog
      case 48: // Depositing rime fog
        return Icons.foggy;
      case 51: // Drizzle: Light
      case 53: // Drizzle: moderate
      case 55: // Drizzle: dense
        return Icons.grain;
      case 61: // Rain: Slight
      case 63: // Rain: moderate
        return Icons.water_drop;
      case 65: // Rain: heavy
        return Icons.umbrella;
      case 71: // Snow fall: Slight
      case 73: // Snow fall: moderate
      case 75: // Snow fall: heavy
        return Icons.ac_unit;
      case 95: // Thunderstorm
        return Icons.thunderstorm;
      case 96: // Thunderstorm with slight hail
      case 99: // Thunderstorm with heavy hail
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }
  
  static String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
        return 'Light Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 71:
        return 'Light Snow';
      case 73:
        return 'Moderate Snow';
      case 75:
        return 'Heavy Snow';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }
}