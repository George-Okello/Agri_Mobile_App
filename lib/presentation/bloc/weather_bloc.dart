import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/usecases/get_weather_usecase.dart' as weather_usecase;
import '../../domain/usecases/get_enhanced_weather_usecase.dart';
import '../../core/error/failures.dart';
import '../../core/services/location_services.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final weather_usecase.GetWeatherUseCase getWeatherUseCase;
  final GetEnhancedWeatherUseCase getEnhancedWeatherUseCase;

  WeatherBloc({
    required this.getWeatherUseCase,
    required this.getEnhancedWeatherUseCase,
  }) : super(WeatherInitial()) {
    on<GetWeatherForCurrentLocation>(_onGetWeatherForCurrentLocation);
    on<GetWeatherForCoordinates>(_onGetWeatherForCoordinates);
    on<GetEnhancedWeatherForCurrentLocation>(_onGetEnhancedWeatherForCurrentLocation);
    on<GetEnhancedWeatherForCoordinates>(_onGetEnhancedWeatherForCoordinates);
    on<RefreshWeather>(_onRefreshWeather);
  }

  Future<void> _onGetWeatherForCurrentLocation(
    GetWeatherForCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final locationResult = await LocationService.getCurrentLocation();

      if (emit.isDone) return;

      if (locationResult.isLeft) {
        emit(WeatherError(locationResult.left.message));
        return;
      }

      final position = locationResult.right;

      final weatherResult = await getWeatherUseCase(
        weather_usecase.WeatherParams(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      if (emit.isDone) return;

      if (weatherResult.isLeft) {
        emit(WeatherError(_mapFailureToMessage(weatherResult.left)));
      } else {
        emit(WeatherLoaded(weatherResult.right));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(WeatherError('Unexpected error: $e'));
      }
    }
  }

  Future<void> _onGetWeatherForCoordinates(
    GetWeatherForCoordinates event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final result = await getWeatherUseCase(
        weather_usecase.WeatherParams(
          latitude: event.latitude, 
          longitude: event.longitude
        ),
      );

      if (emit.isDone) return;

      if (result.isLeft) {
        emit(WeatherError(_mapFailureToMessage(result.left)));
      } else {
        emit(WeatherLoaded(result.right));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(WeatherError('Unexpected error: $e'));
      }
    }
  }

  Future<void> _onGetEnhancedWeatherForCurrentLocation(
    GetEnhancedWeatherForCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final locationResult = await LocationService.getCurrentLocation();

      if (emit.isDone) return;

      if (locationResult.isLeft) {
        emit(WeatherError(locationResult.left.message));
        return;
      }

      final position = locationResult.right;

      final weatherResult = await getEnhancedWeatherUseCase(
        weather_usecase.WeatherParams(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      if (emit.isDone) return;

      if (weatherResult.isLeft) {
        emit(WeatherError(_mapFailureToMessage(weatherResult.left)));
      } else {
        emit(WeatherLoaded(weatherResult.right));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(WeatherError('Unexpected error: $e'));
      }
    }
  }

  Future<void> _onGetEnhancedWeatherForCoordinates(
    GetEnhancedWeatherForCoordinates event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final result = await getEnhancedWeatherUseCase(
        weather_usecase.WeatherParams(
          latitude: event.latitude, 
          longitude: event.longitude
        ),
      );

      if (emit.isDone) return;

      if (result.isLeft) {
        emit(WeatherError(_mapFailureToMessage(result.left)));
      } else {
        emit(WeatherLoaded(result.right));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(WeatherError('Unexpected error: $e'));
      }
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherLoaded) {
      emit(WeatherLoading());
    }

    try {
      final params = weather_usecase.WeatherParams(
        latitude: event.latitude, 
        longitude: event.longitude
      );

      final result = event.enhanced 
          ? await getEnhancedWeatherUseCase(params)
          : await getWeatherUseCase(params);

      if (emit.isDone) return;

      if (result.isLeft) {
        if (state is WeatherLoaded) {
          return;
        }
        emit(WeatherError(_mapFailureToMessage(result.left)));
      } else {
        emit(WeatherLoaded(result.right));
      }
    } catch (e) {
      if (!emit.isDone) {
        if (state is! WeatherLoaded) {
          emit(WeatherError('Unexpected error: $e'));
        }
      }
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case LocationFailure:
        return (failure as LocationFailure).message;
      default:
        return 'Unexpected error occurred';
    }
  }
}