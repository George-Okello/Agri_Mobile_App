import 'package:flutter/material.dart';

class WeatherIcons {
  /// Returns a suitable Flutter Icon for the given Open-Meteo weather code.
  static IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      // 0–3: Clear & cloudy
      case 0: return Icons.wb_sunny;             // Clear sky
      case 1: return Icons.wb_sunny_outlined;    // Mainly clear
      case 2: return Icons.cloud_queue;          // Partly cloudy
      case 3: return Icons.cloud;                // Overcast

      // 45–48: Fog
      case 45:
      case 48:
        return Icons.foggy;

      // 51–57: Drizzle & freezing drizzle
      case 51: return Icons.grain;               // Light drizzle
      case 53: return Icons.grain;               // Moderate drizzle
      case 55: return Icons.grain;               // Dense drizzle
      case 56: return Icons.ac_unit;             // Light freezing drizzle
      case 57: return Icons.ac_unit;             // Dense freezing drizzle

      // 61–67: Rain & freezing rain
      case 61: return Icons.water_drop;          // Light rain
      case 63: return Icons.grain;               // Moderate rain
      case 65: return Icons.umbrella;            // Heavy rain
      case 66: return Icons.ac_unit;             // Light freezing rain
      case 67: return Icons.ac_unit;             // Heavy freezing rain

      // 71–77: Snow
      case 71: return Icons.ac_unit;             // Light snowfall
      case 73: return Icons.ac_unit;             // Moderate snowfall
      case 75: return Icons.ac_unit;             // Heavy snowfall
      case 77: return Icons.ac_unit;             // Snow grains

      // 80–82: Rain showers
      case 80: return Icons.water_drop;          // Light rain showers
      case 81: return Icons.grain;               // Moderate rain showers
      case 82: return Icons.umbrella;            // Violent rain showers

      // 85–86: Snow showers
      case 85: return Icons.cloudy_snowing;      // Light snow showers
      case 86: return Icons.cloudy_snowing;      // Heavy snow showers

      // 95–99: Thunderstorms
      case 95: return Icons.thunderstorm;        // Thunderstorm
      case 96: return Icons.flash_on;            // Thunderstorm with slight hail
      case 99: return Icons.flash_on;            // Thunderstorm with heavy hail
    }
    // Since Open-Meteo only returns 0–99, all are covered.
    throw ArgumentError("Invalid weather code: $weatherCode");
  }

  /// Returns a human-friendly weather description for the given code.
  static String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      // 0–3
      case 0: return 'Clear Sky';
      case 1: return 'Mainly Clear';
      case 2: return 'Partly Cloudy';
      case 3: return 'Overcast';

      // 45–48
      case 45:
      case 48:
        return 'Fog';

      // 51–57
      case 51: return 'Light Drizzle';
      case 53: return 'Moderate Drizzle';
      case 55: return 'Dense Drizzle';
      case 56: return 'Light Freezing Drizzle';
      case 57: return 'Dense Freezing Drizzle';

      // 61–67
      case 61: return 'Light Rain';
      case 63: return 'Moderate Rain';
      case 65: return 'Heavy Rain';
      case 66: return 'Light Freezing Rain';
      case 67: return 'Heavy Freezing Rain';

      // 71–77
      case 71: return 'Light Snowfall';
      case 73: return 'Moderate Snowfall';
      case 75: return 'Heavy Snowfall';
      case 77: return 'Snow Grains';

      // 80–82
      case 80: return 'Light Rain Showers';
      case 81: return 'Moderate Rain Showers';
      case 82: return 'Violent Rain Showers';

      // 85–86
      case 85: return 'Light Snow Showers';
      case 86: return 'Heavy Snow Showers';

      // 95–99
      case 95: return 'Thunderstorm';
      case 96: return 'Thunderstorm with Light Hail';
      case 99: return 'Thunderstorm with Heavy Hail';
    }
    // All codes handled (0–99)
    throw ArgumentError("Invalid weather code: $weatherCode");
  }
}
