import 'package:flutter/material.dart';

class Access {
  final String id;
  final String name;
  final String accessPath;
  final String category;
  final int idSort;
  final String iconName;
  final IconData icon;
  final DateTime createdAt;

  Access({
    required this.id,
    required this.name,
    required this.accessPath,
    required this.category,
    required this.idSort,
    required this.iconName,
    required this.icon,
    required this.createdAt,
  });

  factory Access.fromMap(Map<String, dynamic> map) {
    return Access(
      id: map['id'],
      name: map['name'],
      accessPath: map['access_path'],
      category: map['category'],
      idSort: map['id_sort'],
      iconName: map['icon'],
      icon: appIcons.firstWhere((item) => item.name == map["icon"]).icon,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

final List<IconItem> appIcons = [
  // Navigation
  IconItem(name: "dashboard", icon: Icons.dashboard_rounded),
  IconItem(name: "home", icon: Icons.home_rounded),
  IconItem(name: "menu", icon: Icons.menu),
  IconItem(name: "settings", icon: Icons.settings),

  // User / Role / Permission
  IconItem(name: "user", icon: Icons.person_rounded),
  IconItem(name: "users", icon: Icons.group_rounded),
  IconItem(name: "role", icon: Icons.manage_accounts_rounded),
  IconItem(name: "lock", icon: Icons.lock_rounded),
  IconItem(name: "permission", icon: Icons.admin_panel_settings_rounded),

  // Orders
  IconItem(name: "orders", icon: Icons.shopping_cart_rounded),
  IconItem(name: "orders_pending", icon: Icons.hourglass_empty_rounded),
  IconItem(name: "orders_completed", icon: Icons.check_circle_rounded),

  // Products / Stock
  IconItem(name: "products", icon: Icons.coffee_maker_rounded),
  IconItem(name: "categories", icon: Icons.category_rounded),
  IconItem(name: "inventory", icon: Icons.inventory_2_rounded),

  // Finance
  IconItem(name: "cashflow", icon: Icons.account_balance_wallet_rounded),
  IconItem(name: "report", icon: Icons.assessment_rounded),
  IconItem(name: "transaction", icon: Icons.payment_rounded),

  // Content & Media
  IconItem(name: "menu_food", icon: Icons.restaurant_menu_rounded),
  IconItem(name: "dish_types", icon: Icons.fastfood_rounded),
  IconItem(name: "gallery", icon: Icons.collections_rounded),

  // Management
  IconItem(name: "user_admin", icon: Icons.people_rounded),
  IconItem(name: "roles", icon: Icons.manage_accounts_rounded),
  IconItem(name: "accesses", icon: Icons.lock),

  // Status / Info
  IconItem(name: "info", icon: Icons.info_rounded),
  IconItem(name: "warning", icon: Icons.warning_rounded),
  IconItem(name: "error", icon: Icons.error_rounded),
  IconItem(name: "success", icon: Icons.check_circle_rounded),
  IconItem(name: "pending", icon: Icons.hourglass_top_rounded),

  // Actions
  IconItem(name: "add", icon: Icons.add_rounded),
  IconItem(name: "edit", icon: Icons.edit_rounded),
  IconItem(name: "delete", icon: Icons.delete_rounded),
  IconItem(name: "save", icon: Icons.save_rounded),
  IconItem(name: "refresh", icon: Icons.refresh_rounded),

  // Files
  IconItem(name: "file", icon: Icons.insert_drive_file_rounded),
  IconItem(name: "folder", icon: Icons.folder_rounded),
  IconItem(name: "upload", icon: Icons.cloud_upload_rounded),
  IconItem(name: "download", icon: Icons.cloud_download_rounded),

  // Time
  IconItem(name: "calendar", icon: Icons.calendar_month_rounded),
  IconItem(name: "schedule", icon: Icons.schedule_rounded),
  IconItem(name: "history", icon: Icons.history_rounded),

  // Analytics
  IconItem(name: "chart", icon: Icons.bar_chart_rounded),
  IconItem(name: "analytics", icon: Icons.analytics_rounded),
  IconItem(name: "trend_up", icon: Icons.trending_up_rounded),
  IconItem(name: "trend_down", icon: Icons.trending_down_rounded),
];

class IconItem {
  final String name;
  final IconData icon;

  IconItem({required this.name, required this.icon});
}
