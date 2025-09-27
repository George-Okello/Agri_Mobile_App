import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(double lat, double lon);
  Future<WeatherModel> getEnhancedWeather(double lat, double lon);
  Future<String> getCityName(double lat, double lon);
  Future<Map<String, dynamic>> getHistoricalWeather(double lat, double lon);
  Future<Map<String, dynamic>> getAirQuality(double lat, double lon);
  Future<double> getElevation(double lat, double lon);
  Future<Map<String, dynamic>> getSoilData(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSourceImpl(this.client);

  @override
  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final cityName = await getCityName(lat, lon);

      final url = Uri.parse(
        '${AppConstants.baseUrl}/forecast?'
        'latitude=$lat&longitude=$lon&'
        'forecast_days=16&'
        'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,'
        'weather_code,surface_pressure,wind_speed_10m,wind_direction_10m,uv_index&'
        'hourly=temperature_2m,relative_humidity_2m,precipitation,precipitation_probability,'
        'weather_code,wind_speed_10m,uv_index&'
        'daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,'
        'apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,'
        'precipitation_probability_max,wind_speed_10m_max&'
        'timezone=auto',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return WeatherModel.fromJson(jsonResponse, cityName);
      } else {
        throw ServerFailure('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ServerFailure('Failed to fetch weather data: $e');
    }
  }

  @override
  Future<WeatherModel> getEnhancedWeather(double lat, double lon) async {
    try {
      final futures = await Future.wait([
        _getWeatherForecast(lat, lon),
        getHistoricalWeather(lat, lon).catchError((e) => <String, dynamic>{}),
        getAirQuality(lat, lon).catchError((e) => <String, dynamic>{}),
        getElevation(lat, lon).catchError((e) => 0.0),
        getSoilData(lat, lon).catchError((e) => <String, dynamic>{}),
        getCityName(lat, lon),
      ]);

      final weatherData = futures[0] as Map<String, dynamic>;
      final historicalData = futures[1] as Map<String, dynamic>;
      final airQualityData = futures[2] as Map<String, dynamic>;
      final elevation = futures[3] as double;
      final soilData = futures[4] as Map<String, dynamic>;
      final cityName = futures[5] as String;

      return WeatherModel.fromEnhancedJson(
        weatherData,
        historicalData,
        airQualityData,
        elevation,
        soilData,
        cityName,
      );
    } catch (e) {
      return await getWeather(lat, lon);
    }
  }

  Future<Map<String, dynamic>> _getWeatherForecast(double lat, double lon) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}/forecast?'
      'latitude=$lat&longitude=$lon&'
      'forecast_days=16&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,'
      'weather_code,surface_pressure,wind_speed_10m,wind_direction_10m,uv_index&'
      'hourly=temperature_2m,relative_humidity_2m,precipitation,precipitation_probability,'
      'weather_code,wind_speed_10m,uv_index&'
      'daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,'
      'apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,'
      'precipitation_probability_max,wind_speed_10m_max&'
      'timezone=auto',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerFailure('Weather forecast API Error ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoricalWeather(double lat, double lon) async {
    try {
      final endDate = DateTime.now().subtract(const Duration(days: 1));
      final startDate = endDate.subtract(const Duration(days: 365));

      final url = Uri.parse(
        'https://archive-api.open-meteo.com/v1/archive?'
        'latitude=$lat&longitude=$lon&'
        'start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&'
        'end_date=${DateFormat('yyyy-MM-dd').format(endDate)}&'
        'daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max&'
        'timezone=auto',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerFailure('Historical weather API Error ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure('Failed to fetch historical weather data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAirQuality(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?'
        'latitude=$lat&longitude=$lon&'
        'current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone&'
        'timezone=auto',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerFailure('Air quality API Error ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure('Failed to fetch air quality data: $e');
    }
  }

  @override
  Future<double> getElevation(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/elevation?'
        'latitude=$lat&longitude=$lon',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['elevation'][0]?.toDouble() ?? 0.0;
      } else {
        throw ServerFailure('Elevation API Error ${response.statusCode}');
      }
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<Map<String, dynamic>> getSoilData(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}/forecast?'
        'latitude=$lat&longitude=$lon&'
        'daily=soil_temperature_0cm,soil_temperature_6cm,soil_temperature_18cm,'
        'soil_moisture_0_1cm,soil_moisture_1_3cm,soil_moisture_3_9cm&'
        'forecast_days=16&'
        'timezone=auto',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerFailure('Soil data API Error ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure('Failed to fetch soil data: $e');
    }
  }

  @override
  Future<String> getCityName(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=$lat&lon=$lon&format=json&accept-language=en',
      );

      final response = await client.get(
        url,
        headers: {
          'User-Agent': 'WeatherApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final displayName = jsonResponse['display_name'] as String?;
        final address = jsonResponse['address'] as Map<String, dynamic>?;

        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              '';

          final state = address['state'] ?? '';
          final country = address['country'] ?? '';

          if (city.isNotEmpty) {
            if (state.isNotEmpty && country.isNotEmpty) {
              return '$city, $state, $country';
            } else if (country.isNotEmpty) {
              return '$city, $country';
            } else {
              return city;
            }
          }

          if (displayName != null && displayName.isNotEmpty) {
            final parts = displayName.split(', ');
            if (parts.length >= 2) {
              return '${parts[0]}, ${parts[parts.length - 1]}';
            }
            return parts[0];
          }
        }
      }

      return await _tryAlternativeGeocoding(lat, lon);
    } catch (e) {
      return await _tryAlternativeGeocoding(lat, lon);
    }
  }

  Future<String> _tryAlternativeGeocoding(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?'
        'latitude=$lat&longitude=$lon&localityLanguage=en',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final city = jsonResponse['city'] ??
            jsonResponse['locality'] ??
            jsonResponse['principalSubdivision'] ??
            '';
        final country = jsonResponse['countryName'] ?? '';

        if (city.isNotEmpty && country.isNotEmpty) {
          return '$city, $country';
        } else if (city.isNotEmpty) {
          return city;
        }
      }
    } catch (e) {
      // ignore
    }

    return _formatCoordinates(lat, lon);
  }

  String _formatCoordinates(double lat, double lon) {
    final latDirection = lat >= 0 ? 'N' : 'S';
    final lonDirection = lon >= 0 ? 'E' : 'W';

    return '${lat.abs().toStringAsFixed(2)}°$latDirection, ${lon.abs().toStringAsFixed(2)}°$lonDirection';
  }
}
