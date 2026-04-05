import 'package:dio/dio.dart';

class CollectionPointsService {
  final Dio _dio;
  CollectionPointsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/collection-points');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/collection-points/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/collection-points', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/collection-points/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/collection-points/' + id);
  }
}
