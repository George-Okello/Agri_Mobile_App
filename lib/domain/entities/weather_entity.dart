import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  // Basic weather data
  final double temperature;
  final double temperatureMax;
  final double temperatureMin;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final double windGusts;
  final int windDirection;
  final double rainfall;
  final int humidity;
  final double uvIndex;
  final double pressure;
  final double sunshineDuration;
  
  // Agricultural specific data
  final double evapotranspiration;
  final double soilTemperature0cm;
  final double soilTemperature6cm;
  final double soilTemperature18cm;
  final double soilMoisture0to1cm;
  final double soilMoisture1to3cm;
  final double soilMoisture3to9cm;
  
  // Time data
  final String sunrise;
  final String sunset;
  final double daylightDuration;
  
  // Forecast arrays
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final String cityName;
  
  // Enhanced data for analytics
  final List<HistoricalWeatherData> historicalData;
  final AirQualityData? airQuality;
  final double elevation;
  final Map<String, dynamic> soilAnalysis;

  const WeatherEntity({
    required this.temperature,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.windGusts,
    required this.windDirection,
    required this.rainfall,
    required this.humidity,
    required this.uvIndex,
    required this.pressure,
    required this.sunshineDuration,
    required this.evapotranspiration,
    required this.soilTemperature0cm,
    required this.soilTemperature6cm,
    required this.soilTemperature18cm,
    required this.soilMoisture0to1cm,
    required this.soilMoisture1to3cm,
    required this.soilMoisture3to9cm,
    required this.sunrise,
    required this.sunset,
    required this.daylightDuration,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.cityName,
    this.historicalData = const [],
    this.airQuality,
    this.elevation = 0.0,
    this.soilAnalysis = const {},
  });

  @override
  List<Object?> get props => [
        temperature,
        temperatureMax,
        temperatureMin,
        apparentTemperature,
        weatherCode,
        windSpeed,
        windGusts,
        windDirection,
        rainfall,
        humidity,
        uvIndex,
        pressure,
        sunshineDuration,
        evapotranspiration,
        soilTemperature0cm,
        soilTemperature6cm,
        soilTemperature18cm,
        soilMoisture0to1cm,
        soilMoisture1to3cm,
        soilMoisture3to9cm,
        sunrise,
        sunset,
        daylightDuration,
        hourlyForecast,
        dailyForecast,
        cityName,
        historicalData,
        airQuality,
        elevation,
        soilAnalysis,
      ];
}

class HourlyForecast extends Equatable {
  final String time;
  final double temperature;
  final int weatherCode;
  final double humidity;
  final double precipitation;
  final double precipitationProbability;
  final double windSpeed;
  final double uvIndex;
  final double soilTemperature0cm;
  final double soilMoisture0to1cm;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.precipitation,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.uvIndex,
    required this.soilTemperature0cm,
    required this.soilMoisture0to1cm,
  });

  @override
  List<Object> get props => [
        time,
        temperature,
        weatherCode,
        humidity,
        precipitation,
        precipitationProbability,
        windSpeed,
        uvIndex,
        soilTemperature0cm,
        soilMoisture0to1cm,
      ];
}

class DailyForecast extends Equatable {
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final double apparentTemperatureMax;
  final double apparentTemperatureMin;
  final int weatherCode;
  final String sunrise;
  final String sunset;
  final double daylightDuration;
  final double sunshineDuration;
  final double uvIndexMax;
  final double precipitationSum;
  final double rainSum;
  final double snowfallSum;
  final double precipitationProbabilityMax;
  final double windSpeedMax;
  final double windGustsMax;
  final double evapotranspiration;

  const DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.apparentTemperatureMax,
    required this.apparentTemperatureMin,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.daylightDuration,
    required this.sunshineDuration,
    required this.uvIndexMax,
    required this.precipitationSum,
    required this.rainSum,
    required this.snowfallSum,
    required this.precipitationProbabilityMax,
    required this.windSpeedMax,
    required this.windGustsMax,
    required this.evapotranspiration,
  });

  @override
  List<Object> get props => [
        date,
        temperatureMax,
        temperatureMin,
        apparentTemperatureMax,
        apparentTemperatureMin,
        weatherCode,
        sunrise,
        sunset,
        daylightDuration,
        sunshineDuration,
        uvIndexMax,
        precipitationSum,
        rainSum,
        snowfallSum,
        precipitationProbabilityMax,
        windSpeedMax,
        windGustsMax,
        evapotranspiration,
      ];
}

class HistoricalWeatherData extends Equatable {
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final double precipitation;
  final double windSpeed;
  
  const HistoricalWeatherData({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitation,
    required this.windSpeed,
  });
  
  @override
  List<Object> get props => [date, temperatureMax, temperatureMin, precipitation, windSpeed];
}

class AirQualityData extends Equatable {
  final double pm10;
  final double pm25;
  final double ozone;
  final double no2;
  final double co;
  
  const AirQualityData({
    required this.pm10,
    required this.pm25,
    required this.ozone,
    required this.no2,
    required this.co,
  });
  
  @override
  List<Object> get props => [pm10, pm25, ozone, no2, co];
}