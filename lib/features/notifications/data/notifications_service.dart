import 'package:dio/dio.dart';

class NotificationsService {
  final Dio _dio;
  NotificationsService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/notifications');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/notifications/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/notifications', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/notifications/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/notifications/' + id);
  }
}
