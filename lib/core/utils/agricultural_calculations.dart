import '../../domain/entities/weather_entity.dart';

class AgriculturalCalculations {
  // Calculate Growing Degree Days
  static double calculateGDD(double maxTemp, double minTemp, double baseTemp) {
    double avgTemp = (maxTemp + minTemp) / 2;
    return (avgTemp - baseTemp).clamp(0, double.infinity);
  }

  // Calculate cumulative GDD for a list of forecasts
  static double calculateCumulativeGDD(List<DailyForecast> forecasts, double baseTemp) {
    double total = 0;
    for (var forecast in forecasts) {
      total += calculateGDD(forecast.temperatureMax, forecast.temperatureMin, baseTemp);
    }
    return total;
  }

  // Predict crop stages based on GDD
  static List<CropStage> predictCropStages(double currentGDD) {
    return [
      CropStage('Emergence', 150, currentGDD >= 150),
      CropStage('Vegetative Growth', 400, currentGDD >= 400),
      CropStage('Flowering', 800, currentGDD >= 800),
      CropStage('Grain Fill', 1200, currentGDD >= 1200),
      CropStage('Maturity', 1600, currentGDD >= 1600),
    ];
  }

  // Calculate heat stress percentage
  static double calculateHeatStress(double temperature) {
    if (temperature < 25) return 0;
    if (temperature < 30) return (temperature - 25) * 4; // 0-20%
    if (temperature < 35) return 20 + (temperature - 30) * 8; // 20-60%
    return 60 + (temperature - 35) * 10; // 60-100%
  }

  // Calculate water stress based on recent precipitation
  static double calculateWaterStress(List<DailyForecast> recentForecasts) {
    if (recentForecasts.isEmpty) return 50;
    
    double totalPrecip = 0;
    double totalET = 0;
    
    for (var forecast in recentForecasts.take(7)) {
      totalPrecip += forecast.precipitationSum;
      totalET += estimateEvapotranspiration(forecast);
    }
    
    double waterBalance = totalPrecip - totalET;
    if (waterBalance >= 0) return 0; // No water stress
    
    return ((-waterBalance / totalET) * 100).clamp(0, 100);
  }

  // Calculate overall stress combining multiple factors
  static double calculateOverallStress(double heatStress, double waterStress) {
    return ((heatStress * 0.6) + (waterStress * 0.4)).clamp(0, 100);
  }

  // Estimate evapotranspiration
  static double estimateEvapotranspiration(DailyForecast forecast) {
    double baseET = 3.0; // Base ET rate
    double tempFactor = (forecast.temperatureMax - 20) * 0.1;
    double windFactor = forecast.windSpeedMax * 0.05;
    
    return (baseET + tempFactor + windFactor).clamp(1.0, 8.0);
  }

  // Calculate Temperature Humidity Index for livestock
  static double calculateTHI(double temperature, double humidity) {
    return (1.8 * temperature + 32) - ((0.55 - 0.0055 * humidity) * ((1.8 * temperature + 32) - 58));
  }

  // Calculate yield potential
  static double calculateYieldPotential(List<DailyForecast> forecasts) {
    if (forecasts.isEmpty) return 50;
    
    double totalStress = 0;
    int stressfulDays = 0;
    double totalGDD = 0;
    
    for (var forecast in forecasts.take(14)) {
      double heatStress = calculateHeatStress(forecast.temperatureMax);
      double waterStress = forecast.precipitationSum < 2 ? 30 : 0;
      
      totalStress += calculateOverallStress(heatStress, waterStress);
      if (heatStress > 40 || waterStress > 40) stressfulDays++;
      
      totalGDD += calculateGDD(forecast.temperatureMax, forecast.temperatureMin, 10);
    }
    
    double avgStress = totalStress / forecasts.take(14).length;
    double stressPenalty = (stressfulDays * 5) + (avgStress * 0.5);
    double gddBonus = (totalGDD > 300) ? 10 : 0;
    
    return (85 - stressPenalty + gddBonus).clamp(0, 100);
  }

  // Get yield potential label
  static String getYieldPotentialLabel(double potential) {
    if (potential >= 80) return 'Excellent';
    if (potential >= 65) return 'Good';
    if (potential >= 50) return 'Fair';
    if (potential >= 30) return 'Poor';
    return 'Very Poor';
  }
}

class CropStage {
  final String name;
  final double requiredGDD;
  final bool isReached;
  
  CropStage(this.name, this.requiredGDD, this.isReached);
}