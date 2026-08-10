import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contractor_app/core/router/route_constants.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreen2State();
}

class _OnBoardingScreen2State extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/images/Frame 157.png", height: 50),
                  Image.asset("assets/images/image 18.png", height: 50),
                  const SizedBox(width: 50),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutePaths.firstChoose);
                    },
                    child: const Text(
                      "تخطي",
                      style: TextStyle(
                        color: Color(0xff005AA9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => _dot(index == currentPage),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 200,
                          child: Container(
                            width: 220,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withValues(alpha: .5),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          "assets/images/content.png",
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 200,
                          child: Container(
                            width: 220,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withValues(alpha: .5),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          "assets/images/Container.png",
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage == 0) {
                      // لو في أول صفحة روح للثانية
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // لو في آخر صفحة افتح شاشة التسجيل
                      context.go(AppRoutePaths.firstChoose);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0066C3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "متابعة",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xff0066C3) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
