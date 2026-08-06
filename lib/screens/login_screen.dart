import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// Logo
              Image.asset(
                "assets/images/logo.png",
                width: 60,
                height: 60,
              ),

              const SizedBox(height: 18),

              /// Title
              const Text(
                "مرحباً في شايل",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              const Text(
                "اكتب كلمة مرورك لتسجيل الدخول أو تبديل حسابك",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 28),

              /// Phone Label
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "رقم الهاتف",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Phone Field
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "10 234 5678",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      "🇪🇬 +20",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 90),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              /// Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0066C3),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Password Login
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff0066C3),
                    side: const BorderSide(
                      color: Color(0xff0066C3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "تسجيل دخول بكلمة المرور",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "تبديل الحساب",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff0066C3),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Text(
                "التطبيق الإصدار0.1",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}