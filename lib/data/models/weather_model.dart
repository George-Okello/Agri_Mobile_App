import '../../domain/entities/weather_entity.dart';
import 'dart:math';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.temperature,
    required super.temperatureMax,
    required super.temperatureMin,
    required super.apparentTemperature,
    required super.weatherCode,
    required super.windSpeed,
    required super.windGusts,
    required super.windDirection,
    required super.rainfall,
    required super.humidity,
    required super.uvIndex,
    required super.pressure,
    required super.sunshineDuration,
    required super.evapotranspiration,
    required super.soilTemperature0cm,
    required super.soilTemperature6cm,
    required super.soilTemperature18cm,
    required super.soilMoisture0to1cm,
    required super.soilMoisture1to3cm,
    required super.soilMoisture3to9cm,
    required super.sunrise,
    required super.sunset,
    required super.daylightDuration,
    required super.hourlyForecast,
    required super.dailyForecast,
    required super.cityName,
    super.historicalData,
    super.airQuality,
    super.elevation,
    super.soilAnalysis,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String cityName) {
    final current = json['current'] ?? {};
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    return WeatherModel(
      // Basic weather from API
      temperature: current['temperature_2m']?.toDouble() ?? 0.0,
      temperatureMax: (daily['temperature_2m_max'] as List?)?.isNotEmpty == true 
          ? daily['temperature_2m_max'][0]?.toDouble() ?? 0.0 : 0.0,
      temperatureMin: (daily['temperature_2m_min'] as List?)?.isNotEmpty == true 
          ? daily['temperature_2m_min'][0]?.toDouble() ?? 0.0 : 0.0,
      apparentTemperature: current['apparent_temperature']?.toDouble() ?? 0.0,
      weatherCode: current['weather_code'] ?? 0,
      windSpeed: current['wind_speed_10m']?.toDouble() ?? 0.0,
      windGusts: 0.0, // Not in current API call
      windDirection: current['wind_direction_10m'] ?? 0,
      rainfall: current['precipitation']?.toDouble() ?? 0.0,
      humidity: current['relative_humidity_2m'] ?? 0,
      uvIndex: current['uv_index']?.toDouble() ?? 0.0,
      pressure: current['surface_pressure']?.toDouble() ?? 1013.25,
      
      // Default values for agricultural data not in API
      sunshineDuration: 0.0,
      evapotranspiration: 2.5,
      soilTemperature0cm: current['temperature_2m']?.toDouble() ?? 15.0,
      soilTemperature6cm: current['temperature_2m']?.toDouble() ?? 15.0,
      soilTemperature18cm: current['temperature_2m']?.toDouble() ?? 15.0,
      soilMoisture0to1cm: 0.3,
      soilMoisture1to3cm: 0.3,
      soilMoisture3to9cm: 0.3,
      
      // Time data from API
      sunrise: (daily['sunrise'] as List?)?.isNotEmpty == true 
          ? daily['sunrise'][0]?.toString() ?? '' : '',
      sunset: (daily['sunset'] as List?)?.isNotEmpty == true 
          ? daily['sunset'][0]?.toString() ?? '' : '',
      daylightDuration: 43200.0, // Default 12 hours
      
      // Forecasts
      hourlyForecast: _parseHourlyForecast(hourly),
      dailyForecast: _parseDailyForecast(daily),
      cityName: cityName,
    );
  }

  factory WeatherModel.fromEnhancedJson(
    Map<String, dynamic> weatherData,
    Map<String, dynamic>? historicalData,
    Map<String, dynamic>? airQualityData,
    double elevation,
    Map<String, dynamic>? soilData,
    String cityName,
  ) {
    final current = weatherData['current'] ?? {};
    final daily = weatherData['daily'] ?? {};
    final hourly = weatherData['hourly'] ?? {};

    // Enhanced soil data from API if available
    Map<String, dynamic> enhancedSoil = soilData ?? {};
    final soilDaily = enhancedSoil['daily'] ?? {};
    
    return WeatherModel(
      // Basic weather from API
      temperature: current['temperature_2m']?.toDouble() ?? 0.0,
      temperatureMax: (daily['temperature_2m_max'] as List?)?.isNotEmpty == true 
          ? daily['temperature_2m_max'][0]?.toDouble() ?? 0.0 : 0.0,
      temperatureMin: (daily['temperature_2m_min'] as List?)?.isNotEmpty == true 
          ? daily['temperature_2m_min'][0]?.toDouble() ?? 0.0 : 0.0,
      apparentTemperature: current['apparent_temperature']?.toDouble() ?? 0.0,
      weatherCode: current['weather_code'] ?? 0,
      windSpeed: current['wind_speed_10m']?.toDouble() ?? 0.0,
      windGusts: 0.0,
      windDirection: current['wind_direction_10m'] ?? 0,
      rainfall: current['precipitation']?.toDouble() ?? 0.0,
      humidity: current['relative_humidity_2m'] ?? 0,
      uvIndex: current['uv_index']?.toDouble() ?? 0.0,
      pressure: current['surface_pressure']?.toDouble() ?? 1013.25,
      
      // Enhanced agricultural data
      sunshineDuration: 0.0,
      evapotranspiration: 2.5,
      soilTemperature0cm: _getSoilValue(soilDaily, 'soil_temperature_0cm', 0) ?? 
                         (current['temperature_2m']?.toDouble() ?? 15.0),
      soilTemperature6cm: _getSoilValue(soilDaily, 'soil_temperature_6cm', 0) ?? 
                         (current['temperature_2m']?.toDouble() ?? 15.0),
      soilTemperature18cm: _getSoilValue(soilDaily, 'soil_temperature_18cm', 0) ?? 
                          (current['temperature_2m']?.toDouble() ?? 15.0),
      soilMoisture0to1cm: _getSoilValue(soilDaily, 'soil_moisture_0_1cm', 0) ?? 0.3,
      soilMoisture1to3cm: _getSoilValue(soilDaily, 'soil_moisture_1_3cm', 0) ?? 0.3,
      soilMoisture3to9cm: _getSoilValue(soilDaily, 'soil_moisture_3_9cm', 0) ?? 0.3,
      
      // Time data from API
      sunrise: (daily['sunrise'] as List?)?.isNotEmpty == true 
          ? daily['sunrise'][0]?.toString() ?? '' : '',
      sunset: (daily['sunset'] as List?)?.isNotEmpty == true 
          ? daily['sunset'][0]?.toString() ?? '' : '',
      daylightDuration: 43200.0,
      
      // Forecasts
      hourlyForecast: _parseHourlyForecast(hourly),
      dailyForecast: _parseDailyForecast(daily),
      cityName: cityName,
      
      // Enhanced properties
      historicalData: _parseHistoricalData(historicalData),
      airQuality: _parseAirQualityData(airQualityData),
      elevation: elevation,
      soilAnalysis: enhancedSoil,
    );
  }

  static double? _getSoilValue(Map<String, dynamic> soilDaily, String key, int index) {
    final values = soilDaily[key] as List?;
    if (values != null && values.length > index && values[index] != null) {
      return values[index].toDouble();
    }
    return null;
  }

  static List<HourlyForecast> _parseHourlyForecast(Map<String, dynamic>? hourly) {
    if (hourly == null || hourly.isEmpty) return [];
    
    final times = List<String>.from(hourly['time'] ?? []);
    final temperatures = List<dynamic>.from(hourly['temperature_2m'] ?? []);
    final weatherCodes = List<dynamic>.from(hourly['weather_code'] ?? []);
    final humidity = List<dynamic>.from(hourly['relative_humidity_2m'] ?? []);
    final precipitation = List<dynamic>.from(hourly['precipitation'] ?? []);
    final precipitationProb = List<dynamic>.from(hourly['precipitation_probability'] ?? []);
    final windSpeed = List<dynamic>.from(hourly['wind_speed_10m'] ?? []);
    final uvIndex = List<dynamic>.from(hourly['uv_index'] ?? []);

    final forecasts = <HourlyForecast>[];
    final limit = min(times.length, 48);

    for (int i = 0; i < limit; i++) {
      forecasts.add(HourlyForecastModel(
        time: times[i],
        temperature: temperatures.length > i ? temperatures[i]?.toDouble() ?? 0.0 : 0.0,
        weatherCode: weatherCodes.length > i ? weatherCodes[i] ?? 0 : 0,
        humidity: humidity.length > i ? humidity[i]?.toDouble() ?? 50.0 : 50.0,
        precipitation: precipitation.length > i ? precipitation[i]?.toDouble() ?? 0.0 : 0.0,
        precipitationProbability: precipitationProb.length > i ? precipitationProb[i]?.toDouble() ?? 0.0 : 0.0,
        windSpeed: windSpeed.length > i ? windSpeed[i]?.toDouble() ?? 0.0 : 0.0,
        uvIndex: uvIndex.length > i ? uvIndex[i]?.toDouble() ?? 0.0 : 0.0,
        soilTemperature0cm: temperatures.length > i ? temperatures[i]?.toDouble() ?? 15.0 : 15.0,
        soilMoisture0to1cm: 0.3,
      ));
    }

    return forecasts;
  }

  static List<DailyForecast> _parseDailyForecast(Map<String, dynamic>? daily) {
    if (daily == null || daily.isEmpty) return [];
    
    final times = List<String>.from(daily['time'] ?? []);
    final maxTemps = List<dynamic>.from(daily['temperature_2m_max'] ?? []);
    final minTemps = List<dynamic>.from(daily['temperature_2m_min'] ?? []);
    final apparentMaxTemps = List<dynamic>.from(daily['apparent_temperature_max'] ?? []);
    final apparentMinTemps = List<dynamic>.from(daily['apparent_temperature_min'] ?? []);
    final weatherCodes = List<dynamic>.from(daily['weather_code'] ?? []);
    final sunrise = List<dynamic>.from(daily['sunrise'] ?? []);
    final sunset = List<dynamic>.from(daily['sunset'] ?? []);
    final uvIndexMax = List<dynamic>.from(daily['uv_index_max'] ?? []);
    final precipitationSum = List<dynamic>.from(daily['precipitation_sum'] ?? []);
    final precipitationProbMax = List<dynamic>.from(daily['precipitation_probability_max'] ?? []);
    final windSpeedMax = List<dynamic>.from(daily['wind_speed_10m_max'] ?? []);

    final forecasts = <DailyForecast>[];
    final limit = min(times.length, 16);

    for (int i = 0; i < limit; i++) {
      forecasts.add(DailyForecastModel(
        date: times[i],
        temperatureMax: maxTemps.length > i ? maxTemps[i]?.toDouble() ?? 20.0 : 20.0,
        temperatureMin: minTemps.length > i ? minTemps[i]?.toDouble() ?? 10.0 : 10.0,
        apparentTemperatureMax: apparentMaxTemps.length > i ? apparentMaxTemps[i]?.toDouble() ?? 20.0 : 20.0,
        apparentTemperatureMin: apparentMinTemps.length > i ? apparentMinTemps[i]?.toDouble() ?? 10.0 : 10.0,
        weatherCode: weatherCodes.length > i ? weatherCodes[i] ?? 0 : 0,
        sunrise: sunrise.length > i ? sunrise[i]?.toString() ?? '' : '',
        sunset: sunset.length > i ? sunset[i]?.toString() ?? '' : '',
        daylightDuration: 43200.0, // Default 12 hours
        sunshineDuration: 8.0, // Estimate
        uvIndexMax: uvIndexMax.length > i ? uvIndexMax[i]?.toDouble() ?? 5.0 : 5.0,
        precipitationSum: precipitationSum.length > i ? precipitationSum[i]?.toDouble() ?? 0.0 : 0.0,
        rainSum: precipitationSum.length > i ? precipitationSum[i]?.toDouble() ?? 0.0 : 0.0,
        snowfallSum: 0.0,
        precipitationProbabilityMax: precipitationProbMax.length > i ? precipitationProbMax[i]?.toDouble() ?? 0.0 : 0.0,
        windSpeedMax: windSpeedMax.length > i ? windSpeedMax[i]?.toDouble() ?? 10.0 : 10.0,
        windGustsMax: windSpeedMax.length > i ? (windSpeedMax[i]?.toDouble() ?? 10.0) * 1.5 : 15.0,
        evapotranspiration: 3.0,
      ));
    }

    return forecasts;
  }

  static List<HistoricalWeatherData> _parseHistoricalData(Map<String, dynamic>? historical) {
    if (historical == null || historical.isEmpty) return [];
    
    final daily = historical['daily'] ?? {};
    final times = List<String>.from(daily['time'] ?? []);
    final maxTemps = List<dynamic>.from(daily['temperature_2m_max'] ?? []);
    final minTemps = List<dynamic>.from(daily['temperature_2m_min'] ?? []);
    final precipitation = List<dynamic>.from(daily['precipitation_sum'] ?? []);
    final windSpeed = List<dynamic>.from(daily['wind_speed_10m_max'] ?? []);

    final historicalData = <HistoricalWeatherData>[];
    final limit = min(times.length, 365); // Last year of data

    for (int i = 0; i < limit; i++) {
      historicalData.add(HistoricalWeatherData(
        date: times[i],
        temperatureMax: maxTemps.length > i ? maxTemps[i]?.toDouble() ?? 20.0 : 20.0,
        temperatureMin: minTemps.length > i ? minTemps[i]?.toDouble() ?? 10.0 : 10.0,
        precipitation: precipitation.length > i ? precipitation[i]?.toDouble() ?? 0.0 : 0.0,
        windSpeed: windSpeed.length > i ? windSpeed[i]?.toDouble() ?? 10.0 : 10.0,
      ));
    }

    return historicalData;
  }

  static AirQualityData? _parseAirQualityData(Map<String, dynamic>? airQuality) {
    if (airQuality == null || airQuality.isEmpty) return null;
    
    final current = airQuality['current'] ?? {};
    
    return AirQualityData(
      pm10: current['pm10']?.toDouble() ?? 0.0,
      pm25: current['pm2_5']?.toDouble() ?? 0.0,
      ozone: current['ozone']?.toDouble() ?? 0.0,
      no2: current['nitrogen_dioxide']?.toDouble() ?? 0.0,
      co: current['carbon_monoxide']?.toDouble() ?? 0.0,
    );
  }
}

class HourlyForecastModel extends HourlyForecast {
  const HourlyForecastModel({
    required super.time,
    required super.temperature,
    required super.weatherCode,
    required super.humidity,
    required super.precipitation,
    required super.precipitationProbability,
    required super.windSpeed,
    required super.uvIndex,
    required super.soilTemperature0cm,
    required super.soilMoisture0to1cm,
  });
}

class DailyForecastModel extends DailyForecast {
  const DailyForecastModel({
    required super.date,
    required super.temperatureMax,
    required super.temperatureMin,
    required super.apparentTemperatureMax,
    required super.apparentTemperatureMin,
    required super.weatherCode,
    required super.sunrise,
    required super.sunset,
    required super.daylightDuration,
    required super.sunshineDuration,
    required super.uvIndexMax,
    required super.precipitationSum,
    required super.rainSum,
    required super.snowfallSum,
    required super.precipitationProbabilityMax,
    required super.windSpeedMax,
    required super.windGustsMax,
    required super.evapotranspiration,
  });
}
