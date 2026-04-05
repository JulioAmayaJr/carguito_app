import '../models/user_model.dart';
import 'app_nav_item.dart';
import 'app_routes.dart';
import 'role_capabilities.dart';
import 'role_menu_builders.dart';
import 'role_policy.dart';

export 'app_nav_item.dart';
export 'app_routes.dart';

/// Single entry point: capabilities, routes, menus, and route guards.
abstract final class RoleAccess {
  RoleAccess._();

  // --- Routes (alias [AppRoutes] for backward compatibility) ---
  static String get pathShipments => AppRoutes.shipments;
  static String get pathShipmentsNew => AppRoutes.shipmentsNew;
  static String get pathShipmentsEdit => AppRoutes.shipmentsEdit;
  static String get pathShipmentsRoutes => AppRoutes.shipmentsRoutes;
  static String get pathShipmentsDelivery => AppRoutes.shipmentsDelivery;
  static String get pathPackages => AppRoutes.packages;
  static String get pathPackagesNew => AppRoutes.packagesNew;
  static String get pathPackagesEdit => AppRoutes.packagesEdit;
  static String get pathPayments => AppRoutes.payments;
  static String get pathSettings => AppRoutes.settings;
  static String get pathCompanyQr => AppRoutes.companyQr;

  static String homeFor(UserModel user) => AppRoutes.homeForUser(user);

  static bool isPublicPath(String path) => RolePolicy.isPublicPath(path);

  static bool isPathAllowed(UserModel user, String path) =>
      RolePolicy.isPathAllowed(user, path);

  static bool canNavigate(UserModel? user, String path) =>
      user != null && isPathAllowed(user, path);

  // --- Capabilities ---
  static bool isDriverUser(UserModel? user) =>
      RoleCapabilities.isDriverUser(user);

  static bool isClientUser(UserModel? user) =>
      RoleCapabilities.isClientUser(user);

  static bool canManagePackages(UserModel? user) =>
      RoleCapabilities.canManagePackages(user);

  static bool canManageShipments(UserModel? user) =>
      RoleCapabilities.canManageShipments(user);

  // --- Bottom navigation ---
  static List<AppNavItem> bottomNavItems(UserModel? user) =>
      RoleMenuBuilders.forUser(user);

  static int bottomNavSelectedIndex(String location, List<AppNavItem> items) =>
      RoleMenuBuilders.selectedIndex(location, items);

  static bool showsCompanyQrAdminLayout(UserModel? user) =>
      RoleCapabilities.showsCompanyQrAdminLayout(user);

  static bool isSellerPortalUser(UserModel? user) =>
      RoleCapabilities.isSellerUser(user);

  static bool showCompanyAdministrationInSettings(UserModel? user) =>
      RoleCapabilities.showCompanyAdministrationInSettings(user);
}
