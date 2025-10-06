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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      ),
      drawer: _buildDrawer(context),
      body: widget.child,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final currentPath = widget.state.uri.path;

    return Drawer(
      child: Column(
        children: [
          // Header dengan gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.brown[700]!, Colors.brown[500]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    // Logo Cafe
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset("assets/logo.png"),
                    ),
                    const SizedBox(height: 16),
                    // Nama Cafe
                    const Text(
                      'KJM Cafe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white30, thickness: 1),
                    const SizedBox(height: 10),
                    // Profile User
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.brown[700],
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'admin@kjmcafe.com',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  path: '/dashboard',
                  isSelected: currentPath == '/dashboard',
                  onTap: () {
                    Navigator.pop(context); // Tutup drawer
                    context.go('/dashboard', extra: selectedPeriod);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_cart,
                  title: 'Order',
                  path: '/order',
                  isSelected: currentPath == '/order',
                  onTap: () {
                    Navigator.pop(context);
                    // context.go('/inventory');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Order belum tersedia'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.coffee_maker,
                  title: 'Product',
                  path: '/product',
                  isSelected: currentPath == '/product',
                  onTap: () {
                    Navigator.pop(context);
                    // context.go('/inventory');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Product belum tersedia'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Inventory',
                  path: '/inventory',
                  isSelected: currentPath == '/inventory',
                  onTap: () {
                    Navigator.pop(context);
                    // context.go('/inventory');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Inventory belum tersedia'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Menu',
                  path: '/menu',
                  isSelected: currentPath == '/menu',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/menu');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.image,
                  title: 'Gallery',
                  path: '/Gallery',
                  isSelected: currentPath == '/gallery',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Gallery belum tersedia'),
                      ),
                    );
                  },
                ),
                // _buildDrawerItem(
                //   context: context,
                //   icon: Icons.analytics_rounded,
                //   title: 'Reports',
                //   path: '/reports',
                //   isSelected: currentPath == '/reports',
                //   onTap: () {
                //     Navigator.pop(context);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Halaman Reports belum tersedia'),
                //       ),
                //     );
                //   },
                // ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  path: '/settings',
                  isSelected: currentPath == '/settings',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Settings belum tersedia'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.red[700]),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String path,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.brown[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.brown[700] : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.brown[700] : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.chevron_right, color: Colors.brown[700])
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout berhasil')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
