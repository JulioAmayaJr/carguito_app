import 'package:flutter/material.dart';
import '../../data/branches_service.dart';

class BranchesProvider extends ChangeNotifier {
  final BranchesService _service;
  List<dynamic> items = [];
  bool isLoading = false;
  String? error;

  BranchesProvider(this._service);

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
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.create(data);
      await fetchAll();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.update(id, data);
      await fetchAll();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.delete(id);
      await fetchAll();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
