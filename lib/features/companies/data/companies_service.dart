import 'package:dio/dio.dart';

class CompaniesService {
  final Dio _dio;
  CompaniesService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/companies');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/companies/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/companies', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/companies/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/companies/' + id);
  }
}
