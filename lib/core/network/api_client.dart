import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'auth_screen_guard.dart';
import '../router/app_router_holder.dart';
import '../storage/auth_storage.dart';
import '../services/fcm_service.dart';
import 'app_update_interceptor.dart';

/// Base URL for driver API (override via --dart-define=DRIVER_API_BASE_URL=... in release).
const String kDriverApiBaseUrl = String.fromEnvironment(
  'DRIVER_API_BASE_URL',
  // defaultValue: 'https://api-agg.sunway-eg.com/api/driver',
  defaultValue: 'https://stg-api-agg.sunway-eg.com/api/driver',
);

/// Shared API root (e.g. `https://…/api`) for endpoints outside `/driver`.
String get kApiBaseUrl {
  const suffix = '/driver';
  if (kDriverApiBaseUrl.endsWith(suffix)) {
    return kDriverApiBaseUrl.substring(
      0,
      kDriverApiBaseUrl.length - suffix.length,
    );
  }
  return kDriverApiBaseUrl;
}

/// Dio interceptor that adds authentication token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthStorage.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Paths where 401 means "invalid credentials" (user is trying to auth).
  /// Do NOT redirect - let the UI show the error inline.
  static const _authAttemptPaths = [
    '/auth/login',
    '/auth/send-login-otp',
    '/auth/login-with-otp',
    '/auth/forget-password',
    '/auth/reset-password',
    '/auth/reset-password-with-code',
    '/auth/send-mfa-code',
    '/auth/verify-mfa',
    '/auth/verify-email',
    '/auth/resend-verification',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path.split('?').first;
      final isAuthAttempt = _authAttemptPaths.any(
        (p) => path == p || path.startsWith('$p/'),
      );

      // Only redirect when token expired on protected endpoints.
      // Skip redirect when user is on an auth screen (e.g. OTP) so opening
      // notification center / app resume doesn't trigger a 401 and send them to login.
      final onAuthScreen = AuthScreenGuard.isOnAuthScreen;
      if (!isAuthAttempt && !onAuthScreen) {
        AuthStorage.instance.clearTokens();

        final router = AppRouterHolder.instance.router;
        if (router != null) {
          Future.microtask(() {
            try {
              router.go('/login');
            } catch (e) {
              debugPrint('Failed to redirect to login on 401: $e');
            }
          });
        }
      }
    }
    handler.next(err);
  }
}

/// Dio interceptor that adds language header based on current locale.
/// RTL (Arabic) -> lang: ar for all APIs. LTR (English) -> lang: en.
class LanguageInterceptor extends Interceptor {
  static const String _localeKey = 'app_locale';

  /// Returns 'ar' for RTL/Arabic, 'en' otherwise.
  static String _langFromLocale(String? localeCode) {
    if (localeCode == null || localeCode.isEmpty) return 'ar'; // App default
    final code = localeCode.toLowerCase().split('_').first;
    return code == 'ar' ? 'ar' : 'en';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      options.headers['lang'] = _langFromLocale(localeCode);
    } catch (_) {
      options.headers['lang'] = 'ar';
    }
    handler.next(options);
  }
}

/// Dio interceptor that adds FCM token to request headers
class FcmTokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final fcmService = FCMService();
      final fcmToken = fcmService.currentToken;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        options.headers['fcmToken'] = fcmToken;
      }
    } catch (e) {
      // If FCM token is not available, continue without it
      debugPrint('Failed to get FCM token for header: $e');
    }
    handler.next(options);
  }
}

/// Dio interceptor that adds device information to request headers
class DeviceInterceptor extends Interceptor {
  static DeviceInfo? _cachedDeviceInfo;
  static PackageInfo? _cachedPackageInfo;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get device info (cached for performance)
      _cachedDeviceInfo ??= await _getDeviceInfo();

      // Get package info (cached for performance)
      _cachedPackageInfo ??= await PackageInfo.fromPlatform();

      final deviceInfo = _cachedDeviceInfo!;
      final packageInfo = _cachedPackageInfo!;

      // Add device headers
      options.headers['device-id'] = deviceInfo.deviceId;
      options.headers['device-model'] = deviceInfo.deviceModel;
      options.headers['device-os'] = deviceInfo.platform;
      options.headers['device-os-version'] = deviceInfo.osVersion;
      options.headers['app-version'] = packageInfo.version;
      options.headers['app-build-number'] = packageInfo.buildNumber;
    } catch (e) {
      // If device info fails, continue without device headers
      // Log error but don't block the request
      debugPrint('Failed to get device info: $e');
    }
    handler.next(options);
  }

  static Future<DeviceInfo> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return DeviceInfo(
          deviceId: androidInfo.id,
          deviceModel: androidInfo.model,
          platform: 'Android',
          osVersion: androidInfo.version.release,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return DeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? 'unknown',
          deviceModel: iosInfo.model,
          platform: 'iOS',
          osVersion: iosInfo.systemVersion,
        );
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        return DeviceInfo(
          deviceId: 'macos-${macInfo.computerName}',
          deviceModel: macInfo.model,
          platform: 'macOS',
          osVersion: macInfo.osRelease,
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        return DeviceInfo(
          deviceId: windowsInfo.deviceId,
          deviceModel: windowsInfo.computerName,
          platform: 'Windows',
          osVersion: windowsInfo.displayVersion,
        );
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        return DeviceInfo(
          deviceId: linuxInfo.machineId ?? 'unknown',
          deviceModel: linuxInfo.prettyName,
          platform: 'Linux',
          osVersion: linuxInfo.version ?? 'unknown',
        );
      } else {
        // Fallback for web or unknown platforms
        return DeviceInfo(
          deviceId: 'unknown',
          deviceModel: 'unknown',
          platform: 'unknown',
          osVersion: 'unknown',
        );
      }
    } catch (e) {
      // Return fallback device info if platform calls fail
      debugPrint('Failed to get device info: $e');
      return DeviceInfo(
        deviceId: 'unknown',
        deviceModel: 'unknown',
        platform: 'unknown',
        osVersion: 'unknown',
      );
    }
  }
}

/// Device information model
class DeviceInfo {
  final String deviceId;
  final String deviceModel;
  final String platform;
  final String osVersion;

  DeviceInfo({
    required this.deviceId,
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
  });
}

/// Dio instance for driver API with interceptors.
Dio createDriverApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kDriverApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.add(DeviceInterceptor());
  dio.interceptors.add(LanguageInterceptor());
  dio.interceptors.add(FcmTokenInterceptor());
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(AppUpdateInterceptor());
  dio.interceptors.add(ChuckerDioInterceptor());
  return dio;
}
