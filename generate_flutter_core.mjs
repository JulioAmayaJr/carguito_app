import fs from 'fs';
import path from 'path';

const projectDir = '/Users/julioamaya/Projects/carguito/carguito_app/lib';

const ensureDir = (dirPath) => {
  fs.mkdirSync(dirPath, { recursive: true });
};

// Folders
ensureDir(path.join(projectDir, 'core/constants'));
ensureDir(path.join(projectDir, 'core/network'));
ensureDir(path.join(projectDir, 'core/storage'));
ensureDir(path.join(projectDir, 'core/models'));
ensureDir(path.join(projectDir, 'core/router'));
ensureDir(path.join(projectDir, 'features/auth/data'));
ensureDir(path.join(projectDir, 'features/auth/presentation/providers'));
ensureDir(path.join(projectDir, 'features/auth/presentation/screens'));
ensureDir(path.join(projectDir, 'features/dashboard/presentation/screens'));
ensureDir(path.join(projectDir, 'features/companies/presentation/screens'));
ensureDir(path.join(projectDir, 'features/shared/widgets'));

// 1. Constants
fs.writeFileSync(path.join(projectDir, 'core/constants/app_constants.dart'), `
class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';
}
`);

// 2. Storage
fs.writeFileSync(path.join(projectDir, 'core/storage/token_manager.dart'), `
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user));
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }
}
`);

// 3. User Model
fs.writeFileSync(path.join(projectDir, 'core/models/user_model.dart'), `
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role,
  };
}
`);

// 4. Network Client
fs.writeFileSync(path.join(projectDir, 'core/network/dio_client.dart'), `
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_manager.dart';

class DioClient {
  final Dio dio;
  final TokenManager tokenManager;

  DioClient({required this.tokenManager})
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await tokenManager.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshToken = await tokenManager.getRefreshToken();
            if (refreshToken != null) {
              try {
                // Determine new tokens
                final refreshOptions = Options(headers: {'Content-Type': 'application/json'});
                final response = await Dio(BaseOptions(baseUrl: AppConstants.baseUrl)).post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: refreshOptions,
                );
                
                final newAccessToken = response.data['accessToken'];
                final newRefreshToken = response.data['refreshToken'];

                await tokenManager.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                // Retry failed request
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.request(
                  e.requestOptions.path,
                  options: Options(
                    method: e.requestOptions.method,
                    headers: e.requestOptions.headers,
                  ),
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(retryResponse);
              } catch (_) {
                // Refresh token also failed or expired
                await tokenManager.clearAll();
                return handler.next(e);
              }
            } else {
              await tokenManager.clearAll();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
`);

// 5. Auth Service
fs.writeFileSync(path.join(projectDir, 'features/auth/data/auth_service.dart'), `
import 'package:dio/dio.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> me() async {
    final response = await dio.get('/auth/me');
    return response.data;
  }
}
`);

// 6. Auth Provider
fs.writeFileSync(path.join(projectDir, 'features/auth/presentation/providers/auth_provider.dart'), `
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/storage/token_manager.dart';
import '../../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenManager _tokenManager;

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  AuthProvider(this._authService, this._tokenManager) {
    _init();
  }

  Future<void> _init() async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      try {
        final userData = await _authService.me();
        _user = UserModel.fromJson(userData);
      } catch (e) {
        await _tokenManager.clearAll();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      
      await _tokenManager.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );
      
      _user = UserModel.fromJson(response['user']);
      await _tokenManager.saveUser(response['user']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _tokenManager.clearAll();
    notifyListeners();
  }
}
`);

// 7. Login Page
fs.writeFileSync(path.join(projectDir, 'features/auth/presentation/screens/login_page.dart'), `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Carguito', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                if (auth.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await auth.login(_emailController.text, _passwordController.text);
                          if (mounted && auth.isAuthenticated) {
                            if (auth.user!.role == 'platform_admin') {
                              context.go('/platform/home');
                            } else if (auth.user!.role == 'company_admin') {
                              context.go('/company/home');
                            } else {
                              context.go('/employee/home');
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: \${e.toString()}')),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
`);

// 8. Routers & Splash/Home Page stub
fs.writeFileSync(path.join(projectDir, 'features/auth/presentation/screens/splash_page.dart'), `
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
`);

fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: Center(child: Text('Hola Platform Admin: \${auth.user?.fullName}')),
    );
  }
}
`);

fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/company_home.dart'), `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: Center(child: Text('Hola Company Admin: \${auth.user?.fullName}')),
    );
  }
}
`);

fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/employee_home.dart'), `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: Center(child: Text('Hola Empleado: \${auth.user?.fullName}')),
    );
  }
}
`);

// App Router
fs.writeFileSync(path.join(projectDir, 'core/router/app_router.dart'), `
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/auth/presentation/screens/splash_page.dart';
import '../../features/dashboard/presentation/screens/platform_home.dart';
import '../../features/dashboard/presentation/screens/company_home.dart';
import '../../features/dashboard/presentation/screens/employee_home.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

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
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/platform/home',
        builder: (context, state) => const PlatformHome(),
      ),
      GoRoute(
        path: '/company/home',
        builder: (context, state) => const CompanyHome(),
      ),
      GoRoute(
        path: '/employee/home',
        builder: (context, state) => const EmployeeHome(),
      ),
    ],
  );
}
`);

// 9. Main
fs.writeFileSync(path.join(projectDir, 'main.dart'), `
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_manager.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final tokenManager = TokenManager();
  final dioClient = DioClient(tokenManager: tokenManager);
  final authService = AuthService(dioClient.dio);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService, tokenManager)),
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
`);

console.log('App Core Generated');
