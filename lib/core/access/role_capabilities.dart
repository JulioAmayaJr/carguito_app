import '../models/user_model.dart';

/// Role predicates and feature flags for UI (no route strings here).
abstract final class RoleCapabilities {
  RoleCapabilities._();

  static bool isDriverUser(UserModel? user) {
    if (user == null) return false;
    final r = user.role;
    if (r != 'company_employee' && r != 'employee') return false;
    return user.employeeRole == 'driver';
  }

  static bool isClientUser(UserModel? user) {
    final r = user?.role;
    return r == 'seller' || r == 'recipient';
  }

  static bool isSellerUser(UserModel? user) => user?.role == 'seller';

  static bool isPlatformAdmin(UserModel? user) =>
      user?.role == 'platform_admin';

  static bool isCompanyAdmin(UserModel? user) => user?.role == 'company_admin';

  /// Create / edit / delete shipments (not driver, not client portal users).
  static bool canManageShipments(UserModel? user) {
    return user != null && !isDriverUser(user) && !isClientUser(user);
  }

  /// FAB + package CRUD for company staff and platform (not drivers, not clients).
  static bool canManagePackages(UserModel? user) {
    if (user == null || isDriverUser(user) || isClientUser(user)) {
      return false;
    }
    final r = user.role;
    return r == 'platform_admin' ||
        r == 'company_admin' ||
        r == 'company_employee' ||
        r == 'employee';
  }

  /// Company QR screen: full admin layout (both QR types + PDF).
  static bool showsCompanyQrAdminLayout(UserModel? user) =>
      isCompanyAdmin(user);

  /// Settings → "Administración" section (company back-office only).
  static bool showCompanyAdministrationInSettings(UserModel? user) =>
      isCompanyAdmin(user);
}
