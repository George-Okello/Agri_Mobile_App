import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/dl/Injection.dart';
import 'presentation/pages/weather_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  setupDependencyInjection();
  
  // Configure system UI for premium look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations (optional - remove if you want landscape support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const AgriculturalWeatherApp());
}

class AgriculturalWeatherApp extends StatelessWidget {
  const AgriculturalWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agricultural Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'San Francisco',
        scaffoldBackgroundColor: Colors.transparent,
        // Enhanced theme configuration for premium look
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        // Custom app bar theme for consistency
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        // Splash and highlight colors
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
      ),
      home: WeatherPage(),
    );
  }
}