import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/weather_icons.dart';
import 'daily_weather_modal.dart';
import '../pages/weather_graphs_page.dart';

class WeatherCard extends StatefulWidget {
  final WeatherEntity weather;

  const WeatherCard({super.key, required this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showDailyWeatherModal(DailyForecast forecast) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext context) {
        return DailyWeatherModal(
          forecast: forecast,
          hourlyData: widget.weather.hourlyForecast,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_backgroundAnimation.value * 0.5),
                colors: const [
                  Color(0xFF0D4F3C), // Deep forest green
                  Color(0xFF1B5E20), // Dark green
                  Color(0xFF2E7D32), // Forest green
                  Color(0xFF388E3C), // Medium green
                  Color(0xFF4A5C16), // Olive green
                  Color(0xFF33691E), // Light forest green
                  Color(0xFF689F38), // Agriculture green
                ],
              ),
            ),
            child: Stack(
              children: [
                // Subtle floating particles
                ...List.generate(15, (index) => _buildFloatingParticle(index)),
                
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildMainWeatherCard(),
                          const SizedBox(height: 16),
                          _buildAgricultureSummary(),
                          const SizedBox(height: 16),
                          _buildHourlyForecast(),
                          const SizedBox(height: 16),
                          _buildDetailedConditions(),
                          const SizedBox(height: 16),
                          _buildWeeklyForecast(),
                          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final size = (index % 2 + 1) * 1.5;
    final speed = (index % 3 + 1) * 0.4;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final progress = (_backgroundAnimation.value * speed) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        
        return Positioned(
          left: (index * 45) % screenWidth,
          top: screenHeight * progress - 50,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
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

  Widget _buildMainWeatherCard() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Location with agricultural branding
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50).withValues(alpha: 0.3),
                              const Color(0xFF2E7D32).withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.weather.cityName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Text(
                                      'Farm Weather Station',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Temperature display
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0, end: widget.weather.temperature),
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()}°',
                      style: const TextStyle(
                        fontSize: 88,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        height: 0.9,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Weather description
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    WeatherIcons.getWeatherDescription(widget.weather.weatherCode),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Feels like and high/low
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Feels like ${widget.weather.apparentTemperature.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: 1,
                      height: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Text(
                      'H:${widget.weather.temperatureMax.round()}° L:${widget.weather.temperatureMin.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Weather icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.85 + (_pulseAnimation.value * 0.15),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          WeatherIcons.getWeatherIcon(widget.weather.weatherCode),
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgricultureSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.25),
                      const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Soil & Environmental Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPremiumFarmTile(
                  icon: Icons.thermostat,
                  title: 'Soil Temperature',
                  value: '${widget.weather.soilTemperature0cm.round()}°C',
                  subtitle: 'Surface layer',
                  color: const Color(0xFFFF7043).withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumFarmTile(
                  icon: Icons.water_drop,
                  title: 'Soil Moisture',
                  value: '${(widget.weather.soilMoisture0to1cm * 100).round()}%',
                  subtitle: '0-1cm depth',
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPremiumFarmTile(
                  icon: Icons.eco,
                  title: 'Evapotranspiration',
                  value: '${widget.weather.evapotranspiration.toStringAsFixed(1)}mm',
                  subtitle: 'Water loss rate',
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumFarmTile(
                  icon: Icons.wb_sunny,
                  title: 'Growing Hours',
                  value: '${(widget.weather.daylightDuration / 3600).toStringAsFixed(1)}h',
                  subtitle: 'Daylight period',
                  color: const Color(0xFFFFCA28).withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFarmTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white60,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemCount: widget.weather.hourlyForecast.length > 24 ? 24 : widget.weather.hourlyForecast.length,
              itemBuilder: (context, index) {
                final forecast = widget.weather.hourlyForecast[index];
                final time = DateTime.parse(forecast.time);
                final timeFormat = DateFormat('HH:mm').format(time);
                
                return Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: index == 0 ? 0.25 : 0.12),
                        Colors.white.withValues(alpha: index == 0 ? 0.15 : 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: index == 0 ? 0.3 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        index == 0 ? 'Now' : timeFormat,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        WeatherIcons.getWeatherIcon(forecast.weatherCode),
                        size: 24,
                        color: Colors.white,
                      ),
                      Text(
                        '${forecast.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${forecast.precipitationProbability.round()}%',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedConditions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Environmental Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.air,
                  title: 'Wind Speed',
                  value: '${widget.weather.windSpeed.toStringAsFixed(1)} km/h',
                  color: const Color(0xFF26C6DA).withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.water_drop,
                  title: 'Humidity',
                  value: '${widget.weather.humidity}%',
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.wb_sunny,
                  title: 'UV Index',
                  value: widget.weather.uvIndex.toStringAsFixed(1),
                  color: const Color(0xFFFF7043).withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.compress,
                  title: 'Pressure',
                  value: '${widget.weather.pressure.round()} hPa',
                  color: const Color(0xFF8E24AA).withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                '7-Day Farm Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.weather.dailyForecast.take(7).map((forecast) {
            final date = DateTime.parse(forecast.date);
            final dayFormat = DateFormat('EEE, MMM d').format(date);
            final isToday = date.day == DateTime.now().day && 
                           date.month == DateTime.now().month && 
                           date.year == DateTime.now().year;
            
            return GestureDetector(
              onTap: () => _showDailyWeatherModal(forecast),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isToday 
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.12),
                      isToday 
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isToday 
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        isToday ? 'Today' : dayFormat,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      WeatherIcons.getWeatherIcon(forecast.weatherCode),
                      size: 22,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${forecast.precipitationProbabilityMax.round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${forecast.temperatureMin.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${forecast.temperatureMax.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildSmartAnalyticsButton(),
        ],
      ),
    );
  }

  Widget _buildSmartAnalyticsButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.99 + (_pulseAnimation.value * 0.01),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedWeatherGraphsPage(weather: widget.weather),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    const Color(0xFF1B5E20).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farm Intelligence Hub',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Advanced crop analytics, irrigation planning & yield forecasting',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}