import fs from 'fs';
import path from 'path';

const projectDir = '/Users/julioamaya/Projects/carguito/carguito_app/lib';

const ensureDir = (dirPath) => {
  fs.mkdirSync(dirPath, { recursive: true });
};

const modules = [
  'companies', 'branches', 'employees', 'sellers', 'recipients',
  'collection_points', 'delivery_points', 'packages', 'shipments',
  'payments', 'fees', 'bank_accounts', 'notifications'
];

modules.forEach(m => {
  ensureDir(path.join(projectDir, 'features/' + m + '/data'));
  ensureDir(path.join(projectDir, 'features/' + m + '/presentation/providers'));
  ensureDir(path.join(projectDir, 'features/' + m + '/presentation/screens'));
  
  const camelCase = m.replace(/_([a-z])/g, g => g[1].toUpperCase());
  const PascalCase = m.split('_').map(w => w[0].toUpperCase() + w.slice(1)).join('');
  const endpoint = m.replace('_', '-');

  fs.writeFileSync(path.join(projectDir, 'features/' + m + '/data/' + m + '_service.dart'), 
`import 'package:dio/dio.dart';

class ` + PascalCase + `Service {
  final Dio _dio;
  ` + PascalCase + `Service(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/` + endpoint + `');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/` + endpoint + `/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/` + endpoint + `', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/` + endpoint + `/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/` + endpoint + `/' + id);
  }
}
`);

  fs.writeFileSync(path.join(projectDir, 'features/' + m + '/presentation/providers/' + m + '_provider.dart'), 
`import 'package:flutter/material.dart';
import '../../data/` + m + `_service.dart';

class ` + PascalCase + `Provider extends ChangeNotifier {
  final ` + PascalCase + `Service _service;
  
  List<dynamic> items = [];
  bool isLoading = false;
  String? error;

  ` + PascalCase + `Provider(this._service);

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _service.create(data);
      await fetchAll();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
`);

  fs.writeFileSync(path.join(projectDir, 'features/' + m + '/presentation/screens/' + m + '_list_screen.dart'), 
`import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/` + m + `_provider.dart';

class ` + PascalCase + `ListScreen extends StatefulWidget {
  const ` + PascalCase + `ListScreen({super.key});

  @override
  State<` + PascalCase + `ListScreen> createState() => _` + PascalCase + `ListScreenState();
}

class _` + PascalCase + `ListScreenState extends State<` + PascalCase + `ListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<` + PascalCase + `Provider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<` + PascalCase + `Provider>();
    return Scaffold(
      appBar: AppBar(title: const Text('` + PascalCase + `')),
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['name'] ?? item['package_code'] ?? item['id'] ?? 'Unknown'),
                      subtitle: Text(item.toString()),
                    );
                  },
                ),
    );
  }
}
`);
});

const providerImports = modules.map(m => {
  return "import 'features/" + m + "/data/" + m + "_service.dart';\nimport 'features/" + m + "/presentation/providers/" + m + "_provider.dart';";
}).join('\n');

const providerInjects = modules.map(m => {
  const PascalCase = m.split('_').map(w => w[0].toUpperCase() + w.slice(1)).join('');
  return "ChangeNotifierProvider(create: (_) => " + PascalCase + "Provider(" + PascalCase + "Service(dioClient.dio))),";
}).join('\n        ');

const mainDart = `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_manager.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/router/app_router.dart';
` + providerImports + `

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final tokenManager = TokenManager();
  final dioClient = DioClient(tokenManager: tokenManager);
  final authService = AuthService(dioClient.dio);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService, tokenManager)),
        ` + providerInjects + `
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
`;

fs.writeFileSync(path.join(projectDir, 'main.dart'), mainDart);

