import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/weather_icons.dart';

class DailyWeatherModal extends StatefulWidget {
  final DailyForecast forecast;
  final List<HourlyForecast> hourlyData;

  const DailyWeatherModal({
    super.key,
    required this.forecast,
    required this.hourlyData,
  });

  @override
  State<DailyWeatherModal> createState() => _DailyWeatherModalState();
}

class _DailyWeatherModalState extends State<DailyWeatherModal>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.forecast.date);
    final dayName = DateFormat('EEEE').format(date);
    final dateFormatted = DateFormat('MMMM d, y').format(date);
    
    // Filter hourly data for this specific day
    final dayHourlyData = widget.hourlyData.where((hourly) {
      final hourlyDate = DateTime.parse(hourly.time);
      return hourlyDate.day == date.day && 
             hourlyDate.month == date.month && 
             hourlyDate.year == date.year;
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
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
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle floating particles
                ...List.generate(12, (index) => _buildFloatingParticle(index)),
                
                // Main content
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Header
                      _buildPremiumHeader(dayName, dateFormatted),
                      
                      // Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildMainWeatherSection(),
                              const SizedBox(height: 24),
                              if (dayHourlyData.isNotEmpty) 
                                _buildHourlyForecastSection(dayHourlyData),
                              const SizedBox(height: 24),
                              _buildAgriculturalInsightsSection(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
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
    final size = (index % 2 + 1) * 1.2;
    final speed = (index % 3 + 1) * 0.3;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final progress = (_backgroundAnimation.value * speed) % 1.0;
        return Positioned(
          left: (index * 35) % 350,
          top: 600 * progress - 50,
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

  Widget _buildPremiumHeader(String dayName, String dateFormatted) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50).withValues(alpha: 0.3),
                              const Color(0xFF2E7D32).withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          dayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Text(
              dateFormatted,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherSection() {
    return Container(
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
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
          // Weather icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.92 + (_pulseAnimation.value * 0.08),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    WeatherIcons.getWeatherIcon(widget.forecast.weatherCode),
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Weather description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              WeatherIcons.getWeatherDescription(widget.forecast.weatherCode),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          
          // Temperature range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTemperatureTile(
                'High',
                '${widget.forecast.temperatureMax.round()}°',
                const Color(0xFFFF7043).withValues(alpha: 0.25),
                FontWeight.w700,
              ),
              Container(
                height: 50,
                width: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTemperatureTile(
                'Low',
                '${widget.forecast.temperatureMin.round()}°',
                const Color(0xFF42A5F5).withValues(alpha: 0.25),
                FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTile(String label, String value, Color color, FontWeight weight) {
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
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: weight,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastSection(List<HourlyForecast> dayHourlyData) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF26C6DA).withValues(alpha: 0.25),
                        const Color(0xFF00ACC1).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 110,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dayHourlyData.length,
              itemBuilder: (context, index) {
                final hourlyForecast = dayHourlyData[index];
                final time = DateTime.parse(hourlyForecast.time);
                final timeFormat = DateFormat('HH:mm').format(time);
                
                return Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeFormat,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        WeatherIcons.getWeatherIcon(hourlyForecast.weatherCode),
                        size: 26,
                        color: Colors.white,
                      ),
                      Text(
                        '${hourlyForecast.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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

  Widget _buildAgriculturalInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Farm Management Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInsightCard(
            Icons.agriculture,
            'Field Operations Today',
            _getFieldConditions(widget.forecast.weatherCode),
            const Color(0xFF4CAF50).withValues(alpha: 0.25),
          ),
          const SizedBox(height: 10),
          _buildInsightCard(
            Icons.water_drop,
            'Irrigation Management',
            _getIrrigationAdvice(widget.forecast.weatherCode),
            const Color(0xFF42A5F5).withValues(alpha: 0.25),
          ),
          const SizedBox(height: 10),
          _buildInsightCard(
            Icons.local_florist,
            'Crop Protection & Care',
            _getPlantCareAdvice(widget.forecast.weatherCode),
            const Color(0xFFFF7043).withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String description, Color color) {
    return Container(
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
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldConditions(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return 'Optimal conditions for harvesting, tillage, and heavy machinery operations. Low soil compaction risk. Ideal timing for pesticide and herbicide applications.';
      case 2:
      case 3:
        return 'Good conditions for most field operations. Monitor soil moisture before using heavy equipment. Spray operations viable until cloud cover increases.';
      case 45:
      case 48:
        return 'Reduce spray operations due to fog reducing effectiveness. Consider delaying harvest if possible. Monitor for increased fungal disease pressure.';
      case 51:
      case 53:
      case 55:
        return 'Light machinery only recommended. Postpone harvest and spraying operations. Monitor crops for lodging risk. Check field drainage systems.';
      case 61:
      case 63:
      case 65:
        return 'Avoid all field operations due to high soil compaction risk. Delay planting or harvest for minimum 24-48 hours after rain stops.';
      case 71:
      case 73:
      case 75:
        return 'Protect sensitive crops with row covers. Check livestock water systems for freezing. Prepare for potential crop damage assessment.';
      case 80:
      case 81:
      case 82:
        return 'Secure loose equipment and materials. Check irrigation systems for potential damage. Monitor for soil erosion in sloped fields.';
      case 95:
      case 96:
      case 99:
        return 'Emergency shelter for livestock required. Inspect crops for hail damage post-storm. Document any damage for insurance claims.';
      default:
        return 'Monitor local conditions closely. Consult weather radar before starting field operations. Prioritize safety in all activities.';
    }
  }

  String _getIrrigationAdvice(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return 'Increase irrigation frequency due to high evaporation rates. Check soil moisture at 6-8 inch depth. Morning irrigation is preferred.';
      case 2:
      case 3:
        return 'Moderate irrigation needs expected. Monitor for crop stress signs. Partial cloud cover reduces water demand by 15-20%.';
      case 45:
      case 48:
        return 'Reduce irrigation by 30% due to high humidity reducing plant water stress. Risk of overwatering and root diseases.';
      case 51:
      case 53:
      case 55:
        return 'Pause irrigation systems temporarily. Natural moisture being provided. Resume based on soil moisture testing in 48-72 hours.';
      case 61:
      case 63:
      case 65:
        return 'Turn off all irrigation systems. Expect 0.5-1.5 inches of natural water input. Check soil saturation before resuming operations.';
      case 71:
      case 73:
      case 75:
        return 'Emergency shutdown of irrigation to prevent freeze damage. Snow provides approximately 0.1 inch water per inch when melted.';
      case 80:
      case 81:
      case 82:
        return 'Emergency shutdown of all irrigation systems. Check equipment for storm damage. Expect significant water input from heavy rain.';
      default:
        return 'Monitor soil moisture levels carefully. Adjust irrigation schedules based on current soil conditions and crop growth stage.';
    }
  }

  String _getPlantCareAdvice(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return 'Monitor crops for heat stress symptoms. Apply mulch to retain soil moisture. Check for increased pest activity in warm conditions.';
      case 2:
      case 3:
        return 'Optimal growing conditions present. Good timing for fertilizer applications. Monitor crop development stages closely.';
      case 45:
      case 48:
        return 'Increase fungicide applications due to poor air circulation promoting disease. Consider delaying fruit and vegetable harvesting.';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return 'High disease pressure expected. Scout for fungal infections regularly. Improve field drainage. Support tall crops against lodging.';
      case 71:
      case 73:
      case 75:
        return 'Cover tender plants immediately. Move potted plants to protected areas. Check antifreeze systems for livestock water supplies.';
      case 80:
      case 81:
      case 82:
        return 'Stake tall plants for wind protection. Harvest ready crops immediately. Prepare emergency livestock shelter and secure equipment.';
      case 95:
      case 96:
      case 99:
        return 'Emergency crop protection measures needed. Move livestock to covered areas. Prepare for hail damage assessment and replanting decisions.';
      default:
        return 'Continue regular crop monitoring routines. Adjust management practices based on weather patterns and current crop growth stage.';
    }
  }
}