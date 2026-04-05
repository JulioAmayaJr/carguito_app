import 'package:dio/dio.dart';

class VehiclesService {
  final Dio _dio;
  VehiclesService(this._dio);

  Future<List<dynamic>> getAll({bool activeOnly = false}) async {
    final q = activeOnly ? '?active_only=1' : '';
    final response = await _dio.get('/vehicles$q');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/vehicles/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/vehicles', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/vehicles/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/vehicles/$id');
  }
}
