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
    print('[AuthProvider] Init: Token present: ${token != null}');
    if (token != null) {
      try {
        final userData = await _authService.me();
        _user = UserModel.fromJson(userData);
        print('[AuthProvider] Init: User loaded: ${_user?.email}');
      } catch (e) {
        print('[AuthProvider] Init: Error loading user: $e');
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
      print('[AuthProvider] Login success for: $email');

      await _tokenManager.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );

      _user = UserModel.fromJson(response['user']);
      await _tokenManager.saveUser(response['user']);
      print('[AuthProvider] Tokens and User saved');
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
