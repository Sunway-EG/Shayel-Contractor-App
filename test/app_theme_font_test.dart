import 'package:contractor_app/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('global app theme uses the Zain font family', () {
    final materialTheme = buildMaterialTheme();
    final cupertinoTheme = buildAppTheme();

    expect(materialTheme.textTheme.bodyLarge?.fontFamily, 'Zain');
    expect(cupertinoTheme.textTheme.textStyle.fontFamily, 'Zain');
  });
}
