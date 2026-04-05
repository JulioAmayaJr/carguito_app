import 'package:dio/dio.dart';

class BranchesService {
  final Dio _dio;
  BranchesService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/branches');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/branches/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/branches', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/branches/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/branches/' + id);
  }
}
