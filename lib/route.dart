import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/provider/auth_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/screen/access/index.dart';
import 'package:flutter_application_1/screen/gallery/index.dart';
import 'package:flutter_application_1/screen/login/index.dart';
import 'package:flutter_application_1/screen/product/index.dart';
import 'package:flutter_application_1/screen/role/addEdit.dart';
import 'package:flutter_application_1/screen/role/index.dart';
import 'package:flutter_application_1/screen/userAdmin/index.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screen/menu/index.dart';
import 'package:flutter_application_1/screen/dashboard/index.dart';
import 'package:flutter_application_1/screen/profile/index.dart';
import 'package:provider/provider.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
  analytics: analytics,
);

class AppRoute {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      redirect: (context, state) {
        if (!authProvider.isLoggedIn) return '/login';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        ShellRoute(
          observers: [observer],
          builder: (context, state, child) =>
              _AppShell(state: state, child: child),
          routes: [
            //MAIN
            GoRoute(
              path: '/',
              builder: (context, state) {
                final selectedPeriod = state.extra as String? ?? 'Hari Ini';
                return DashboardScreen(selectedPeriod: selectedPeriod);
              },
            ),
            //ORDERS
            //PRODUCTS & STOCK
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductPage(),
            ),
            //FINANCE
            //CONTENT & MEDIA
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuPage(),
            ),
            //MANAGEMENT
            GoRoute(
              path: '/user-admin',
              builder: (context, state) => const UserAdminScreen(),
            ),
            GoRoute(
              path: '/roles',
              builder: (context, state) => const RoleScreen(),
            ),
            GoRoute(
              path: '/add-edit-role',
              builder: (context, state) {
                final id = state.extra as int?;

                return AddEditRoleScreen(roleId: id);
              },
            ),

            GoRoute(
              path: '/accesses',
              builder: (context, state) => const AccessScreen(),
            ),

            GoRoute(
              path: '/gallery',
              builder: (context, state) => const GalleryScreen(),
            ),
          ],
        ),
      ],
      initialLocation: '/',
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text("Page Not Found"), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.redAccent,
              ),
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
                label: const Text("Kembali ke Dashboard"),
                onPressed: () {
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    // AppBar dinamis
    switch (widget.state.uri.path) {
      case '/':
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
                  context.go('/', extra: newValue);
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Logo Cafe dengan Settings Button
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset("assets/logo.png"),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              top: -12,
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.go("/");
                                  },
                                  splashColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  highlightColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                      ],
                    ),
                  ),
                  // Profile User Section - Padding horizontal 10
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/profile');
                        },
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          child: Row(
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
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // MAIN MENU
                _buildMenuCategory('MAIN'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  path: '/',
                  isSelected: currentPath == '/',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/', extra: selectedPeriod);
                  },
                ),

                FutureBuilder<Map<String, List<Access>>>(
                  future: groupAccessesByCategory(context),
                  builder: (context, snapshot) {
                    // Loading State
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading menu...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty State
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_open,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Menu Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'There are no menu items to display.\nPlease contact administrator.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Close Drawer'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Success State - Display Menu
                    final data = sortAccess(snapshot.data!);

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.map((entry) {
                          final category = entry.key;
                          final accesses = entry.value;

                          accesses.sort(
                            (a, b) => (a.idSort).compareTo(b.idSort),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMenuCategory(category),
                              ...accesses.map(
                                (access) => _buildDrawerItem(
                                  context: context,
                                  icon: access.icon,
                                  title: access.name,
                                  path: access.accessPath,
                                  isSelected: currentPath == access.accessPath,
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.go(access.accessPath);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                Divider(height: 2, indent: 16, endIndent: 16),

                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  path: '/logout',
                  isSelected: false,
                  isLogout: true,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
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
    bool isLogout = false,
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
          color: isLogout
              ? Colors.red[700]
              : (isSelected ? Colors.brown[700] : Colors.grey[600]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red[700]
                : (isSelected ? Colors.brown[700] : Colors.grey[800]),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      //TODO save dark theme, dan hapus ini breh
                      await themeProvider.setTheme(ThemeMode.light);
                      await authProvider.logout();
                      context.go('/login');
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
