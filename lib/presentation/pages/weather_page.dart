import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../widgets/weather_card.dart';
import '../../core/dl/Injection.dart';

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
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
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
                        transform: GradientRotation(_backgroundAnimation.value * 2 * 3.14159),
                        colors: const [
                          Color(0xFF1a237e), // Deep blue
                          Color(0xFF3949ab), // Indigo  
                          Color(0xFF5e35b1), // Deep purple
                          Color(0xFF7e57c2), // Purple
                          Color(0xFF2e7d32), // Forest green
                          Color(0xFF4CAF50), // Green
                          Color(0xFF388e3c), // Dark green
                          Color(0xFF66BB6A), // Light green
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles background
                        ...List.generate(25, (index) => _buildFloatingParticle(index)),
                        
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
                        transform: GradientRotation(_backgroundAnimation.value * 2 * 3.14159),
                        colors: const [
                          Color(0xFF1a237e), // Deep blue
                          Color(0xFF3949ab), // Indigo  
                          Color(0xFF5e35b1), // Deep purple
                          Color(0xFF7e57c2), // Purple
                          Color(0xFF2e7d32), // Forest green
                          Color(0xFF4CAF50), // Green
                          Color(0xFF388e3c), // Dark green
                          Color(0xFF66BB6A), // Light green
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles background
                        ...List.generate(25, (index) => _buildFloatingParticle(index)),
                        
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
                      transform: GradientRotation(_backgroundAnimation.value * 2 * 3.14159),
                      colors: const [
                        Color(0xFF1a237e), // Deep blue
                        Color(0xFF3949ab), // Indigo  
                        Color(0xFF5e35b1), // Deep purple
                        Color(0xFF7e57c2), // Purple
                        Color(0xFF2e7d32), // Forest green
                        Color(0xFF4CAF50), // Green
                        Color(0xFF388e3c), // Dark green
                        Color(0xFF66BB6A), // Light green
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated particles background
                      ...List.generate(25, (index) => _buildFloatingParticle(index)),
                      
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
    final size = (index % 4 + 1) * 2.0;
    final speed = (index % 5 + 1) * 0.3;
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value * speed) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalOffset = (index * 47) % screenWidth;
        
        return Positioned(
          left: horizontalOffset.toDouble(),
          top: screenHeight * progress - 100,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 8,
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
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  scale: 0.8 + (value * 0.2),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.green.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading Agricultural Data...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Getting your location and weather conditions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
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
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(0.3),
                    Colors.red.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                _getErrorIcon(message),
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Weather',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
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