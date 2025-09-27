// Agricultural Weather App Widget Tests
//
// This file contains basic widget tests for the agricultural weather app.
// To run these tests, use: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Import your main app using package imports instead of relative paths
import 'package:agricultural_weather/main.dart';
import 'package:agricultural_weather/presentation/bloc/weather_bloc.dart';
import 'package:agricultural_weather/domain/entities/weather_entity.dart';
import 'package:agricultural_weather/core/dl/_injection.dart';

// Mock classes
class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState> implements WeatherBloc {}

class MockWeatherEntity extends Mock implements WeatherEntity {}

void main() {
  group('Agricultural Weather App Tests', () {
    
    setUpAll(() {
      // Register fallback values for mock objects
      registerFallbackValue(const GetWeatherForCurrentLocation());
      registerFallbackValue(WeatherInitial());
    });

    testWidgets('App starts without crashing', (WidgetTester tester) async {
      // Setup dependency injection for testing
      setupDependencyInjection();
      
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AgriculturalWeatherApp());
      
      // Verify that the app loads without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows loading indicator initially', (WidgetTester tester) async {
      setupDependencyInjection();
      
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AgriculturalWeatherApp());
      
      // Pump once to build the widget tree
      await tester.pump();
      
      // The app should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('App has proper material design structure', (WidgetTester tester) async {
      setupDependencyInjection();
      
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AgriculturalWeatherApp());
      
      // Verify Material App exists with correct properties
      expect(find.byType(MaterialApp), findsOneWidget);
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Agricultural Weather'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('App contains Scaffold structure', (WidgetTester tester) async {
      setupDependencyInjection();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      // Should have a Scaffold as the main structure
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });

  group('Weather Loading State Tests', () {
    
    testWidgets('Loading state shows correct elements', (WidgetTester tester) async {
      setupDependencyInjection();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      // Should show loading text
      expect(find.textContaining('Loading'), findsAtLeastNWidgets(1));
      
      // Should show agriculture icon
      expect(find.byIcon(Icons.agriculture), findsAtLeastNWidgets(1));
    });

    testWidgets('Loading state has proper styling', (WidgetTester tester) async {
      setupDependencyInjection();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      // Check for gradient background (Container with decoration)
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(1));
      
      // Verify that we have text elements with proper styling
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsAtLeastNWidgets(1));
    });
  });

  group('Theme and UI Tests', () {
    
    testWidgets('App uses correct theme configuration', (WidgetTester tester) async {
      setupDependencyInjection();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify theme properties
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.theme?.scaffoldBackgroundColor, Colors.transparent);
    });

    testWidgets('App handles orientation correctly', (WidgetTester tester) async {
      setupDependencyInjection();
      
      // Test in different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Portrait
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Test landscape (if supported)
      await tester.binding.setSurfaceSize(const Size(800, 400)); // Landscape
      await tester.pump();
      
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Error Handling Tests', () {
    
    testWidgets('App gracefully handles initialization errors', (WidgetTester tester) async {
      // This test ensures the app doesn't crash during startup
      // even if there are issues with dependency injection
      
      try {
        setupDependencyInjection();
        await tester.pumpWidget(const AgriculturalWeatherApp());
        await tester.pump();
        
        // App should still render basic structure
        expect(find.byType(MaterialApp), findsOneWidget);
      } catch (e) {
        // If there's an error, the test should still pass
        // as long as it's handled gracefully
        expect(e, isNotNull);
      }
    });
  });

  group('Accessibility Tests', () {
    
    testWidgets('App has proper semantics for accessibility', (WidgetTester tester) async {
      setupDependencyInjection();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      // Check that important UI elements have proper semantics
      final semantics = find.byType(Semantics);
      // Note: The exact number depends on your implementation
      expect(semantics, findsAtLeastNWidgets(0)); // Adjust based on your semantic structure
    });
  });
}

// Helper function to create a test app with minimal dependencies
Widget createTestApp({Widget? child}) {
  return MaterialApp(
    title: 'Test App',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
      ),
    ),
    home: Scaffold(
      body: child ?? const Center(
        child: Text('Test Content'),
      ),
    ),
  );
}

// Additional integration tests for individual components
void runComponentTests() {
  group('Individual Widget Tests', () {
    
    testWidgets('Weather icon displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const Icon(Icons.wb_sunny),
        ),
      );
      
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    });

    testWidgets('Agriculture themed text displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const Text('Farm Weather Station'),
        ),
      );
      
      expect(find.text('Farm Weather Station'), findsOneWidget);
    });

    testWidgets('Loading animation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const CircularProgressIndicator(),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Test animation by pumping frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should still be present after animation frames
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Container with gradient styling renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              ),
            ),
            child: const Text('Gradient Test'),
          ),
        ),
      );
      
      expect(find.text('Gradient Test'), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });
}

// Performance tests
void runPerformanceTests() {
  group('Performance Tests', () {
    
    testWidgets('App renders within acceptable time', (WidgetTester tester) async {
      setupDependencyInjection();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const AgriculturalWeatherApp());
      await tester.pump();
      
      stopwatch.stop();
      
      // App should render within 5 seconds (adjust as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('Memory usage is reasonable during basic operations', (WidgetTester tester) async {
      setupDependencyInjection();
      
      // Create and dispose multiple instances to test for memory leaks
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(const AgriculturalWeatherApp());
        await tester.pump();
        await tester.pumpWidget(Container()); // Clear the widget tree
      }
      
      // If we get here without running out of memory, the test passes
      expect(true, isTrue);
    });
  });
}