import 'package:flutter/material.dart';
import 'package:contractor_app/core/router/app_router.dart';
import 'package:contractor_app/core/router/app_router_holder.dart';

void main() {
  AppRouterHolder.instance.setRouter(AppRouter.router);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Contractor App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: AppRouter.router,
    );
  }
}
