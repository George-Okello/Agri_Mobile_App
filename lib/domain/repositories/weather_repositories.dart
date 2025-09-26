// domain/repositories/weather_repositories.dart
import '../../domain/entities/weather_entity.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getWeather(double lat, double lon);
  Future<Either<Failure, WeatherEntity>> getEnhancedWeather(
    double lat,
    double lon,
  );
  Future<Either<Failure, String>> getCityName(double lat, double lon);
  Future<Either<Failure, Map<String, dynamic>>> getHistoricalWeather(
    double lat,
    double lon,
  );
  Future<Either<Failure, Map<String, dynamic>>> getAirQuality(
    double lat,
    double lon,
  );
  Future<Either<Failure, double>> getElevation(double lat, double lon);
  Future<Either<Failure, Map<String, dynamic>>> getSoilData(
    double lat,
    double lon,
  );
}
