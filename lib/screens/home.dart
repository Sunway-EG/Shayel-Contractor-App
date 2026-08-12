import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xff0066C3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "الطلبات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: "الدعم",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "الحساب",
          ),
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(color: Color(0xff0066C3)),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: SizedBox(
                                height: 50,
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/Frame 157.png",
                                  ),
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),

                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 60),

                        Text(
                          "القائمة المفضلة",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: _QuickCard(
                                icon: Icons.receipt_long_outlined,
                                title: "رحلات انتهت",
                              ),
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: _QuickCard(
                                icon: Icons.route_outlined,
                                title: "رحلات جاهزة",
                              ),
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: _QuickCard(
                                icon: Icons.menu_book_outlined,
                                title: "طلبات الرحلات",
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        Text(
                          "مراجعة الرحلات",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Image(
                                    image: AssetImage(
                                      "assets/images/Icons.png",
                                    ),
                                    width: 200,
                                    height: 200,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  "لا توجد رحلة بعد",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 1),

                                Text(
                                  "!أنت بانتظار موافقة المسؤول",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 70,
              left: 10,
              right: 10,
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 90,
              left: 20,
              // right: 10,
              child: Container(
                width: 370,
                height: 80,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffFFFBEB),
                  border: Border.all(color: const Color(0xffFCD34D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  " يرجى البقاء في هذه الصفحة حتى يتم إكمال المراجعة.تستغرق خلال ساعتين ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .08), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff0066C3)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
