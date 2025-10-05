import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screen/menu/index.dart';
import 'package:flutter_application_1/screen/dashboard/index.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            _AppShell(child: child, state: state),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              final selectedPeriod = state.extra as String? ?? 'Hari Ini';
              return DashboardPage(selectedPeriod: selectedPeriod);
            },
          ),
          GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
        ],
      ),
    ],
    initialLocation: '/dashboard',
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
                context.go('/menu');
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Widget untuk wrapper AppBar dan Drawer
class _AppShell extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const _AppShell({required this.child, required this.state});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  String selectedPeriod = 'Hari Ini';

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    // AppBar dinamis
    switch (widget.state.uri.path) {
      case '/dashboard':
        actions = [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedPeriod,
              dropdownColor: Colors.brown[700],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Tahun Ini']
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPeriod = newValue;
                  });

                  // kirim value ke DashboardPage via GoRouter extra
                  context.go('/dashboard', extra: newValue);
                }
              },
            ),
          ),
        ];
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KJM Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  "KJM Navigation",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => context.go('/dashboard', extra: selectedPeriod),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Menu"),
              onTap: () => context.go('/menu'),
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
