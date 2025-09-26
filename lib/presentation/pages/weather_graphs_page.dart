import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/weather_icons.dart';
import '../../core/utils/agricultural_calculations.dart';
import 'tabs/crop_growth_tab.dart';
import 'tabs/irrigation_tab.dart';
import 'tabs/disease_risk_tab.dart';
import 'tabs/field_operations_tab.dart';
import 'tabs/yield_prediction_tab.dart';
import 'tabs/livestock_tab.dart';

class EnhancedWeatherGraphsPage extends StatefulWidget {
  final WeatherEntity weather;

  const EnhancedWeatherGraphsPage({super.key, required this.weather});

  @override
  State<EnhancedWeatherGraphsPage> createState() =>
      _EnhancedWeatherGraphsPageState();
}

class _EnhancedWeatherGraphsPageState extends State<EnhancedWeatherGraphsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CropGrowthTab(weather: widget.weather),
                    IrrigationTab(weather: widget.weather),
                    DiseaseRiskTab(weather: widget.weather),
                    FieldOperationsTab(weather: widget.weather),
                    YieldPredictionTab(weather: widget.weather),
                    LivestockTab(weather: widget.weather),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Smart Farm Analytics Hub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Crop Growth'),
          Tab(text: 'Irrigation'),
          Tab(text: 'Disease Risk'),
          Tab(text: 'Operations'),
          Tab(text: 'Yield Forecast'),
          Tab(text: 'Livestock'),
        ],
      ),
    );
  }
}
