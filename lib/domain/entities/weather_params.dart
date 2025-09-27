class WeatherParams {
  final double latitude;
  final double longitude;

  WeatherParams({required this.latitude, required this.longitude});

  @override
  String toString() => 'WeatherParams(latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherParams &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
