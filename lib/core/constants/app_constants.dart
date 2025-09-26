class AppConstants {
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';
  
  // Weather codes mapping
  static const Map<int, String> weatherCodes = {
    0: 'clear',
    1: 'mainly_clear',
    2: 'partly_cloudy',
    3: 'overcast',
    45: 'fog',
    48: 'depositing_rime_fog',
    51: 'drizzle_light',
    53: 'drizzle_moderate',
    55: 'drizzle_dense',
    61: 'rain_slight',
    63: 'rain_moderate',
    65: 'rain_heavy',
    71: 'snow_slight',
    73: 'snow_moderate',
    75: 'snow_heavy',
    95: 'thunderstorm',
    96: 'thunderstorm_hail_slight',
    99: 'thunderstorm_hail_heavy',
  };
}