import '../models/user_model.dart';

/// All app paths in one place (router, guards, navigation).
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String publicRegister = '/public/register';

  static const String platformHome = '/platform/home';
  static const String platformConfig = '/platform/config';
  static const String companyHome = '/company/home';
  static const String employeeHome = '/employee/home';
  static const String sellerHome = '/seller/home';
  static const String recipientHome = '/recipient/home';

  static const String companyQr = '/company/qr';

  static const String companies = '/companies';
  static const String companiesNew = '/companies/new';
  static const String companiesEdit = '/companies/edit';

  static const String branches = '/branches';
  static const String branchesNew = '/branches/new';
  static const String branchesEdit = '/branches/edit';

  static const String employees = '/employees';
  static const String employeesNew = '/employees/new';
  static const String employeesEdit = '/employees/edit';

  static const String sellers = '/sellers';
  static const String sellersNew = '/sellers/new';
  static const String sellersEdit = '/sellers/edit';

  static const String recipients = '/recipients';
  static const String recipientsNew = '/recipients/new';
  static const String recipientsEdit = '/recipients/edit';

  static const String collectionPoints = '/collection_points';
  static const String collectionPointsNew = '/collection_points/new';
  static const String collectionPointsEdit = '/collection_points/edit';

  static const String deliveryPoints = '/delivery_points';
  static const String deliveryPointsNew = '/delivery_points/new';
  static const String deliveryPointsEdit = '/delivery_points/edit';

  static const String vehicles = '/vehicles';
  static const String vehiclesNew = '/vehicles/new';
  static const String vehiclesEdit = '/vehicles/edit';

  static const String packages = '/packages';
  static const String packagesNew = '/packages/new';
  static const String packagesEdit = '/packages/edit';

  static const String shipments = '/shipments';
  static const String shipmentsNew = '/shipments/new';
  static const String shipmentsEdit = '/shipments/edit';
  static const String shipmentsDelivery = '/shipments/delivery';
  static const String shipmentsRoutes = '/shipments/routes';

  static const String bankAccounts = '/bank_accounts';
  static const String bankAccountsNew = '/bank_accounts/new';
  static const String bankAccountsEdit = '/bank_accounts/edit';

  static const String payments = '/payments';
  static const String fees = '/fees';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static String homeForUser(UserModel user) {
    switch (user.role) {
      case 'platform_admin':
        return platformHome;
      case 'company_admin':
        return companyHome;
      case 'seller':
        return sellerHome;
      case 'recipient':
        return recipientHome;
      default:
        return employeeHome;
    }
  }
}
