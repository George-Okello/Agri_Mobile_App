import 'dart:async';
import '../../domain/entities/weather_entity.dart';

class WeatherCacheService {
  static final Map<String, CachedWeatherData> _cache = {};
  static final Map<String, CachedWeatherData> _enhancedCache = {};
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration enhancedCacheTimeout = Duration(hours: 2);

  String _getCacheKey(double lat, double lon) {
    return '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
  }

  bool _isCacheValid(String key, {bool enhanced = false}) {
    final cache = enhanced ? _enhancedCache : _cache;
    final timeout = enhanced ? enhancedCacheTimeout : cacheTimeout;
    final cached = cache[key];

    if (cached == null) return false;
    return DateTime.now().difference(cached.timestamp) < timeout;
  }

  WeatherEntity? getCached(double lat, double lon) {
    final key = _getCacheKey(lat, lon);
    if (_isCacheValid(key)) {
      return _cache[key]!.data;
    }
    return null;
  }

  WeatherEntity? getCachedEnhanced(double lat, double lon) {
    final key = _getCacheKey(lat, lon);
    if (_isCacheValid(key, enhanced: true)) {
      return _enhancedCache[key]!.data;
    }
    return null;
  }

  void cache(double lat, double lon, WeatherEntity data) {
    final key = _getCacheKey(lat, lon);
    _cache[key] = CachedWeatherData(data, DateTime.now());
  }

  void cacheEnhanced(double lat, double lon, WeatherEntity data) {
    final key = _getCacheKey(lat, lon);
    _enhancedCache[key] = CachedWeatherData(data, DateTime.now());
  }

  void clearExpired() {
    _cache.removeWhere(
      (key, value) =>
          DateTime.now().difference(value.timestamp) >= cacheTimeout,
    );
    _enhancedCache.removeWhere(
      (key, value) =>
          DateTime.now().difference(value.timestamp) >= enhancedCacheTimeout,
    );
  }

  void clearAll() {
    _cache.clear();
    _enhancedCache.clear();
  }

  int getCacheSize() {
    return _cache.length + _enhancedCache.length;
  }
}

class CachedWeatherData {
  final WeatherEntity data;
  final DateTime timestamp;

  CachedWeatherData(this.data, this.timestamp);
}

// Background cache maintenance
class CacheManager {
  static Timer? _cleanupTimer;

  static void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => WeatherCacheService().clearExpired(),
    );
  }

  static void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
