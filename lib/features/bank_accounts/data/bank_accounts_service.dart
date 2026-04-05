import 'package:dio/dio.dart';

class BankAccountsService {
  final Dio _dio;
  BankAccountsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/bank-accounts');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/bank-accounts/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/bank-accounts', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/bank-accounts/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/bank-accounts/' + id);
  }
}
