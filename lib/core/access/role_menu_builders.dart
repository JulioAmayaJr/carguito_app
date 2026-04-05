import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'app_nav_item.dart';
import 'app_routes.dart';
import 'role_capabilities.dart';

/// One menu builder per role family; [forUser] dispatches.
abstract final class RoleMenuBuilders {
  RoleMenuBuilders._();

  static List<AppNavItem> forUser(UserModel? user) {
    if (user == null) return [];

    switch (user.role) {
      case 'platform_admin':
        return forPlatformAdmin();
      case 'company_admin':
        return forCompanyAdmin();
      case 'seller':
      case 'recipient':
        return forClient(AppRoutes.homeForUser(user));
      case 'company_employee':
      case 'employee':
        return RoleCapabilities.isDriverUser(user)
            ? forDriver()
            : forWarehouseEmployee();
      default:
        return forUnknownRole();
    }
  }

  static List<AppNavItem> forPlatformAdmin() => const [
        AppNavItem(
          route: AppRoutes.platformHome,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        AppNavItem(
          route: AppRoutes.companies,
          label: 'Empresas',
          icon: Icons.business_rounded,
        ),
        AppNavItem(
          route: AppRoutes.packages,
          label: 'Paquetes',
          icon: Icons.inventory_2_rounded,
        ),
        AppNavItem(
          route: AppRoutes.shipments,
          label: 'Envíos',
          icon: Icons.local_shipping_rounded,
        ),
        AppNavItem(
          route: AppRoutes.platformConfig,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static List<AppNavItem> forCompanyAdmin() => const [
        AppNavItem(
          route: AppRoutes.companyHome,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        // AppNavItem(
        //   route: AppRoutes.employees,
        //   label: 'Empleados',
        //   icon: Icons.people_rounded,
        // ),
        AppNavItem(
          route: AppRoutes.packages,
          label: 'Paquetes',
          icon: Icons.inventory_2_rounded,
        ),
        AppNavItem(
          route: AppRoutes.shipments,
          label: 'Envíos',
          icon: Icons.local_shipping_rounded,
        ),
        AppNavItem(
          route: AppRoutes.payments,
          label: 'Pagos',
          icon: Icons.account_balance_wallet_rounded,
        ),
        AppNavItem(
          route: AppRoutes.settings,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static List<AppNavItem> forClient(String homeRoute) => [
        AppNavItem(
          route: homeRoute,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        const AppNavItem(
          route: AppRoutes.shipments,
          label: 'Envíos',
          icon: Icons.local_shipping_rounded,
        ),
        const AppNavItem(
          route: AppRoutes.packages,
          label: 'Paquetes',
          icon: Icons.inventory_2_rounded,
        ),
        const AppNavItem(
          route: AppRoutes.payments,
          label: 'Pagos',
          icon: Icons.account_balance_wallet_rounded,
        ),
        const AppNavItem(
          route: AppRoutes.settings,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static List<AppNavItem> forDriver() => const [
        AppNavItem(
          route: AppRoutes.employeeHome,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        AppNavItem(
          route: AppRoutes.shipments,
          label: 'Envíos',
          icon: Icons.local_shipping_rounded,
        ),
        AppNavItem(
          route: AppRoutes.shipmentsRoutes,
          label: 'Rutas',
          icon: Icons.map_rounded,
        ),
        AppNavItem(
          route: AppRoutes.settings,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static List<AppNavItem> forWarehouseEmployee() => const [
        AppNavItem(
          route: AppRoutes.employeeHome,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        AppNavItem(
          route: AppRoutes.packages,
          label: 'Paquetes',
          icon: Icons.inventory_2_rounded,
        ),
        AppNavItem(
          route: AppRoutes.shipments,
          label: 'Envíos',
          icon: Icons.local_shipping_rounded,
        ),
        AppNavItem(
          route: AppRoutes.settings,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static List<AppNavItem> forUnknownRole() => const [
        AppNavItem(
          route: AppRoutes.splash,
          label: 'Inicio',
          icon: Icons.home_rounded,
        ),
        AppNavItem(
          route: AppRoutes.settings,
          label: 'Ajustes',
          icon: Icons.settings_rounded,
        ),
      ];

  static int selectedIndex(String location, List<AppNavItem> items) {
    var bestIdx = 0;
    var bestLen = -1;
    for (var i = 0; i < items.length; i++) {
      final r = items[i].route;
      if (location == r || location.startsWith('$r/')) {
        if (r.length > bestLen) {
          bestLen = r.length;
          bestIdx = i;
        }
      }
    }
    return bestIdx;
  }
}
