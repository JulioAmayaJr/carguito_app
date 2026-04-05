import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/public/presentation/public_registration_screen.dart';
import '../../features/dashboard/presentation/screens/company_qr_screen.dart';
import '../../features/auth/presentation/screens/splash_page.dart';
import '../../features/dashboard/presentation/screens/platform_home.dart';
import '../../features/dashboard/presentation/screens/company_home.dart';
import '../../features/dashboard/presentation/screens/employee_home.dart';
import '../../features/dashboard/presentation/screens/seller_home.dart';
import '../../features/dashboard/presentation/screens/recipient_home.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/platform/presentation/screens/platform_config_screen.dart';

import '../../features/companies/presentation/screens/companies_form_screen.dart';
import '../../features/companies/presentation/screens/companies_list_screen.dart';

import '../../features/branches/presentation/screens/branches_list_screen.dart';
import '../../features/branches/presentation/screens/branches_form_screen.dart';

import '../../features/employees/presentation/screens/employees_list_screen.dart';
import '../../features/employees/presentation/screens/employees_form_screen.dart';

import '../../features/sellers/presentation/screens/sellers_list_screen.dart';
import '../../features/sellers/presentation/screens/sellers_form_screen.dart';

import '../../features/recipients/presentation/screens/recipients_list_screen.dart';
import '../../features/recipients/presentation/screens/recipients_form_screen.dart';

import '../../features/collection_points/presentation/screens/collection_points_list_screen.dart';
import '../../features/collection_points/presentation/screens/collection_points_form_screen.dart';

import '../../features/delivery_points/presentation/screens/delivery_points_list_screen.dart';
import '../../features/delivery_points/presentation/screens/delivery_points_form_screen.dart';

import '../../features/vehicles/presentation/screens/vehicles_list_screen.dart';
import '../../features/vehicles/presentation/screens/vehicles_form_screen.dart';

import '../../features/packages/presentation/screens/packages_list_screen.dart';
import '../../features/packages/presentation/screens/packages_form_screen.dart';

import '../../features/shipments/presentation/screens/shipments_list_screen.dart';
import '../../features/shipments/presentation/screens/shipments_form_screen.dart';

import '../../features/payments/presentation/screens/payments_list_screen.dart';
import '../../features/fees/presentation/screens/fees_list_screen.dart';

import '../../features/bank_accounts/presentation/screens/bank_accounts_list_screen.dart';
import '../../features/bank_accounts/presentation/screens/bank_accounts_form_screen.dart';

