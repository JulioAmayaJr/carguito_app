import 'package:dio/dio.dart';

class EmployeesService {
  final Dio _dio;
  EmployeesService(this._dio);

  Future<List<dynamic>> getAll() async {
    final response = await _dio.get('/employees');
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dio.get('/employees/' + id);
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/employees', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/employees/' + id, data: data);
    return response.data;
  }

  Future<void> delete(String id) async {
    await _dio.delete('/employees/' + id);
  }
}
