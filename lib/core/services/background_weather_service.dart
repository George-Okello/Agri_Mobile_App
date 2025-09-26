import 'dart:async';
import 'dart:collection';

// background_weather_service.dart
class BackgroundWeatherService {
  static Timer? _updateTimer;
  
  void startPeriodicUpdates(Function updateCallback, double lat, double lon) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => updateCallback(lat, lon),
    );
  }
  
  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}

// api_rate_limiter.dart
class APIRateLimiter {
  final Map<String, Queue<DateTime>> _requestHistory = {};
  static const int maxRequestsPerHour = 100;
  static const int maxRequestsPerMinute = 10;
  
  Future<bool> canMakeRequest(String apiName) async {
    final now = DateTime.now();
    final history = _requestHistory[apiName] ?? Queue<DateTime>();
    
    // Remove requests older than 1 hour
    while (history.isNotEmpty && now.difference(history.first).inHours >= 1) {
      history.removeFirst();
    }
    
    // Check hourly limit
    if (history.length >= maxRequestsPerHour) {
      return false;
    }
    
    // Check per-minute limit
    final recentRequests = history.where((time) => 
      now.difference(time).inMinutes < 1).length;
    
    if (recentRequests >= maxRequestsPerMinute) {
      return false;
    }
    
    history.add(now);
    _requestHistory[apiName] = history;
    return true;
  }
  
  Duration getWaitTime(String apiName) {
    final now = DateTime.now();
    final history = _requestHistory[apiName] ?? Queue<DateTime>();
    
    if (history.isEmpty) return Duration.zero;
    
    // Check if we need to wait for per-minute limit
    final recentRequests = history.where((time) => 
      now.difference(time).inMinutes < 1).toList();
    
    if (recentRequests.length >= maxRequestsPerMinute) {
      final oldestRecent = recentRequests.first;
      return Duration(seconds: 60 - now.difference(oldestRecent).inSeconds);
    }
    
    // Check if we need to wait for hourly limit
    if (history.length >= maxRequestsPerHour) {
      final oldestRequest = history.first;
      return Duration(minutes: 60 - now.difference(oldestRequest).inMinutes);
    }
    
    return Duration.zero;
  }
}

// robust_weather_service.dart
class RobustWeatherService {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 1);
  
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation,
    {int maxRetries = 3}
  ) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          rethrow;
        }
        
        // Exponential backoff
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * (1 << (attempt - 1))
        );
        
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
  
  static Future<T> executeWithFallback<T>(
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation,
  ) async {
    try {
      return await primaryOperation();
    } catch (e) {
      print('Primary operation failed: $e');
      try {
        return await fallbackOperation();
      } catch (e2) {
        print('Fallback operation failed: $e2');
        rethrow;
      }
    }
  }
}

// weather_notification_service.dart
class WeatherNotificationService {
  static const List<String> criticalConditions = [
    'extreme_temperature',
    'severe_storm',
    'flooding_risk',
    'frost_warning',
  ];
  
  static List<WeatherNotification> generateNotifications(
    Map<String, dynamic> weatherData
  ) {
    List<WeatherNotification> notifications = [];
    
    // Temperature notifications
    if (weatherData['temperatureMax'] > 40) {
      notifications.add(WeatherNotification(
        id: 'extreme_heat_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Extreme Heat Warning',
        message: 'Temperature expected to reach ${weatherData['temperatureMax']}°C',
        priority: NotificationPriority.high,
        category: 'extreme_temperature',
      ));
    }
    
    if (weatherData['temperatureMin'] < -5) {
      notifications.add(WeatherNotification(
        id: 'frost_warning_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Frost Warning',
        message: 'Minimum temperature ${weatherData['temperatureMin']}°C - Protect sensitive crops',
        priority: NotificationPriority.high,
        category: 'frost_warning',
      ));
    }
    
    // Precipitation notifications
    if (weatherData['precipitationSum'] > 50) {
      notifications.add(WeatherNotification(
        id: 'heavy_rain_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Heavy Rain Alert',
        message: '${weatherData['precipitationSum']}mm of rain expected - Check drainage',
        priority: NotificationPriority.medium,
        category: 'flooding_risk',
      ));
    }
    
    return notifications;
  }
}

