import '../entities/weather_entity.dart';
import '../repositories/weather_repositories.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;
  GetWeatherUseCase(this.repository);
  Future<Either<Failure, WeatherEntity>> call(WeatherParams params) async {
    return await repository.getWeather(params.latitude, params.longitude);
  }
}

class WeatherParams {
  final double latitude;
  final double longitude;
  WeatherParams({required this.latitude, required this.longitude});
  @override
  String toString() => 'WeatherParams(latitude: $latitude, longitude: $longitude)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherParams && other.latitude == latitude && other.longitude == longitude;
  }
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}