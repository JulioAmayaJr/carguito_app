import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // In-memory cache for instant access (no async delay)
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  /// Call this once at app startup to pre-load tokens from disk
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedAccessToken = prefs.getString(_accessTokenKey);
    _cachedRefreshToken = prefs.getString(_refreshTokenKey);
    print('[TokenManager] Initialized. Token present: ${_cachedAccessToken != null}');
  }

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    // Update in-memory cache immediately
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;

    // Persist to disk
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    print('[TokenManager] Tokens saved (in-memory + disk)');
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user));
  }

  /// Synchronous getter - returns cached token instantly
  String? get accessToken => _cachedAccessToken;

  /// Synchronous getter - returns cached refresh token instantly
  String? get refreshToken => _cachedRefreshToken;

  /// Async getter (fallback, reads from disk if cache is empty)
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedAccessToken = prefs.getString(_accessTokenKey);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedRefreshToken = prefs.getString(_refreshTokenKey);
    return _cachedRefreshToken;
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
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    print('[TokenManager] All tokens cleared');
  }
}