import '../../features/shipments/presentation/screens/delivery_confirmation_screen.dart';
import '../../features/shipments/presentation/screens/driver_routes_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../auth/role_access.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isInitialized = authProvider.isInitialized;
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;

      if (!isInitialized) return AppRoutes.splash;

      final path = state.uri.path;
      final isLoginPath =
          path == AppRoutes.login || path == AppRoutes.publicRegister;

      if (!isAuthenticated && !isLoginPath) {
        return AppRoutes.login;
      }

      if (isAuthenticated &&
          user != null &&
          (isLoginPath || path == AppRoutes.splash)) {
        return RoleAccess.homeFor(user);
      }

      if (isAuthenticated && user != null) {
        if (!RoleAccess.isPublicPath(path) && !RoleAccess.isPathAllowed(user, path)) {
          return RoleAccess.homeFor(user);
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
          path: AppRoutes.publicRegister,
          builder: (_, __) => const PublicRegistrationScreen()),
      GoRoute(path: AppRoutes.companyQr, builder: (_, __) => const CompanyQrScreen()),
      GoRoute(path: AppRoutes.platformHome, builder: (_, __) => const PlatformHome()),
      GoRoute(path: AppRoutes.companyHome, builder: (_, __) => const CompanyHome()),
      GoRoute(path: AppRoutes.employeeHome, builder: (_, __) => const EmployeeHome()),
      GoRoute(path: AppRoutes.sellerHome, builder: (_, __) => const SellerHome()),
      GoRoute(
          path: AppRoutes.recipientHome, builder: (_, __) => const RecipientHome()),
      GoRoute(
          path: AppRoutes.platformConfig,
          builder: (_, __) => const PlatformConfigScreen()),

      GoRoute(
          path: AppRoutes.companies,
          name: 'companiesList',
          builder: (_, __) => const CompaniesListScreen()),
      GoRoute(
          path: AppRoutes.companiesNew,
          name: 'newCompany',
          builder: (_, __) => const CompaniesFormScreen()),
      GoRoute(
          path: AppRoutes.companiesEdit,
          name: 'editCompany',
          builder: (_, state) => CompaniesFormScreen(
              company: state.extra as Map<String, dynamic>)),
      GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
          path: AppRoutes.branches, builder: (_, __) => const BranchesListScreen()),
      GoRoute(
          path: AppRoutes.branchesNew,
          builder: (_, __) => const BranchesFormScreen()),
      GoRoute(
          path: AppRoutes.branchesEdit,
          builder: (context, state) =>
              BranchesFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.employees, builder: (_, __) => const EmployeesListScreen()),
      GoRoute(
          path: AppRoutes.employeesNew,
          builder: (_, __) => const EmployeesFormScreen()),
      GoRoute(
          path: AppRoutes.employeesEdit,
          builder: (context, state) =>
              EmployeesFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(path: AppRoutes.sellers, builder: (_, __) => const SellersListScreen()),
      GoRoute(
          path: AppRoutes.sellersNew, builder: (_, __) => const SellersFormScreen()),
      GoRoute(
          path: AppRoutes.sellersEdit,
          builder: (context, state) =>
              SellersFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.recipients,
          builder: (_, __) => const RecipientsListScreen()),
      GoRoute(
          path: AppRoutes.recipientsNew,
          builder: (_, __) => const RecipientsFormScreen()),
      GoRoute(
          path: AppRoutes.recipientsEdit,
          builder: (context, state) =>
              RecipientsFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.collectionPoints,
          builder: (_, __) => const CollectionPointsListScreen()),
      GoRoute(
          path: AppRoutes.collectionPointsNew,
          builder: (_, __) => const CollectionPointsFormScreen()),
      GoRoute(
          path: AppRoutes.collectionPointsEdit,
          builder: (context, state) => CollectionPointsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.deliveryPoints,
          builder: (_, __) => const DeliveryPointsListScreen()),
      GoRoute(
          path: AppRoutes.deliveryPointsNew,
          builder: (_, __) => const DeliveryPointsFormScreen()),
      GoRoute(
          path: AppRoutes.deliveryPointsEdit,
          builder: (context, state) => DeliveryPointsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.vehicles,
          builder: (_, __) => const VehiclesListScreen()),
      GoRoute(
          path: AppRoutes.vehiclesNew,
          builder: (_, __) => const VehiclesFormScreen()),
      GoRoute(
          path: AppRoutes.vehiclesEdit,
          builder: (context, state) => VehiclesFormScreen(
              item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.packages, builder: (_, __) => const PackagesListScreen()),
      GoRoute(
          path: AppRoutes.packagesNew,
          builder: (_, __) => const PackagesFormScreen()),
      GoRoute(
          path: AppRoutes.packagesEdit,
          builder: (context, state) =>
              PackagesFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.shipments, builder: (_, __) => const ShipmentsListScreen()),
      GoRoute(
          path: AppRoutes.shipmentsNew,
          builder: (_, __) => const ShipmentsFormScreen()),
      GoRoute(
          path: AppRoutes.shipmentsEdit,
          builder: (context, state) =>
              ShipmentsFormScreen(item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.bankAccounts,
          builder: (_, __) => const BankAccountsListScreen()),
      GoRoute(
          path: AppRoutes.bankAccountsNew,
          builder: (_, __) => const BankAccountsFormScreen()),
      GoRoute(
          path: AppRoutes.bankAccountsEdit,
          builder: (context, state) => BankAccountsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      GoRoute(
          path: AppRoutes.payments, builder: (_, __) => const PaymentsListScreen()),
      GoRoute(path: AppRoutes.fees, builder: (_, __) => const FeesListScreen()),
      GoRoute(
          path: AppRoutes.shipmentsDelivery,
          builder: (context, state) =>
              DeliveryConfirmationScreen(item: state.extra as Map<String, dynamic>)),
      GoRoute(
          path: AppRoutes.shipmentsRoutes,
          builder: (_, __) => const DriverRoutesScreen()),
    ],
  );
}
