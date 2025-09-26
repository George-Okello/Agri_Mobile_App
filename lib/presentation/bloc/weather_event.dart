part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class GetWeatherForCurrentLocation extends WeatherEvent {
  const GetWeatherForCurrentLocation();
}

class GetWeatherForCoordinates extends WeatherEvent {
  final double latitude;
  final double longitude;

  const GetWeatherForCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class GetEnhancedWeatherForCurrentLocation extends WeatherEvent {
  const GetEnhancedWeatherForCurrentLocation();
}

class GetEnhancedWeatherForCoordinates extends WeatherEvent {
  final double latitude;
  final double longitude;

  const GetEnhancedWeatherForCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class RefreshWeather extends WeatherEvent {
  final double latitude;
  final double longitude;
  final bool enhanced;

  const RefreshWeather({
    required this.latitude,
    required this.longitude,
    this.enhanced = false,
  });

  @override
  List<Object> get props => [latitude, longitude, enhanced];
}