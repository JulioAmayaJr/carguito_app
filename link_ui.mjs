import fs from 'fs';
import path from 'path';

const projectDir = '/Users/julioamaya/Projects/carguito/carguito_app/lib';

// Link PlatformProvider in Main.dart
let mainDart = fs.readFileSync(path.join(projectDir, 'main.dart'), 'utf8');
if (!mainDart.includes('platform_provider.dart')) {
  mainDart = mainDart.replace(
    "import 'core/router/app_router.dart';", 
    "import 'core/router/app_router.dart';\nimport 'features/platform/data/platform_service.dart';\nimport 'features/platform/presentation/providers/platform_provider.dart';"
  );
  mainDart = mainDart.replace(
    "providers: [", 
    "providers: [\n        ChangeNotifierProvider(create: (_) => PlatformProvider(PlatformService(dioClient.dio))),"
  );
  fs.writeFileSync(path.join(projectDir, 'main.dart'), mainDart);
}

// Map AppRouter Screens
let appRouter = fs.readFileSync(path.join(projectDir, 'core/router/app_router.dart'), 'utf8');
if (!appRouter.includes('platform_config_screen.dart')) {
  appRouter = appRouter.replace(
    "import '../../features/auth/presentation/providers/auth_provider.dart';", 
    "import '../../features/auth/presentation/providers/auth_provider.dart';\nimport '../../features/platform/presentation/screens/platform_config_screen.dart';\nimport '../../features/companies/presentation/screens/companies_form_screen.dart';"
  );
  appRouter = appRouter.replace(
    "GoRoute(path: '/companies', builder: (_, __) => const CompaniesListScreen()),", 
    "GoRoute(path: '/companies', builder: (_, __) => const CompaniesListScreen()),\n      GoRoute(path: '/companies/new', builder: (_, __) => const CompaniesFormScreen()),\n      GoRoute(path: '/companies/edit', builder: (context, state) => CompaniesFormScreen(company: state.extra as Map<String,dynamic>)),\n      GoRoute(path: '/platform/config', builder: (_, __) => const PlatformConfigScreen()),"
  );
  fs.writeFileSync(path.join(projectDir, 'core/router/app_router.dart'), appRouter);
}

// Connect Dashboard to Platform Screens
let platformHome = fs.readFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), 'utf8');
if (!platformHome.includes('/platform/config')) {
  platformHome = platformHome.replace(
    "ListTile(title: const Text('Companies'), onTap: () => context.push('/companies')),", 
    "ListTile(title: const Text('Companies'), onTap: () => context.push('/companies')),\n            ListTile(title: const Text('Plataforma y Bancos'), onTap: () => context.push('/platform/config')),"
  );
  fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), platformHome);
}

console.log('UI Links Established Successfully');
