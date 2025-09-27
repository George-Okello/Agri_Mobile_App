import '../../domain/entities/weather_entity.dart';

class DiseaseRiskCalculator {
  
  // Calculate fungal disease risk based on weather conditions
  static double calculateFungalRisk(DailyForecast forecast) {
    double riskScore = 0;
    
    // Temperature factor (optimal range for fungal growth: 15-25°C)
    double avgTemp = (forecast.temperatureMax + forecast.temperatureMin) / 2;
    if (avgTemp >= 15 && avgTemp <= 25) {
      riskScore += 30;
    } else if (avgTemp >= 10 && avgTemp <= 30) {
      riskScore += 15;
    }
    
    // Humidity factor (estimate humidity from precipitation and temperature)
    double estimatedHumidity = _estimateHumidity(forecast);
    if (estimatedHumidity >= 80) {
      riskScore += 35;
    } else if (estimatedHumidity >= 60) {
      riskScore += 20;
    } else if (estimatedHumidity >= 40) {
      riskScore += 10;
    }
    
    // Precipitation factor
    if (forecast.precipitationSum > 10) {
      riskScore += 25;
    } else if (forecast.precipitationSum > 5) {
      riskScore += 15;
    } else if (forecast.precipitationSum > 1) {
      riskScore += 5;
    }
    
    // Leaf wetness duration (estimated from precipitation and humidity)
    double leafWetnessDuration = _estimateLeafWetness(forecast);
    if (leafWetnessDuration > 12) {
      riskScore += 10;
    } else if (leafWetnessDuration > 6) {
      riskScore += 5;
    }
    
    return riskScore.clamp(0, 100);
  }
  
  // Calculate bacterial disease risk
  static double calculateBacterialRisk(DailyForecast forecast) {
    double riskScore = 0;
    
    // Temperature factor (bacteria thrive in warmer conditions)
    double avgTemp = (forecast.temperatureMax + forecast.temperatureMin) / 2;
    if (avgTemp >= 25 && avgTemp <= 35) {
      riskScore += 30;
    } else if (avgTemp >= 20 && avgTemp <= 40) {
      riskScore += 20;
    }
    
    // High humidity and precipitation increase bacterial risk
    if (forecast.precipitationSum > 5) {
      riskScore += 25;
    }
    
    double estimatedHumidity = _estimateHumidity(forecast);
    if (estimatedHumidity >= 70) {
      riskScore += 25;
    }
    
    // Wind can spread bacterial diseases
    if (forecast.windSpeedMax > 15) {
      riskScore += 10;
    }
    
    return riskScore.clamp(0, 100);
  }
  
  // Calculate pest pressure
  static double calculatePestPressure(DailyForecast forecast) {
    double pressure = 0;
    
    double avgTemp = (forecast.temperatureMax + forecast.temperatureMin) / 2;
    
    // Temperature affects pest activity
    if (avgTemp >= 20 && avgTemp <= 30) {
      pressure += 40; // Optimal temperature for most pests
    } else if (avgTemp >= 15 && avgTemp <= 35) {
      pressure += 25;
    } else if (avgTemp >= 10 && avgTemp <= 40) {
      pressure += 10;
    }
    
    // Humidity factor
    double estimatedHumidity = _estimateHumidity(forecast);
    if (estimatedHumidity >= 60) {
      pressure += 20;
    }
    
    // Light rain can increase pest activity, heavy rain decreases it
    if (forecast.precipitationSum >= 1 && forecast.precipitationSum <= 5) {
      pressure += 15;
    } else if (forecast.precipitationSum > 15) {
      pressure -= 10; // Heavy rain washes away pests
    }
    
    // Calm conditions favor pest activity
    if (forecast.windSpeedMax < 10) {
      pressure += 10;
    } else if (forecast.windSpeedMax > 20) {
      pressure -= 5; // Strong winds disrupt pests
    }
    
    return pressure.clamp(0, 100);
  }
  
  // Get overall disease and pest risk
  static Map<String, double> getOverallRisk(DailyForecast forecast) {
    return {
      'fungal': calculateFungalRisk(forecast),
      'bacterial': calculateBacterialRisk(forecast),
      'pest': calculatePestPressure(forecast),
    };
  }
  
  // Get risk level description
  static String getRiskDescription(double riskScore) {
    if (riskScore >= 80) return 'Very High';
    if (riskScore >= 60) return 'High';
    if (riskScore >= 40) return 'Moderate';
    if (riskScore >= 20) return 'Low';
    return 'Very Low';
  }
  
  // Estimate humidity based on precipitation and temperature
  static double _estimateHumidity(DailyForecast forecast) {
    double baseHumidity = 50;
    
    // Precipitation increases humidity
    if (forecast.precipitationSum > 10) {
      baseHumidity += 35;
    } else if (forecast.precipitationSum > 5) {
      baseHumidity += 25;
    } else if (forecast.precipitationSum > 1) {
      baseHumidity += 15;
    }
    
    // Temperature affects humidity (inverse relationship)
    double avgTemp = (forecast.temperatureMax + forecast.temperatureMin) / 2;
    if (avgTemp > 30) {
      baseHumidity -= 15;
    } else if (avgTemp < 15) {
      baseHumidity += 10;
    }
    
    // Clear sky conditions (weather code 0) typically mean lower humidity
    if (forecast.weatherCode == 0) {
      baseHumidity -= 10;
    }
    
    return baseHumidity.clamp(20, 95);
  }
  
  // Estimate leaf wetness duration in hours
  static double _estimateLeafWetness(DailyForecast forecast) {
    double wetnessDuration = 0;
    
    // Precipitation directly contributes to leaf wetness
    if (forecast.precipitationSum > 10) {
      wetnessDuration += 16; // Most of the day
    } else if (forecast.precipitationSum > 5) {
      wetnessDuration += 12;
    } else if (forecast.precipitationSum > 1) {
      wetnessDuration += 8;
    }
    
    // High humidity extends leaf wetness
    double estimatedHumidity = _estimateHumidity(forecast);
    if (estimatedHumidity >= 90) {
      wetnessDuration += 6;
    } else if (estimatedHumidity >= 80) {
      wetnessDuration += 3;
    }
    
    // Temperature differential can cause dew
    double tempRange = forecast.temperatureMax - forecast.temperatureMin;
    if (tempRange > 15) {
      wetnessDuration += 2; // Likely dew formation
    }
    
    return wetnessDuration.clamp(0, 24);
  }
}
