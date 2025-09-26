import 'package:flutter/material.dart';
import '../../core/services/location_services.dart';

class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WeatherErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(_getErrorIcon(), size: 64, color: Colors.white70),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_isLocationError()) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (message.contains('permanently denied') ||
                                message.contains('settings')) {
                              await LocationService.openAppSettings();
                            } else {
                              await LocationService.openLocationSettings();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (_isLocationError()) {
      return Icons.location_off;
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet')) {
      return Icons.wifi_off;
    }
    return Icons.error_outline;
  }

  bool _isLocationError() {
    return message.toLowerCase().contains('location') ||
        message.toLowerCase().contains('permission') ||
        message.toLowerCase().contains('gps');
  }
}