class WeatherNotification {
  final String id;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String category;
  final DateTime timestamp;
  
  WeatherNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.category,
  }) : timestamp = DateTime.now();
}

enum NotificationPriority { low, medium, high, critical }

// weather_data_validator.dart
class WeatherDataValidator {
  static bool validateWeatherData(Map<String, dynamic> data) {
    if (data.isEmpty) return false;
    
    // Check required fields
    final requiredFields = ['temperature', 'humidity', 'pressure'];
    for (String field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }
    
    // Validate temperature range
    if (data['temperature'] < -50 || data['temperature'] > 60) {
      return false;
    }
    
    // Validate humidity range
    if (data['humidity'] < 0 || data['humidity'] > 100) {
      return false;
    }
    
    // Validate pressure range
    if (data['pressure'] < 800 || data['pressure'] > 1100) {
      return false;
    }
    
    return true;
  }
  
  static Map<String, dynamic> sanitizeWeatherData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    // Clamp values to reasonable ranges
    if (sanitized['temperature'] != null) {
      sanitized['temperature'] = (sanitized['temperature'] as double).clamp(-50.0, 60.0);
    }
    
    if (sanitized['humidity'] != null) {
      sanitized['humidity'] = (sanitized['humidity'] as int).clamp(0, 100);
    }
    
    if (sanitized['pressure'] != null) {
      sanitized['pressure'] = (sanitized['pressure'] as double).clamp(800.0, 1100.0);
    }
    
    if (sanitized['windSpeed'] != null) {
      sanitized['windSpeed'] = (sanitized['windSpeed'] as double).clamp(0.0, 200.0);
    }
    
    return sanitized;
  }
}

// weather_analytics_service.dart
class WeatherAnalyticsService {
  static Map<String, dynamic> calculateWeatherTrends(
    List<Map<String, dynamic>> historicalData
  ) {
    if (historicalData.isEmpty) {
      return {'error': 'No data available'};
    }
    
    // Calculate temperature trend
    final temperatures = historicalData
        .map((data) => data['temperature'] as double?)
        .where((temp) => temp != null)
        .map((temp) => temp!)
        .toList();
    
    double avgTemperature = temperatures.isNotEmpty 
        ? temperatures.reduce((a, b) => a + b) / temperatures.length 
        : 0.0;
    
    // Calculate precipitation trend
    final precipitations = historicalData
        .map((data) => data['precipitation'] as double?)
        .where((precip) => precip != null)
        .map((precip) => precip!)
        .toList();
    
    double avgPrecipitation = precipitations.isNotEmpty 
        ? precipitations.reduce((a, b) => a + b) / precipitations.length 
        : 0.0;
    
    return {
      'averageTemperature': avgTemperature,
      'averagePrecipitation': avgPrecipitation,
      'dataPoints': historicalData.length,
      'temperatureRange': temperatures.isNotEmpty 
          ? {'min': temperatures.reduce((a, b) => a < b ? a : b), 
             'max': temperatures.reduce((a, b) => a > b ? a : b)}
          : {'min': 0, 'max': 0},
    };
  }
  
  static List<String> generateInsights(Map<String, dynamic> trends) {
    List<String> insights = [];
    
    if (trends['averageTemperature'] > 25) {
      insights.add('Higher than average temperatures detected');
    }
    
    if (trends['averagePrecipitation'] > 100) {
      insights.add('Above normal precipitation levels');
    } else if (trends['averagePrecipitation'] < 25) {
      insights.add('Below normal precipitation - consider irrigation');
    }
    
    return insights;
  }
}