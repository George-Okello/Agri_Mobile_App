import '../../domain/entities/weather_entity.dart';

class SprayWindowCalculator {
  
  // Get spray conditions for a given day
  static Map<String, dynamic> getSprayConditions(DailyForecast forecast) {
    List<String> issues = [];
    bool suitable = true;
    String severity = 'low';
    
    // Check wind speed - major factor
    if (forecast.windSpeedMax > 15) {
      issues.add('High wind speed (${forecast.windSpeedMax.toInt()} km/h)');
      suitable = false;
      severity = 'high';
    } else if (forecast.windSpeedMax > 10) {
      issues.add('Moderate wind speed (${forecast.windSpeedMax.toInt()} km/h)');
      severity = 'medium';
    }
    
    // Check precipitation
    if (forecast.precipitationSum > 5) {
      issues.add('Rain expected (${forecast.precipitationSum.toInt()}mm)');
      suitable = false;
      if (forecast.precipitationSum > 15) severity = 'high';
    } else if (forecast.precipitationSum > 1) {
      issues.add('Light rain possible (${forecast.precipitationSum.toInt()}mm)');
      severity = 'medium';
    }
    
    // Check temperature extremes
    if (forecast.temperatureMax > 30) {
      issues.add('High temperature (${forecast.temperatureMax.toInt()}°C)');
      if (forecast.temperatureMax > 35) {
        suitable = false;
        severity = 'high';
      } else {
        severity = 'medium';
      }
    }
    
    if (forecast.temperatureMax < 5) {
      issues.add('Very low temperature (${forecast.temperatureMax.toInt()}°C)');
      suitable = false;
      severity = 'high';
    }
    
    // Build reason string
    String reason;
    if (issues.isEmpty) {
      reason = 'Favorable conditions - Low wind, no precipitation expected';
    } else {
      reason = issues.join(', ');
    }
    
    return {
      'suitable': suitable,
      'reason': reason,
      'severity': severity,
      'issues': issues,
      'windSpeed': forecast.windSpeedMax,
      'precipitation': forecast.precipitationSum,
      'temperature': forecast.temperatureMax,
    };
  }
  
  // Get spray window score (0-100)
  static double getSprayScore(DailyForecast forecast) {
    double score = 100;
    
    // Wind penalty
    if (forecast.windSpeedMax > 15) {
      score -= 40;
    } else if (forecast.windSpeedMax > 10) {
      score -= 20;
    } else if (forecast.windSpeedMax > 5) {
      score -= 10;
    }
    
    // Precipitation penalty
    if (forecast.precipitationSum > 15) {
      score -= 50;
    } else if (forecast.precipitationSum > 5) {
      score -= 30;
    } else if (forecast.precipitationSum > 1) {
      score -= 15;
    }
    
    // Temperature penalties
    if (forecast.temperatureMax > 35) {
      score -= 30;
    } else if (forecast.temperatureMax > 30) {
      score -= 15;
    }
    
    if (forecast.temperatureMax < 5) {
      score -= 40;
    } else if (forecast.temperatureMax < 10) {
      score -= 20;
    }
    
    // Bonus for ideal conditions
    if (forecast.windSpeedMax <= 8 && 
        forecast.precipitationSum == 0 && 
        forecast.temperatureMax >= 15 && 
        forecast.temperatureMax <= 25) {
      score += 10;
    }
    
    return score.clamp(0, 100);
  }
  
  // Get best spray windows from a list of forecasts
  static List<Map<String, dynamic>> getBestSprayWindows(
    List<DailyForecast> forecasts, 
    {int maxWindows = 3}
  ) {
    List<Map<String, dynamic>> windows = [];
    
    for (int i = 0; i < forecasts.length; i++) {
      final forecast = forecasts[i];
      final conditions = getSprayConditions(forecast);
      final score = getSprayScore(forecast);
      
      windows.add({
        'date': forecast.date,
        'forecast': forecast,
        'conditions': conditions,
        'score': score,
        'dayIndex': i,
      });
    }
    
    // Sort by score descending
    windows.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Return top windows
    return windows.take(maxWindows).toList();
  }
  
  // Get spray recommendations for the week
  static List<String> getWeeklyRecommendations(List<DailyForecast> weeklyForecasts) {
    List<String> recommendations = [];
    
    int suitableDays = 0;
    int windyDays = 0;
    int rainyDays = 0;
    
    for (var forecast in weeklyForecasts.take(7)) {
      final conditions = getSprayConditions(forecast);
      if (conditions['suitable']) suitableDays++;
      if (forecast.windSpeedMax > 10) windyDays++;
      if (forecast.precipitationSum > 1) rainyDays++;
    }
    
    if (suitableDays >= 4) {
      recommendations.add('Excellent week for spray applications');
    } else if (suitableDays >= 2) {
      recommendations.add('Moderate opportunities for spraying this week');
    } else {
      recommendations.add('Limited spray opportunities this week');
    }
    
    if (windyDays >= 4) {
      recommendations.add('Plan early morning applications to avoid wind');
    }
    
    if (rainyDays >= 3) {
      recommendations.add('Consider systemic products due to frequent rain');
    }
    
    // Find the best day
    final bestWindows = getBestSprayWindows(weeklyForecasts.take(7).toList(), maxWindows: 1);
    if (bestWindows.isNotEmpty) {
      final bestDay = bestWindows.first;
      final date = DateTime.parse(bestDay['date']);
      recommendations.add('Best spray day: ${_getDayName(date.weekday)}');
    }
    
    return recommendations;
  }
  
  // Check if conditions are suitable for specific spray types
  static Map<String, bool> getSprayTypeSuitability(DailyForecast forecast) {
    final conditions = getSprayConditions(forecast);
    final windSpeed = forecast.windSpeedMax;
    final rain = forecast.precipitationSum;
    final temp = forecast.temperatureMax;
    
    return {
      'herbicide': windSpeed <= 12 && rain <= 3 && temp >= 10 && temp <= 30,
      'insecticide': windSpeed <= 15 && rain <= 5 && temp >= 8,
      'fungicide': windSpeed <= 10 && rain <= 2 && temp >= 5 && temp <= 28,
      'foliar_fertilizer': windSpeed <= 8 && rain == 0 && temp >= 12 && temp <= 25,
      'biological': windSpeed <= 8 && rain <= 1 && temp >= 15 && temp <= 25,
    };
  }
  
  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}