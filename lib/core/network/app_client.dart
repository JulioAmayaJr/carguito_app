import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

class AppClient {
  static final AppClient instance = AppClient._();
  late Dio dio;

  AppClient._() {
    dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await TokenStorage.getRefreshToken();
            if (refreshToken != null) {
              final response = await Dio().post(
                AppConstants.baseUrl + AppConstants.authRefresh,
                data: {'refreshToken': refreshToken},
              );

              final newToken = response.data['accessToken'];
              await TokenStorage.saveAccessToken(newToken);

              final request = error.requestOptions;
              request.headers['Authorization'] = 'Bearer $newToken';

              final retry = await dio.fetch(request);
              return handler.resolve(retry);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future get(String url) async => dio.get(url);
  Future post(String url, data) async => dio.post(url, data: data);
  Future put(String url, data) async => dio.put(url, data: data);
  Future delete(String url) async => dio.delete(url);
}
