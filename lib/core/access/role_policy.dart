import '../models/user_model.dart';
import 'app_routes.dart';
import 'role_capabilities.dart';

/// Route allow-lists per role (used by GoRouter redirect).
abstract final class RolePolicy {
  RolePolicy._();

  static bool isPublicPath(String path) {
    return path == AppRoutes.splash ||
        path == AppRoutes.login ||
        path == AppRoutes.publicRegister;
  }

  static bool isPathAllowed(UserModel user, String path) {
    if (RoleCapabilities.isPlatformAdmin(user)) return true;

    if (RoleCapabilities.isCompanyAdmin(user)) {
      return !path.startsWith('/platform/');
    }

    if (RoleCapabilities.isDriverUser(user)) {
      if (path.startsWith(AppRoutes.shipmentsEdit)) return false;
      return _matchesAnyRoot(path, [
        AppRoutes.employeeHome,
        AppRoutes.settings,
        AppRoutes.shipmentsRoutes,
        AppRoutes.shipmentsDelivery,
        AppRoutes.shipmentsNew,
        AppRoutes.shipments,
      ]);
    }

    if (user.role == 'seller') {
      if (path.startsWith(AppRoutes.shipmentsRoutes)) return false;
      if (_isClientForbiddenShipmentOrPackageForm(path)) return false;
      return _matchesAnyRoot(path, [
        AppRoutes.homeForUser(user),
        AppRoutes.shipments,
        AppRoutes.packages,
        AppRoutes.payments,
        AppRoutes.settings,
        AppRoutes.companyQr,
      ]);
    }

    if (user.role == 'recipient') {
      if (path.startsWith('/company/')) return false;
      if (path.startsWith(AppRoutes.shipmentsRoutes)) return false;
      if (_isClientForbiddenShipmentOrPackageForm(path)) return false;
      return _matchesAnyRoot(path, [
        AppRoutes.homeForUser(user),
        AppRoutes.shipments,
        AppRoutes.packages,
        AppRoutes.payments,
        AppRoutes.settings,
      ]);
    }

    if (user.role == 'company_employee' || user.role == 'employee') {
      if (path == AppRoutes.vehicles ||
          path.startsWith('${AppRoutes.vehicles}/')) {
        return false;
      }
      return _matchesAnyRoot(path, [
        AppRoutes.employeeHome,
        AppRoutes.packages,
        AppRoutes.shipments,
        AppRoutes.settings,
        AppRoutes.notifications,
        AppRoutes.collectionPoints,
        AppRoutes.deliveryPoints,
      ]);
    }

    return true;
  }

  static bool _isClientForbiddenShipmentOrPackageForm(String path) {
    return path.startsWith(AppRoutes.shipmentsNew) ||
        path.startsWith(AppRoutes.shipmentsEdit) ||
        path.startsWith(AppRoutes.shipmentsDelivery) ||
        path.startsWith(AppRoutes.packagesNew) ||
        path.startsWith(AppRoutes.packagesEdit);
  }

  static bool _matchesAnyRoot(String path, List<String> roots) {
    for (final root in roots) {
      if (path == root || path.startsWith('$root/')) return true;
    }
    return false;
  }
}
