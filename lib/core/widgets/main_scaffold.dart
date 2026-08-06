import 'package:flutter/cupertino.dart';

/// Lightweight wrapper used by auth screens when a scaffold-like container
/// is expected by the migrated Shayel auth UI.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
