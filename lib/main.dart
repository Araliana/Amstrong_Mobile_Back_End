import 'package:flutter/material.dart';
import 'package:flutter_application_1/route.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "KJM",
      routerConfig: AppRoutes.router,
    );
  }
}
