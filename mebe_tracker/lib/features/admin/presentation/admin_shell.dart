import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_provider.dart';

// ── Admin color palette (dark theme) ─────────────────────────────────────────

class AdminColors {
  AdminColors._();

  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceElevated = Color(0xFF22224A);
  static const primary = Color(0xFF7C73FF);
  static const accent = Color(0xFF00D2D3);
  static const danger = Color(0xFFFF4757);
  static const warning = Color(0xFFFFA502);
  static const success = Color(0xFF2ED573);
  static const textPrimary = Color(0xFFEEEEFF);
  static const textSecondary = Color(0xFF9999BB);
  static const divider = Color(0xFF2A2A4A);
}

final ThemeData _adminTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AdminColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AdminColors.surface,
    primary: AdminColors.primary,
    error: AdminColors.danger,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AdminColors.surface,
    foregroundColor: AdminColors.textPrimary,
    elevation: 0,
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: AdminColors.surface),
  dividerColor: AdminColors.divider,
  cardColor: AdminColors.surface,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AdminColors.surfaceElevated,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AdminColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AdminColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AdminColors.primary, width: 2),
    ),
    labelStyle: const TextStyle(color: AdminColors.textSecondary),
    hintStyle: const TextStyle(color: AdminColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AdminColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AdminColors.surfaceElevated,
    selectedColor: AdminColors.primary.withValues(alpha: 0.3),
    labelStyle: const TextStyle(color: AdminColors.textPrimary),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AdminColors.textPrimary),
    bodyMedium: TextStyle(color: AdminColors.textPrimary),
    bodySmall: TextStyle(color: AdminColors.textSecondary),
    titleMedium: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: AdminColors.textSecondary),
  ),
  iconTheme: const IconThemeData(color: AdminColors.textSecondary),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AdminColors.primary : AdminColors.textSecondary),
    trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AdminColors.primary.withValues(alpha: 0.4) : AdminColors.divider),
  ),
);

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.minLevel,
  });
  final String label;
  final IconData icon;
  final String path;
  final int minLevel;
}

const _navItems = [
  _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, path: '/admin/dashboard', minLevel: 0),
  _NavItem(label: 'Người dùng', icon: Icons.people_outline, path: '/admin/users', minLevel: 0),
  _NavItem(label: 'Cấp Premium', icon: Icons.star_outline, path: '/admin/grant', minLevel: 0),
  _NavItem(label: 'Nhật ký', icon: Icons.history, path: '/admin/audit', minLevel: 0),
  _NavItem(label: 'Cấu hình', icon: Icons.settings_outlined, path: '/admin/config', minLevel: 1),
  _NavItem(label: 'Vai trò', icon: Icons.admin_panel_settings_outlined, path: '/admin/roles', minLevel: 2),
];

// ── Shell ─────────────────────────────────────────────────────────────────────

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(adminRoleProvider);
    final role = roleAsync.value ?? AdminRole.user;

    return Theme(
      data: _adminTheme,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        appBar: AppBar(
          title: Row(
            children: [
              const Text('MeBé', style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)),
              const Text(' Admin', style: TextStyle(color: AdminColors.textPrimary)),
            ],
          ),
          actions: [
            _RoleBadge(role: role),
            const SizedBox(width: 8),
          ],
        ),
        drawer: _AdminDrawer(role: role),
        body: child,
      ),
    );
  }
}

// ── Role badge ────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final AdminRole role;

  Color _color() {
    switch (role) {
      case AdminRole.superadmin:
        return AdminColors.danger;
      case AdminRole.admin:
        return AdminColors.primary;
      case AdminRole.support:
        return AdminColors.success;
      case AdminRole.user:
        return AdminColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color().withValues(alpha: 0.5)),
      ),
      child: Text(
        role.displayName.toUpperCase(),
        style: TextStyle(color: _color(), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}

// ── Drawer ────────────────────────────────────────────────────────────────────

class _AdminDrawer extends ConsumerWidget {
  const _AdminDrawer({required this.role});
  final AdminRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final visibleItems = _navItems.where((item) => role.level >= item.minLevel).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield, color: AdminColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin Panel',
                          style: TextStyle(
                              color: AdminColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(role.displayName,
                          style: const TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AdminColors.divider, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: visibleItems.map((item) {
                  final isSelected = currentPath == item.path;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected ? AdminColors.primary : AdminColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? AdminColors.primary : AdminColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AdminColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (!isSelected) context.go(item.path);
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(color: AdminColors.divider, height: 1),
            ListTile(
              leading: const Icon(Icons.phone_android_outlined, color: AdminColors.textSecondary, size: 22),
              title: const Text('Xem ứng dụng', style: TextStyle(color: AdminColors.textPrimary)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
