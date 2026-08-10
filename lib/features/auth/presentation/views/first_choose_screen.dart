import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class FirstChooseScreen extends StatelessWidget {
  const FirstChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 90),

              /// Logo
              Image.asset("assets/images/logo.png", width: 60, height: 60),

              const SizedBox(height: 20),

              /// Title
              const Text(
                "مرحباً في شايل",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtitle
              const Text(
                "اكتب كلمة مرورك لتسجيل الدخول أو تبديل حسابك",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const Spacer(),

              /// Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutePaths.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0066C3),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "تسجيل الدخول",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Create Account Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    context.go(AppRoutePaths.register);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff0066C3),
                    side: const BorderSide(
                      color: Color(0xff0066C3),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "إنشاء حساب جديد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const Spacer(),

              /// Switch Account
              TextButton(
                onPressed: () {},
                child: const Text(
                  "تبديل الحساب",
                  style: TextStyle(
                    color: Color(0xff0066C3),
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "التطبيق الإصدار 0.1",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
