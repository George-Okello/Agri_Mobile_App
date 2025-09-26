// ignore: library_prefixes
import 'dart:math' as Math;

import '../../domain/entities/weather_entity.dart';

class FieldOperationsCalculator {
  
  // Calculate overall field operations suitability (0-100)
  static double calculateOperationsSuitability(DailyForecast forecast) {
    double score = 100;
    
    // Temperature factors
    if (forecast.temperatureMax < 0) {
      score -= 30; // Frozen ground conditions
    } else if (forecast.temperatureMax < 5) {
      score -= 20; // Very cold
    } else if (forecast.temperatureMax > 35) {
      score -= 15; // Too hot for operators
    }
    
    // Precipitation factors
    if (forecast.precipitationSum > 20) {
      score -= 50; // Heavy rain makes fields impassable
    } else if (forecast.precipitationSum > 10) {
      score -= 30; // Moderate rain
    } else if (forecast.precipitationSum > 5) {
      score -= 15; // Light rain may delay operations
    } else if (forecast.precipitationSum > 1) {
      score -= 5; // Very light precipitation
    }
    
    // Wind factors
    if (forecast.windSpeedMax > 25) {
      score -= 25; // Dangerous wind speeds
    } else if (forecast.windSpeedMax > 15) {
      score -= 10; // High winds affect precision
    }
    
    // Weather code specific adjustments
    if (forecast.weatherCode >= 95) { // Thunderstorms
      score -= 40;
    } else if (forecast.weatherCode >= 80) { // Rain showers
      score -= 20;
    } else if (forecast.weatherCode >= 70) { // Snow
      score -= 35;
    } else if (forecast.weatherCode >= 50) { // Drizzle
      score -= 15;
    } else if (forecast.weatherCode == 0) { // Clear sky bonus
      score += 5;
    }
    
    return score.clamp(0, 100);
  }
  
  // Get recommended operations for a specific day
  static List<String> getRecommendedOperations(DailyForecast forecast) {
    List<String> operations = [];
    double suitability = calculateOperationsSuitability(forecast);
    
    if (suitability >= 80) {
      operations.addAll(_getOptimalOperations(forecast));
    } else if (suitability >= 60) {
      operations.addAll(_getModerateOperations(forecast));
    } else if (suitability >= 40) {
      operations.addAll(_getLimitedOperations(forecast));
    } else {
      operations.add('Avoid field operations - unsuitable conditions');
    }
    
    return operations;
  }
  
  // Operations suitable for optimal conditions
  static List<String> _getOptimalOperations(DailyForecast forecast) {
    List<String> operations = [];
    
    // Temperature-based recommendations
    if (forecast.temperatureMax >= 10 && forecast.temperatureMax <= 30) {
      operations.add('Planting and seeding operations');
      operations.add('Precision fertilizer application');
      operations.add('Cultivation and tillage');
    }
    
    if (forecast.precipitationSum == 0) {
      operations.add('Harvest operations');
      operations.add('Hay making and baling');
      operations.add('Spraying applications');
    }
    
    if (forecast.windSpeedMax <= 10) {
      operations.add('Drone/aerial applications');
      operations.add('Fine spray applications');
    }
    
    // General favorable operations
    operations.addAll([
      'Equipment maintenance',
      'Soil sampling',
      'Field scouting and monitoring',
    ]);
    
    return operations;
  }
  
  // Operations suitable for moderate conditions
  static List<String> _getModerateOperations(DailyForecast forecast) {
    List<String> operations = [];
    
    if (forecast.precipitationSum <= 5) {
      operations.add('Non-critical cultivation');
      operations.add('Equipment transport');
    }
    
    if (forecast.windSpeedMax <= 15) {
      operations.add('Coarse spray applications');
    }
    
    operations.addAll([
      'Field inspection',
      'Maintenance activities',
      'Planning and preparation',
    ]);
    
    return operations;
  }
  
  // Operations suitable for limited conditions
  static List<String> _getLimitedOperations(DailyForecast forecast) {
    return [
      'Indoor activities only',
      'Equipment servicing',
      'Planning and paperwork',
      'Training and education',
    ];
  }
  
  // Get soil workability assessment
  static Map<String, dynamic> getSoilWorkability(DailyForecast forecast) {
    double workability = 100;
    String condition = 'Excellent';
    List<String> factors = [];
    
    // Recent precipitation affects soil moisture
    if (forecast.precipitationSum > 15) {
      workability = 10;
      condition = 'Too wet - avoid field work';
      factors.add('Heavy precipitation expected');
    } else if (forecast.precipitationSum > 5) {
      workability = 30;
      condition = 'Wet - limited operations only';
      factors.add('Moderate precipitation may cause rutting');
    } else if (forecast.precipitationSum > 1) {
      workability = 60;
      condition = 'Marginal - check soil conditions';
      factors.add('Light rain may affect soil surface');
    }
    
    // Temperature effects on soil
    if (forecast.temperatureMin < 0) {
      workability = Math.min(workability, 20);
      condition = 'Frozen soil conditions';
      factors.add('Ground likely frozen');
    } else if (forecast.temperatureMin < 5) {
      workability = Math.min(workability, 50);
      factors.add('Cool soil temperatures');
    }
    
    if (factors.isEmpty) {
      factors.add('Favorable conditions for soil work');
    }
    
    return {
      'workability': workability,
      'condition': condition,
      'factors': factors,
    };
  }
  
