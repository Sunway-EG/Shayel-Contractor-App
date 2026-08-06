import 'dart:io' show Platform;

/// Store listing URLs for opening the update flow in the platform store.
abstract final class AppStoreConfig {
  static const androidPackageId = 'com.shayel.driver';

  static const iosAppStoreId = String.fromEnvironment('IOS_APP_STORE_ID');

  static const huaweiAppGalleryId = String.fromEnvironment(
    'HUAWEI_APP_GALLERY_ID',
  );

  static const storeDistribution = String.fromEnvironment(
    'APP_STORE_DISTRIBUTION',
    defaultValue: 'play',
  );

  static const storeUrlOverride = String.fromEnvironment('APP_STORE_URL');

  static bool get isHarmonyOsDistribution {
    final value = storeDistribution.toLowerCase();
    return value == 'harmonyos' || value == 'appgallery';
  }

  static String get storeUrl {
    if (storeUrlOverride.isNotEmpty) {
      return storeUrlOverride;
    }
    if (Platform.isIOS && iosAppStoreId.isNotEmpty) {
      return 'https://apps.apple.com/app/id$iosAppStoreId';
    }
    if (isHarmonyOsDistribution && huaweiAppGalleryId.isNotEmpty) {
      return 'https://appgallery.huawei.com/app/C$huaweiAppGalleryId';
    }
    return 'https://play.google.com/store/apps/details?id=$androidPackageId';
  }
}
