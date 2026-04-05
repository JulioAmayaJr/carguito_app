import 'package:dio/dio.dart';

class DeliveryPointsService {
  final Dio _dio;
  DeliveryPointsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/delivery-points');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/delivery-points/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/delivery-points', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/delivery-points/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/delivery-points/' + id);
  }
}
