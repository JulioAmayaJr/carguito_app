import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_manager.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'features/platform/data/platform_service.dart';
import 'features/platform/presentation/providers/platform_provider.dart';
import 'features/companies/data/companies_service.dart';
import 'features/companies/presentation/providers/companies_provider.dart';
import 'features/branches/data/branches_service.dart';
import 'features/branches/presentation/providers/branches_provider.dart';
import 'features/employees/data/employees_service.dart';
import 'features/employees/presentation/providers/employees_provider.dart';
import 'features/sellers/data/sellers_service.dart';
import 'features/sellers/presentation/providers/sellers_provider.dart';
import 'features/recipients/data/recipients_service.dart';
import 'features/recipients/presentation/providers/recipients_provider.dart';
import 'features/collection_points/data/collection_points_service.dart';
import 'features/collection_points/presentation/providers/collection_points_provider.dart';
import 'features/delivery_points/data/delivery_points_service.dart';
import 'features/delivery_points/presentation/providers/delivery_points_provider.dart';
import 'features/packages/data/packages_service.dart';
import 'features/packages/presentation/providers/packages_provider.dart';
import 'features/shipments/data/shipments_service.dart';
import 'features/shipments/presentation/providers/shipments_provider.dart';
import 'features/payments/data/payments_service.dart';
import 'features/payments/presentation/providers/payments_provider.dart';
import 'features/fees/data/fees_service.dart';
import 'features/fees/presentation/providers/fees_provider.dart';
import 'features/bank_accounts/data/bank_accounts_service.dart';
import 'features/bank_accounts/presentation/providers/bank_accounts_provider.dart';
import 'features/notifications/data/notifications_service.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenManager = TokenManager();
  await tokenManager.init(); // Pre-load tokens from disk into memory
  final dioClient = DioClient(tokenManager: tokenManager);
  final authService = AuthService(dioClient.dio);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => PlatformProvider(PlatformService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authService, tokenManager)),
        ChangeNotifierProvider(
            create: (_) => CompaniesProvider(CompaniesService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => BranchesProvider(BranchesService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => EmployeesProvider(EmployeesService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => SellersProvider(SellersService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) =>
                RecipientsProvider(RecipientsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => CollectionPointsProvider(
                CollectionPointsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) =>
                DeliveryPointsProvider(DeliveryPointsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => PackagesProvider(PackagesService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => ShipmentsProvider(ShipmentsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => PaymentsProvider(PaymentsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) => FeesProvider(FeesService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) =>
                BankAccountsProvider(BankAccountsService(dioClient.dio))),
        ChangeNotifierProvider(
            create: (_) =>
                NotificationsProvider(NotificationsService(dioClient.dio))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final appRouter = AppRouter(authProvider);

    return MaterialApp.router(
      title: 'Carguito',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
