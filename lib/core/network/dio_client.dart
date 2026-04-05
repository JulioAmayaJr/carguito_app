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
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Try synchronous in-memory token first, then fall back to async
          String? token = tokenManager.accessToken;
          token ??= await tokenManager.getAccessToken();

          print('[DioClient] ${options.method} ${options.path} | Token present: ${token != null}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('[DioClient] Got 401 on ${e.requestOptions.path}, attempting refresh...');

            String? refresh = tokenManager.refreshToken;
            refresh ??= await tokenManager.getRefreshToken();

            if (refresh != null) {
              try {
                final response = await Dio(
                  BaseOptions(baseUrl: AppConstants.baseUrl),
                ).post(
                  '/auth/refresh',
                  data: {'refreshToken': refresh},
                );

                final newAccessToken = response.data['accessToken'];
                final newRefreshToken = response.data['refreshToken'];

                await tokenManager.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                print('[DioClient] Token refreshed, retrying request...');

                // Retry the failed request with a fresh Dio (no interceptor loop)
                final reqOpts = e.requestOptions;
                final retryResponse = await Dio(
                  BaseOptions(baseUrl: AppConstants.baseUrl),
                ).request(
                  reqOpts.path,
                  data: reqOpts.data,
                  queryParameters: reqOpts.queryParameters,
                  options: Options(
                    method: reqOpts.method,
                    headers: {
                      ...reqOpts.headers,
                      'Authorization': 'Bearer $newAccessToken',
                    },
                  ),
                );
                return handler.resolve(retryResponse);
              } catch (refreshError) {
                print('[DioClient] Refresh failed: $refreshError');
                await tokenManager.clearAll();
                return handler.next(e);
              }
            } else {
              print('[DioClient] No refresh token available');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
