import 'package:dio/dio.dart';

class FeesService {
  final Dio _dio;
  FeesService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/fees');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/fees/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/fees', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/fees/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/fees/' + id);
  }
}
