import 'package:dio/dio.dart';

class PaymentsService {
  final Dio _dio;
  PaymentsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/payments');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/payments/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/payments', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/payments/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/payments/' + id);
  }
}
