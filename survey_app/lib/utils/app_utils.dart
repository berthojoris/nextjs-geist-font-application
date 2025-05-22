import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences.dart';

class AppUtils {
  static const String deviceIdKey = 'device_id';
  static String? _deviceId;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get or generate a unique device identifier
  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(deviceIdKey);

    if (_deviceId == null) {
      _deviceId = await _generateDeviceId();
      await prefs.setString(deviceIdKey, _deviceId!);
    }

    return _deviceId!;
  }

  // Generate a unique device identifier based on device information
  static Future<String> _generateDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.id}_${androidInfo.model}_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    
    // Fallback if device info is not available
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Check network connectivity
  static Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Show a snackbar with custom styling
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Format timestamp for display
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
           '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  // Get appropriate padding based on device type
  static EdgeInsets getDevicePadding(BuildContext context) {
    return isTablet(context)
        ? const EdgeInsets.all(24.0)
        : const EdgeInsets.all(16.0);
  }
}
