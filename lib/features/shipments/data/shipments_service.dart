import 'package:dio/dio.dart';

class ShipmentsService {
  final Dio _dio;
  ShipmentsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/shipments');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/shipments/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/shipments', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/shipments/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/shipments/' + id);
  }
}
