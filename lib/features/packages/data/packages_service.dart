import 'package:dio/dio.dart';

class PackagesService {
  final Dio _dio;
  PackagesService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/packages');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/packages/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/packages', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/packages/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/packages/' + id);
  }
}