const appRouterContent = `import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/auth/presentation/screens/splash_page.dart';
import '../../features/dashboard/presentation/screens/platform_home.dart';
import '../../features/dashboard/presentation/screens/company_home.dart';
import '../../features/dashboard/presentation/screens/employee_home.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
` + modules.map(m => "import '../../features/" + m + "/presentation/screens/" + m + "_list_screen.dart';").join('\n') + `

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

      final isLoginPath = state.uri.path == '/login';

      if (!isAuthenticated && !isLoginPath) {
        return '/login';
      }

      if (isAuthenticated && (isLoginPath || state.uri.path == '/')) {
        if (user?.role == 'platform_admin') return '/platform/home';
        if (user?.role == 'company_admin') return '/company/home';
        return '/employee/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/platform/home', builder: (_, __) => const PlatformHome()),
      GoRoute(path: '/company/home', builder: (_, __) => const CompanyHome()),
      GoRoute(path: '/employee/home', builder: (_, __) => const EmployeeHome()),
      ` + modules.map(m => "GoRoute(path: '/" + m + "', builder: (_, __) => const " + m.split('_').map(w => w[0].toUpperCase() + w.slice(1)).join('') + "ListScreen()),").join('\n      ') + `
    ],
  );
}
`;

fs.writeFileSync(path.join(projectDir, 'core/router/app_router.dart'), appRouterContent);

const platformHomeContent = `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PlatformHome extends StatelessWidget {
  const PlatformHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Platform Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Companies'), onTap: () => context.push('/companies')),
            ListTile(title: const Text('Packages'), onTap: () => context.push('/packages')),
            ListTile(title: const Text('Shipments'), onTap: () => context.push('/shipments')),
            ListTile(title: const Text('Payments'), onTap: () => context.push('/payments')),
            ListTile(title: const Text('Fees'), onTap: () => context.push('/fees')),
            ListTile(title: const Text('Bank Accounts'), onTap: () => context.push('/bank_accounts')),
            ListTile(title: const Text('Notifications'), onTap: () => context.push('/notifications')),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido \${auth.user?.fullName}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('Dashboard platform API: /api/dashboard/platform'),
          ]
        )
      ),
    );
  }
}
`;
fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), platformHomeContent);

const companyHomeContent = `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CompanyHome extends StatelessWidget {
  const CompanyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Company Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Branches'), onTap: () => context.push('/branches')),
            ListTile(title: const Text('Employees'), onTap: () => context.push('/employees')),
            ListTile(title: const Text('Sellers'), onTap: () => context.push('/sellers')),
            ListTile(title: const Text('Recipients'), onTap: () => context.push('/recipients')),
            ListTile(title: const Text('Collection Points'), onTap: () => context.push('/collection_points')),
            ListTile(title: const Text('Delivery Points'), onTap: () => context.push('/delivery_points')),
            ListTile(title: const Text('Packages'), onTap: () => context.push('/packages')),
            ListTile(title: const Text('Shipments'), onTap: () => context.push('/shipments')),
            ListTile(title: const Text('Fees'), onTap: () => context.push('/fees')),
            ListTile(title: const Text('Payments'), onTap: () => context.push('/payments')),
            ListTile(title: const Text('Bank Accounts'), onTap: () => context.push('/bank_accounts')),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido \${auth.user?.fullName}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('Dashboard company API: /api/dashboard/company'),
          ]
        )
      ),
    );
  }
}
`;
fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/company_home.dart'), companyHomeContent);

const employeeHomeContent = `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Employee'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Employee Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Mis Paquetes'), onTap: () => context.push('/packages')),
            ListTile(title: const Text('Mis Envíos'), onTap: () => context.push('/shipments')),
            ListTile(title: const Text('Notificaciones'), onTap: () => context.push('/notifications')),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hola Empleado \${auth.user?.fullName}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('Accede al menú para realizar entregas y checkins.'),
          ]
        )
      ),
    );
  }
}
`;
fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/employee_home.dart'), employeeHomeContent);

console.log('App Dashboards and CRUDs Generated');
