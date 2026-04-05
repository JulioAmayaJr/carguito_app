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

import '../../features/packages/presentation/screens/packages_list_screen.dart';
import '../../features/packages/presentation/screens/packages_form_screen.dart';

import '../../features/shipments/presentation/screens/shipments_list_screen.dart';
import '../../features/shipments/presentation/screens/shipments_form_screen.dart';

import '../../features/payments/presentation/screens/payments_list_screen.dart';
import '../../features/fees/presentation/screens/fees_list_screen.dart';

import '../../features/bank_accounts/presentation/screens/bank_accounts_list_screen.dart';
import '../../features/bank_accounts/presentation/screens/bank_accounts_form_screen.dart';

import '../../features/notifications/presentation/screens/notifications_list_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isInitialized = authProvider.isInitialized;
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;

      if (!isInitialized) return '/';

      final isLoginPath =
          state.uri.path == '/login' || state.uri.path == '/public/register';

      if (!isAuthenticated && !isLoginPath) {
        return '/login';
      }

      if (isAuthenticated && (isLoginPath || state.uri.path == '/')) {
        if (user?.role == 'platform_admin') return '/platform/home';
        if (user?.role == 'company_admin') return '/company/home';
        if (user?.role == 'seller') return '/seller/home';
        if (user?.role == 'recipient') return '/recipient/home';
        return '/employee/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
          path: '/public/register',
          builder: (_, __) => const PublicRegistrationScreen()),
      GoRoute(path: '/company/qr', builder: (_, __) => const CompanyQrScreen()),
      GoRoute(path: '/platform/home', builder: (_, __) => const PlatformHome()),
      GoRoute(path: '/company/home', builder: (_, __) => const CompanyHome()),
      GoRoute(path: '/employee/home', builder: (_, __) => const EmployeeHome()),
      GoRoute(path: '/seller/home', builder: (_, __) => const SellerHome()),
      GoRoute(
          path: '/recipient/home', builder: (_, __) => const RecipientHome()),
      GoRoute(
          path: '/platform/config',
          builder: (_, __) => const PlatformConfigScreen()),

      // Companies
      GoRoute(
          path: '/companies',
          name: 'companiesList',
          builder: (_, __) => const CompaniesListScreen()),
      GoRoute(
          path: '/companies/new',
          name: 'newCompany',
          builder: (_, __) => const CompaniesFormScreen()),
      GoRoute(
          path: '/companies/edit',
          name: 'editCompany',
          builder: (_, state) => CompaniesFormScreen(
              company: state.extra as Map<String, dynamic>)),
      GoRoute(
  path: '/settings',
  name: 'settings',
  builder: (_, __) => const SettingsScreen(),
),
      // Branches
      GoRoute(
          path: '/branches', builder: (_, __) => const BranchesListScreen()),
      GoRoute(
          path: '/branches/new',
          builder: (_, __) => const BranchesFormScreen()),
      GoRoute(
          path: '/branches/edit',
          builder: (context, state) =>
              BranchesFormScreen(item: state.extra as Map<String, dynamic>)),

      // Employees
      GoRoute(
          path: '/employees', builder: (_, __) => const EmployeesListScreen()),
      GoRoute(
          path: '/employees/new',
          builder: (_, __) => const EmployeesFormScreen()),
      GoRoute(
          path: '/employees/edit',
          builder: (context, state) =>
              EmployeesFormScreen(item: state.extra as Map<String, dynamic>)),

      // Sellers
      GoRoute(path: '/sellers', builder: (_, __) => const SellersListScreen()),
      GoRoute(
          path: '/sellers/new', builder: (_, __) => const SellersFormScreen()),
      GoRoute(
          path: '/sellers/edit',
          builder: (context, state) =>
              SellersFormScreen(item: state.extra as Map<String, dynamic>)),

      // Recipients
      GoRoute(
          path: '/recipients',
          builder: (_, __) => const RecipientsListScreen()),
      GoRoute(
          path: '/recipients/new',
          builder: (_, __) => const RecipientsFormScreen()),
      GoRoute(
          path: '/recipients/edit',
          builder: (context, state) =>
              RecipientsFormScreen(item: state.extra as Map<String, dynamic>)),

      // Collection Points
      GoRoute(
          path: '/collection_points',
          builder: (_, __) => const CollectionPointsListScreen()),
      GoRoute(
          path: '/collection_points/new',
          builder: (_, __) => const CollectionPointsFormScreen()),
      GoRoute(
          path: '/collection_points/edit',
          builder: (context, state) => CollectionPointsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      // Delivery Points
      GoRoute(
          path: '/delivery_points',
          builder: (_, __) => const DeliveryPointsListScreen()),
      GoRoute(
          path: '/delivery_points/new',
          builder: (_, __) => const DeliveryPointsFormScreen()),
      GoRoute(
          path: '/delivery_points/edit',
          builder: (context, state) => DeliveryPointsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      // Packages
      GoRoute(
          path: '/packages', builder: (_, __) => const PackagesListScreen()),
      GoRoute(
          path: '/packages/new',
          builder: (_, __) => const PackagesFormScreen()),
      GoRoute(
          path: '/packages/edit',
          builder: (context, state) =>
              PackagesFormScreen(item: state.extra as Map<String, dynamic>)),

      // Shipments
      GoRoute(
          path: '/shipments', builder: (_, __) => const ShipmentsListScreen()),
      GoRoute(
          path: '/shipments/new',
          builder: (_, __) => const ShipmentsFormScreen()),
      GoRoute(
          path: '/shipments/edit',
          builder: (context, state) =>
              ShipmentsFormScreen(item: state.extra as Map<String, dynamic>)),

      // Bank Accounts
      GoRoute(
          path: '/bank_accounts',
          builder: (_, __) => const BankAccountsListScreen()),
      GoRoute(
          path: '/bank_accounts/new',
          builder: (_, __) => const BankAccountsFormScreen()),
      GoRoute(
          path: '/bank_accounts/edit',
          builder: (context, state) => BankAccountsFormScreen(
              item: state.extra as Map<String, dynamic>)),

      // Other generic
      GoRoute(
          path: '/payments', builder: (_, __) => const PaymentsListScreen()),
      GoRoute(path: '/fees', builder: (_, __) => const FeesListScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsListScreen()),
    ],
  );
}
