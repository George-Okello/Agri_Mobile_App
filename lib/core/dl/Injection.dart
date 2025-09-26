import 'package:http/http.dart' as http;
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repositories.dart';
import '../../domain/usecases/get_weather_usecase.dart' as weather_usecase;
import '../../domain/usecases/get_enhanced_weather_usecase.dart';
import '../../presentation/bloc/weather_bloc.dart';
import '../../core/services/weather_cache_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  void register<T>(T service) {
    _services[T] = service;
  }

  void unregister<T>() {
    _services.remove(T);
  }

  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  void disposeAll() {
    for (final service in _services.values) {
      if (service is Disposable) {
        service.dispose();
      }
    }
    _services.clear();
  }
}

// Interface for disposable services
abstract class Disposable {
  void dispose();
}

final sl = ServiceLocator();

void setupDependencyInjection() {
  // Core services
  sl.register<http.Client>(http.Client());
  sl.register<WeatherCacheService>(WeatherCacheService());

  // Data sources
  sl.register<WeatherRemoteDataSource>(
    WeatherRemoteDataSourceImpl(sl.get<http.Client>()),
  );

  // Repositories
  sl.register<WeatherRepository>(
    WeatherRepositoryImpl(
      sl.get<WeatherRemoteDataSource>(),
      sl.get<WeatherCacheService>(),
    ),
  );

  // Use cases
  sl.register<weather_usecase.GetWeatherUseCase>(
    weather_usecase.GetWeatherUseCase(sl.get<WeatherRepository>()),
  );

  sl.register<GetEnhancedWeatherUseCase>(
    GetEnhancedWeatherUseCase(sl.get<WeatherRepository>()),
  );

  // Bloc
  sl.register<WeatherBloc>(
    WeatherBloc(
      getWeatherUseCase: sl.get<weather_usecase.GetWeatherUseCase>(),
      getEnhancedWeatherUseCase: sl.get<GetEnhancedWeatherUseCase>(),
    ),
  );
}

// Call this when your app shuts down to clean up resources
void disposeDependencies() {
  sl.disposeAll();
}