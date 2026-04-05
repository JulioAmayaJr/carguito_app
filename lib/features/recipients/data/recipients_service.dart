import 'package:dio/dio.dart';

class RecipientsService {
  final Dio _dio;
  RecipientsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/recipients');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/recipients/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/recipients', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/recipients/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/recipients/' + id);
  }
}
