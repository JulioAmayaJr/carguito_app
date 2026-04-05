import 'package:dio/dio.dart';

class SellersService {
  final Dio _dio;
  SellersService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/sellers');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/sellers/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/sellers', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/sellers/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/sellers/' + id);
  }
}
