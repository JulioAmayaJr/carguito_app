import 'package:flutter/material.dart';
import '../../data/fees_service.dart';

class FeesProvider extends ChangeNotifier {
  final FeesService _service;

  List<dynamic> items = [];
  bool isLoading = false;
  String? error;

  FeesProvider(this._service);

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _service.create(data);
      await fetchAll();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
