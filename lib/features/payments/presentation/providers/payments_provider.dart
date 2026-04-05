import 'package:flutter/material.dart';
import '../../data/payments_service.dart';

class PaymentsProvider extends ChangeNotifier {
  final PaymentsService _service;

  List<dynamic> items = [];
  bool isLoading = false;
  String? error;

  PaymentsProvider(this._service);

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
