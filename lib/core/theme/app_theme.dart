import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sun-Way design system theme.
/// English and Arabic now use the Zain font family globally.
ThemeData buildMaterialTheme([
  String? languageCode,
  Brightness brightness = Brightness.light,
]) {
  final base = ThemeData(
    brightness: brightness,
    fontFamily: 'Zain',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Zain'),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Zain'),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
            fontFamily: 'Zain',
          ) ??
          const TextStyle(fontFamily: 'Zain'),
      toolbarTextStyle: base.appBarTheme.toolbarTextStyle?.copyWith(
            fontFamily: 'Zain',
          ) ??
          const TextStyle(fontFamily: 'Zain'),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      titleTextStyle: base.dialogTheme.titleTextStyle?.copyWith(
            fontFamily: 'Zain',
          ) ??
          const TextStyle(fontFamily: 'Zain'),
    ),
  );
}

CupertinoThemeData buildAppTheme([String? languageCode]) {
  return CupertinoThemeData(
    primaryColor: AppColors.mainBlue,
    primaryContrastingColor: AppColors.white,
    barBackgroundColor: AppColors.mainBlue,
    brightness: Brightness.light,
    textTheme: _buildTextTheme('Zain'),
  );
}

CupertinoTextThemeData _buildTextTheme(String fontFamily) {
  final base = const CupertinoTextThemeData();

  return CupertinoTextThemeData(
    navTitleTextStyle: base.navTitleTextStyle.copyWith(
      fontFamily: fontFamily,
      color: AppColors.mainBlue,
    ),
    navLargeTitleTextStyle: base.navLargeTitleTextStyle.copyWith(
      fontFamily: fontFamily,
      color: AppColors.mainBlue,
      fontWeight: FontWeight.w700,
    ),
    textStyle: base.textStyle.copyWith(
      fontFamily: fontFamily,
      color: AppColors.mainBlue,
    ),
    actionTextStyle: base.actionTextStyle.copyWith(
      fontFamily: fontFamily,
      color: AppColors.mainBlue,
    ),
    tabLabelTextStyle: base.tabLabelTextStyle.copyWith(fontFamily: fontFamily),
    navActionTextStyle: base.navActionTextStyle.copyWith(
      fontFamily: fontFamily,
      color: AppColors.white,
    ),
    pickerTextStyle: base.pickerTextStyle.copyWith(fontFamily: fontFamily),
    dateTimePickerTextStyle: base.dateTimePickerTextStyle.copyWith(
      fontFamily: fontFamily,
    ),
  );
}
