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
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
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
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
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
                transform: GradientRotation(_backgroundAnimation.value * 2 * 3.14159),
                colors: const [
                  Color(0xFF1a237e), // Deep blue
                  Color(0xFF3949ab), // Indigo
                  Color(0xFF5e35b1), // Deep purple
                  Color(0xFF2e7d32), // Forest green
                  Color(0xFF388e3c), // Green
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated particles background
                ...List.generate(20, (index) => _buildFloatingParticle(index)),
                
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
    final size = (index % 3 + 1) * 1.5;
    final speed = (index % 3 + 1) * 0.3;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final progress = (_backgroundAnimation.value * speed) % 1.0;
        return Positioned(
          left: (index * 30) % 350,
          top: 600 * progress - 50,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
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

  Widget _buildPremiumHeader(String dayName, String dateFormatted) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          dayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
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
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              dateFormatted,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
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
        children: [
          // Animated weather icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + (_pulseAnimation.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    WeatherIcons.getWeatherIcon(widget.forecast.weatherCode),
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Weather description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              WeatherIcons.getWeatherDescription(widget.forecast.weatherCode),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          
          // Temperature range with premium styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTemperatureTile(
                'High',
                '${widget.forecast.temperatureMax.round()}°',
                Colors.orange.withOpacity(0.3),
                FontWeight.w700,
              ),
              Container(
                height: 60,
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildTemperatureTile(
                'Low',
                '${widget.forecast.temperatureMin.round()}°',
                Colors.blue.withOpacity(0.3),
                FontWeight.w400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTile(String label, String value, Color color, FontWeight weight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
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
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.3),
                        Colors.cyan.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
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
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeFormat,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        WeatherIcons.getWeatherIcon(hourlyForecast.weatherCode),
                        size: 28,
                        color: Colors.white,
                      ),
                      Text(
                        '${hourlyForecast.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.4),
                      Colors.green.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Agricultural Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Creative accordion-style layout
          _buildCollapsibleInsightCard(
            Icons.agriculture,
            'Field Operations Today',
            _getFieldConditions(widget.forecast.weatherCode),
            Colors.green.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _buildCollapsibleInsightCard(
            Icons.water_drop,
            'Irrigation Management',
            _getIrrigationAdvice(widget.forecast.weatherCode),
            Colors.blue.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _buildCollapsibleInsightCard(
            Icons.local_florist,
            'Crop Protection & Care',
            _getPlantCareAdvice(widget.forecast.weatherCode),
            Colors.orange.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleInsightCard(IconData icon, String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header section - no Row, uses Stack for perfect positioning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Content section - uses flexible Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                height: 1.4,
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
        return 'Optimal for harvesting, tillage, and heavy machinery. Soil compaction risk low. Ideal for pesticide/herbicide application.';
      case 2:
      case 3:
        return 'Good for most field work. Monitor soil moisture before heavy equipment use. Spray operations viable until cloud increases.';
      case 45:
      case 48:
        return 'Reduce spray operations - fog reduces effectiveness. Delay harvest if possible. Fungal disease pressure increasing.';
      case 51:
      case 53:
      case 55:
        return 'Light machinery only. Postpone harvest and spraying. Monitor for lodging in tall crops. Check drainage systems.';
      case 61:
      case 63:
      case 65:
        return 'Avoid all field operations. High soil compaction risk. Delay planting/harvest minimum 24-48hrs after rain stops.';
      case 71:
      case 73:
      case 75:
        return 'Protect sensitive crops with row covers. Check livestock water systems. Prepare for potential crop damage assessment.';
      case 80:
      case 81:
      case 82:
        return 'Secure loose equipment. Check irrigation systems for damage. Monitor for soil erosion in sloped fields.';
      case 95:
      case 96:
      case 99:
        return 'Emergency shelter for livestock. Inspect crops for hail damage afterward. Document damage for insurance claims.';
      default:
        return 'Monitor local conditions closely. Consult weather radar before starting field operations. Safety first.';
    }
  }

  String _getIrrigationAdvice(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return 'Increase irrigation frequency. High evaporation rates. Check soil moisture at 6-8 inch depth. Morning irrigation preferred.';
      case 2:
      case 3:
        return 'Moderate irrigation needs. Monitor crop stress signs. Partial cloud cover reduces water demand by 15-20%.';
      case 45:
      case 48:
        return 'Reduce irrigation by 30%. High humidity reduces plant water stress. Risk of overwatering and root diseases.';
      case 51:
      case 53:
      case 55:
        return 'Pause irrigation systems. Natural moisture provided. Resume based on soil moisture testing in 48-72 hours.';
      case 61:
      case 63:
      case 65:
        return 'Turn off all irrigation. Expect 0.5-1.5 inches of natural water. Check soil saturation before resuming.';
      case 71:
      case 73:
      case 75:
        return 'Shut down irrigation to prevent freeze damage. Snow provides 0.1 inch water per inch of snow when melted.';
      case 80:
      case 81:
      case 82:
        return 'Emergency shutdown of irrigation systems. Check for equipment damage. Expect significant water input from storms.';
      default:
        return 'Monitor soil moisture levels. Adjust irrigation based on current soil conditions and crop stage requirements.';
    }
  }

  String _getPlantCareAdvice(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return 'Monitor for heat stress in sensitive crops. Apply mulch to retain moisture. Check for pest activity increase.';
      case 2:
      case 3:
        return 'Optimal growing conditions. Good time for fertilizer application. Monitor crop development stages closely.';
      case 45:
      case 48:
        return 'Increase fungicide applications. Poor air circulation promotes disease. Delay fruit/vegetable harvesting if possible.';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return 'High disease pressure expected. Scout for fungal infections. Improve field drainage. Support tall crops against lodging.';
      case 71:
      case 73:
      case 75:
        return 'Cover tender plants immediately. Move potted plants to shelter. Check antifreeze systems for livestock water.';
      case 80:
      case 81:
      case 82:
        return 'Stake tall plants. Harvest ready crops immediately. Prepare emergency livestock shelter and secure equipment.';
      case 95:
      case 96:
      case 99:
        return 'Emergency crop protection. Move livestock to covered areas. Prepare for hail damage assessment and replanting decisions.';
      default:
        return 'Continue regular crop monitoring. Adjust management practices based on weather patterns and crop growth stage.';
    }
  }
}