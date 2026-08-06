import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contractor_app/core/router/route_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Background Animation
    _backgroundColor =
        ColorTween(begin: Colors.white, end: const Color(0xff0066C3)).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(.15, .85, curve: Curves.easeInOut),
          ),
        );

    // Logo Scale
    _logoScale = Tween<double>(begin: 1.5, end: .65).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.45, 1, curve: Curves.easeInOutBack),
      ),
    );

    // Name Fade
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.6, .9, curve: Curves.easeIn),
      ),
    );

    // Name Slide
    _textSlide = Tween<Offset>(begin: const Offset(0, .8), end: Offset(0, -1))
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(.7, 1, curve: Curves.easeOut),
          ),
        );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      context.go(AppRoutePaths.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget ripple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        double value = (_controller.value - delay).clamp(0.0, 1.0);

        return IgnorePointer(
          child: Container(
            width: 700 * value,
            height: 700 * value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12 * (1 - value)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Stack(
            alignment: Alignment.center,
            children: [ripple(0.0), ripple(0.18), ripple(0.36), child!],
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(
                          alpha: 0.6 * (1 - _controller.value),
                        ),
                        blurRadius: 60,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: Colors.blue.withValues(
                          alpha: 0.45 * (1 - _controller.value),
                        ),
                        blurRadius: 120,
                        spreadRadius: 35,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset("assets/images/logo.png", width: 180),
              ),
            ),

            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Image.asset("assets/images/image 18.png", width: 90),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
