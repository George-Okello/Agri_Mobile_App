import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repositories.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';
import '../datasources/weather_remote_datasource.dart';
import '../../core/services/weather_cache_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherCacheService cacheService;

  WeatherRepositoryImpl(this.remoteDataSource, this.cacheService);

  @override
  Future<Either<Failure, WeatherEntity>> getWeather(
    double lat,
    double lon,
  ) async {
    try {
      // Check cache first
      final cachedWeather = cacheService.getCached(lat, lon);
      if (cachedWeather != null) {
        return Right(cachedWeather);
      }

      // Fetch from remote data source
      final weatherModel = await remoteDataSource.getWeather(lat, lon);
      
      // Cache the result
      cacheService.cache(lat, lon, weatherModel);
      
      return Right(weatherModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } on LocationFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getEnhancedWeather(
    double lat,
    double lon,
  ) async {
    try {
      // Check cache first for enhanced weather
      final cachedWeather = cacheService.getCachedEnhanced(lat, lon);
      if (cachedWeather != null) {
        return Right(cachedWeather);
      }

      // Fetch enhanced weather data
      final weatherModel = await remoteDataSource.getEnhancedWeather(lat, lon);
      
      // Cache the enhanced result
      cacheService.cacheEnhanced(lat, lon, weatherModel);
      
      return Right(weatherModel);
    } on ServerFailure catch (failure) {
      // Fallback to basic weather if enhanced fails
      return await getWeather(lat, lon);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } on LocationFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      // Fallback to basic weather for any other error
      return await getWeather(lat, lon);
    }
  }

  @override
  Future<Either<Failure, String>> getCityName(double lat, double lon) async {
    try {
      final cityName = await remoteDataSource.getCityName(lat, lon);
      return Right(cityName);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get city name: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHistoricalWeather(
    double lat, 
    double lon
  ) async {
    try {
      final historicalData = await remoteDataSource.getHistoricalWeather(lat, lon);
      return Right(historicalData);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get historical weather: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAirQuality(
    double lat, 
    double lon
  ) async {
    try {
      final airQualityData = await remoteDataSource.getAirQuality(lat, lon);
      return Right(airQualityData);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get air quality data: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getElevation(double lat, double lon) async {
    try {
      final elevation = await remoteDataSource.getElevation(lat, lon);
      return Right(elevation);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get elevation data: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSoilData(
    double lat, 
    double lon
  ) async {
    try {
      final soilData = await remoteDataSource.getSoilData(lat, lon);
      return Right(soilData);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get soil data: $e'));
    }
  }

  // Additional utility methods for better functionality
  Future<Either<Failure, bool>> validateConnection() async {
    try {
      await remoteDataSource.getElevation(0.0, 0.0);
      return const Right(true);
    } catch (e) {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  void clearCache() {
    cacheService.clearAll();
  }

  void clearExpiredCache() {
    cacheService.clearExpired();
  }

  int getCacheSize() {
    return cacheService.getCacheSize();
  }
}