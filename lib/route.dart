import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/provider/admin_provider.dart';
import 'package:flutter_application_1/provider/auth_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/screen/access/index.dart';
import 'package:flutter_application_1/screen/category/index.dart';
import 'package:flutter_application_1/screen/changePass/index.dart';
import 'package:flutter_application_1/screen/dishTypes/index.dart';
import 'package:flutter_application_1/screen/editProfile/index.dart';
import 'package:flutter_application_1/screen/gallery/index.dart';
import 'package:flutter_application_1/screen/login/index.dart';
import 'package:flutter_application_1/screen/menu/addEdit.dart';
import 'package:flutter_application_1/screen/product/index.dart';
import 'package:flutter_application_1/screen/role/addEdit.dart';
import 'package:flutter_application_1/screen/role/index.dart';
import 'package:flutter_application_1/screen/setting/index.dart';
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
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/setting',
          builder: (context, state) => const SettingScreen(),
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
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoryPage(),
            ),

            //FINANCE
            //CONTENT & MEDIA
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
            ),
            GoRoute(
              path: '/add-edit-menu',
              builder: (context, state) {
                final id = state.extra as int?;
                return AddEditMenuScreen(menuId: id);
              },
            ),
            GoRoute(
              path: '/dish-types',
              builder: (context, state) => const DishTypePage(),
            ),
            GoRoute(
              path: '/gallery',
              builder: (context, state) => const GalleryScreen(),
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
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadFuture = adminProvider.getUserById(authProvider.currUserId!);
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
    final adminProvider = Provider.of<AdminProvider>(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.brown[700]!, Colors.brown[500]!],
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 50, // Fixed top padding
                    ),
                    child: Column(
                      children: [
                        // Logo Cafe dengan Settings Button
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 80, // Fixed size, tidak relatif
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
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset("assets/logo.png"),
                                ),
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
                                    context.push('/setting');
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
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white30, thickness: 1),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // Profile User Section
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
                          child: StreamBuilder<UserAdmin?>(
                            stream: adminProvider.userStream,
                            builder: (context, streamSnap) {
                              return FutureBuilder<void>(
                                future: _loadFuture,
                                builder: (context, snapshot) {
                                  final user =
                                      streamSnap.data ??
                                      snapshot.data as UserAdmin?;

                                  if (user == null) {
                                    return Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.3),
                                          child: const Icon(
                                            Icons.person_outline,
                                            size: 36,
                                            color: Colors.white54,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 18,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                height: 15,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          size: 18,
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            user.img != null &&
                                                user.img!.isNotEmpty
                                            ? NetworkImage(user.img!)
                                            : null,
                                        child:
                                            user.img == null ||
                                                user.img!.isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                size: 36,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.fullname,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "@${user.username}",
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    showLogoutDialog(context);
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.getTheme();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.grey[600],
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.getTheme();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? (isSelected ? Colors.brown[700] : Colors.transparent)
            : (isSelected ? Colors.brown[50] : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red[700]
              : (isDark
                    ? (isSelected ? Colors.grey[200] : Colors.white60)
                    : (isSelected ? Colors.brown[700] : Colors.grey[800])),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red[700]
                : (isDark
                      ? (isSelected ? Colors.grey[200] : Colors.white60)
                      : (isSelected ? Colors.brown[700] : Colors.grey[800])),
            //: (isSelected ? Colors.brown[700] : isDark ? Colors.white60 : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.chevron_right,
                color: isDark ? Colors.brown[200] : Colors.brown[700],
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
