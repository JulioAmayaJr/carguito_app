import 'package:dio/dio.dart';

class PlatformService {
  final Dio _dio;
  PlatformService(this._dio);

  Future<Map<String, dynamic>> getConfig() async {
    final res = await _dio.get('/platform/config');
    return res.data;
  }

  Future<Map<String, dynamic>> updateConfig(
      double fee, String currency, String vehiclePlate, int odometer) async {
    final res = await _dio.put('/platform/config', data: {
      'default_service_fee_amount': fee,
      'fee_currency': currency,
      'vehicle_plate': vehiclePlate,
      'odometer': odometer,
    });
    return res.data;
  }

  Future<List<dynamic>> getBankAccounts() async {
    final res = await _dio.get('/platform/bank-accounts');
    return res.data;
  }

  Future<Map<String, dynamic>> addBankAccount(Map<String, dynamic> data) async {
    final res = await _dio.post('/platform/bank-accounts', data: data);
    return res.data;
  }
}
