import '../../core/constants/app_constants.dart';
import '../../core/network/app_client.dart';
import '../../core/storage/token_storage.dart';

class AuthController {
  Future login(String email, String password) async {
    final response = await AppClient.instance.post(
      AppConstants.authLogin,
      {
        'email': email,
        'password': password,
      },
    );

    await TokenStorage.saveAccessToken(response.data['token']);
    await TokenStorage.saveRefreshToken(response.data['refreshToken']);
  }

  Future logout() async {
    await TokenStorage.clear();
  }
}