  // Get harvest readiness assessment
  static Map<String, dynamic> getHarvestReadiness(DailyForecast forecast) {
    double readiness = 100;
    String status = 'Excellent';
    List<String> considerations = [];
    
    // Precipitation is critical for harvest
    if (forecast.precipitationSum > 5) {
      readiness = 0;
      status = 'Not suitable';
      considerations.add('Precipitation will delay harvest');
    } else if (forecast.precipitationSum > 1) {
      readiness = 30;
      status = 'Marginal';
      considerations.add('Light precipitation may cause delays');
    }
    
    // Wind affects harvest quality
    if (forecast.windSpeedMax > 20) {
      readiness = Math.min(readiness, 40);
      considerations.add('High winds may cause crop loss');
    } else if (forecast.windSpeedMax > 15) {
      readiness = Math.min(readiness, 70);
      considerations.add('Moderate winds - monitor conditions');
    }
    
    // Temperature considerations
    if (forecast.temperatureMax > 30) {
      considerations.add('Hot weather - consider early morning harvest');
    }
    
    if (considerations.isEmpty) {
      considerations.add('Ideal harvest conditions');
    }
    
    return {
      'readiness': readiness,
      'status': status,
      'considerations': considerations,
    };
  }
  
  // Get equipment operation recommendations
  static Map<String, List<String>> getEquipmentRecommendations(DailyForecast forecast) {
    Map<String, List<String>> recommendations = {
      'tractors': [],
      'harvesters': [],
      'sprayers': [],
      'planters': [],
    };
    
    double suitability = calculateOperationsSuitability(forecast);
    
    // Tractor operations
    if (suitability >= 70) {
      recommendations['tractors']!.addAll([
        'All tractor operations suitable',
        'Good conditions for heavy tillage',
      ]);
    } else if (suitability >= 40) {
      recommendations['tractors']!.add('Light tractor work only');
    } else {
      recommendations['tractors']!.add('Avoid tractor operations');
    }
    
    // Harvester operations
    if (forecast.precipitationSum == 0 && forecast.windSpeedMax <= 20) {
      recommendations['harvesters']!.add('Optimal harvest conditions');
    } else if (forecast.precipitationSum <= 1) {
      recommendations['harvesters']!.add('Monitor crop moisture levels');
    } else {
      recommendations['harvesters']!.add('Delay harvest operations');
    }
    
    // Sprayer operations
    if (forecast.windSpeedMax <= 10 && forecast.precipitationSum == 0) {
      recommendations['sprayers']!.add('Excellent spray conditions');
    } else if (forecast.windSpeedMax <= 15 && forecast.precipitationSum <= 1) {
      recommendations['sprayers']!.add('Acceptable spray conditions');
    } else {
      recommendations['sprayers']!.add('Avoid spraying operations');
    }
    
    // Planter operations
    if (forecast.temperatureMin >= 8 && forecast.precipitationSum <= 2) {
      recommendations['planters']!.add('Good planting conditions');
    } else if (forecast.temperatureMin < 5) {
      recommendations['planters']!.add('Soil too cold for planting');
    } else {
      recommendations['planters']!.add('Monitor soil conditions');
    }
    
    return recommendations;
  }
  
  // Get timing recommendations for field operations
  static Map<String, String> getTimingRecommendations(List<DailyForecast> forecasts) {
    Map<String, String> timing = {};
    
    // Find best days for different operations
    double bestSprayScore = 0;
    String bestSprayDay = '';
    
    double bestHarvestScore = 0;
    String bestHarvestDay = '';
    
    double bestTillageScore = 0;
    String bestTillageDay = '';
    
    for (int i = 0; i < forecasts.length && i < 7; i++) {
      var forecast = forecasts[i];
      double operationsScore = calculateOperationsSuitability(forecast);
      
      // Spray timing
      if (forecast.windSpeedMax <= 10 && forecast.precipitationSum == 0) {
        double sprayScore = operationsScore + (10 - forecast.windSpeedMax);
        if (sprayScore > bestSprayScore) {
          bestSprayScore = sprayScore;
          bestSprayDay = _getDayName(i);
        }
      }
      
      // Harvest timing
      if (forecast.precipitationSum == 0) {
        double harvestScore = operationsScore + 
            (forecast.windSpeedMax <= 15 ? 10 : 0);
        if (harvestScore > bestHarvestScore) {
          bestHarvestScore = harvestScore;
          bestHarvestDay = _getDayName(i);
        }
      }
      
      // Tillage timing
      if (forecast.precipitationSum <= 1 && forecast.temperatureMax >= 10) {
        double tillageScore = operationsScore;
        if (tillageScore > bestTillageScore) {
          bestTillageScore = tillageScore;
          bestTillageDay = _getDayName(i);
        }
      }
    }
    
    timing['spray'] = bestSprayDay.isNotEmpty ? bestSprayDay : 'No suitable days';
    timing['harvest'] = bestHarvestDay.isNotEmpty ? bestHarvestDay : 'No suitable days';
    timing['tillage'] = bestTillageDay.isNotEmpty ? bestTillageDay : 'No suitable days';
    
    return timing;
  }
  
  static String _getDayName(int dayOffset) {
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: dayOffset));
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[targetDate.weekday - 1];
  }
}