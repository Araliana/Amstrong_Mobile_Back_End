import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screen/menu/index.dart';

class AppRoutes {
  // routerConfig untuk MaterialApp.router
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text("Page Not Found"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              "404 - Page not found",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Halaman tidak tersedia.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text("Kembali ke Menu"),
              onPressed: () {
                context.go('/menu'); // ganti pushReplacementNamed
              },
            ),
          ],
        ),
      ),
    ),
  );
}
