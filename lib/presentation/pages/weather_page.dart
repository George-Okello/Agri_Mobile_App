import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../widgets/weather_card.dart';
import '../../core/dl/_injection.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl.get<WeatherBloc>()..add(const GetWeatherForCurrentLocation()),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return Scaffold(
              body: AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(_backgroundAnimation.value * 0.3),
                        colors: const [
                          Color(0xFF0D4F3C), // Deep forest green
                          Color(0xFF1B5E20), // Dark green
                          Color(0xFF2E7D32), // Forest green
                          Color(0xFF388E3C), // Medium green
                          Color(0xFF4A5C16), // Olive green
                          Color(0xFF33691E), // Light forest green
                          Color(0xFF689F38), // Agriculture green
                          Color(0xFF7CB342), // Lighter agriculture green
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles background
                        ...List.generate(18, (index) => _buildFloatingParticle(index)),
                        
                        // Main content
                        SafeArea(child: _buildLoadingState()),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is WeatherLoaded) {
            return WeatherCard(weather: state.weather);
          } else if (state is WeatherError) {
            return Scaffold(
              body: AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(_backgroundAnimation.value * 0.3),
                        colors: const [
                          Color(0xFF0D4F3C), // Deep forest green
                          Color(0xFF1B5E20), // Dark green
                          Color(0xFF2E7D32), // Forest green
                          Color(0xFF388E3C), // Medium green
                          Color(0xFF4A5C16), // Olive green
                          Color(0xFF33691E), // Light forest green
                          Color(0xFF689F38), // Agriculture green
                          Color(0xFF7CB342), // Lighter agriculture green
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles background
                        ...List.generate(18, (index) => _buildFloatingParticle(index)),
                        
                        // Main content
                        SafeArea(child: _buildErrorState(context, state.message)),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return Scaffold(
            body: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      transform: GradientRotation(_backgroundAnimation.value * 0.3),
                      colors: const [
                        Color(0xFF0D4F3C), // Deep forest green
                        Color(0xFF1B5E20), // Dark green
                        Color(0xFF2E7D32), // Forest green
                        Color(0xFF388E3C), // Medium green
                        Color(0xFF4A5C16), // Olive green
                        Color(0xFF33691E), // Light forest green
                        Color(0xFF689F38), // Agriculture green
                        Color(0xFF7CB342), // Lighter agriculture green
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated particles background
                      ...List.generate(18, (index) => _buildFloatingParticle(index)),
                      
                      // Main content
                      SafeArea(child: _buildLoadingState()),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final size = (index % 3 + 1) * 1.8;
    final speed = (index % 4 + 1) * 0.4;
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value * speed) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalOffset = (index * 42) % screenWidth;
        
        return Positioned(
          left: horizontalOffset.toDouble(),
          top: screenHeight * progress - 100,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.03),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(36),
        margin: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated agriculture icon
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.85 + (value * 0.15),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading Farm Weather Data...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Getting your location and agricultural conditions',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE57373).withValues(alpha: 0.3),
                    const Color(0xFFD32F2F).withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _getErrorIcon(message),
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Farm Data',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WeatherBloc>().add(
                  const GetWeatherForCurrentLocation(),
                );
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(String message) {
    if (message.toLowerCase().contains('location') ||
        message.toLowerCase().contains('permission') ||
        message.toLowerCase().contains('gps')) {
      return Icons.location_off;
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet')) {
      return Icons.wifi_off;
    }
    return Icons.error_outline;
  }
}