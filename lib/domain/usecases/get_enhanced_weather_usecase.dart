import '../entities/weather_entity.dart';
import '../repositories/weather_repositories.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';
import 'get_weather_usecase.dart'; // Import to access WeatherParams

class GetEnhancedWeatherUseCase {
  final WeatherRepository repository;

  GetEnhancedWeatherUseCase(this.repository);

  Future<Either<Failure, WeatherEntity>> call(WeatherParams params) async {
    return await repository.getEnhancedWeather(params.latitude, params.longitude);
  }
}