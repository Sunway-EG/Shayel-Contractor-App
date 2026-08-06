import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/home.dart';
import '../../screens/login_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/signin_screen.dart';
import '../../screens/splash_screen.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutePaths.splash,
    routes: [
      GoRoute(
        path: AppRoutePaths.splash,
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        builder: (context, _) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.signin,
        builder: (context, _) => const SigninScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, _) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final isAuthenticated = false;

      final authRoutes = <String>{
        AppRoutePaths.splash,
        AppRoutePaths.onboarding,
        AppRoutePaths.signin,
        AppRoutePaths.login,
      };

      if (!isAuthenticated && !authRoutes.contains(location)) {
        return AppRoutePaths.signin;
      }

      if (isAuthenticated && authRoutes.contains(location)) {
        return AppRoutePaths.home;
      }

      return null;
    },
    errorBuilder: (context, state) => _ErrorScreen(state.error?.toString()),
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xff0066C3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            context.go(AppRoutePaths.home);
          } else {
            // TODO: Register the remaining shell destinations when their screens exist.
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'الدعم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message ?? 'Something went wrong.'),
        ),
      ),
    );
  }
}
