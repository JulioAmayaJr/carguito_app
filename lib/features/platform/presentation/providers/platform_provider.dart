import 'package:flutter/material.dart';
import '../../data/platform_service.dart';

class PlatformProvider extends ChangeNotifier {
  final PlatformService _service;

  Map<String, dynamic> config = {};
  List<dynamic> accounts = [];
  bool isLoading = false;
  String? error;

  PlatformProvider(this._service);

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      config = await _service.getConfig();
      accounts = await _service.getBankAccounts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfig(
      double fee, String currency, String vehiclePlate, int odometer) async {
    try {
      await _service.updateConfig(fee, currency, vehiclePlate, odometer);
      await loadData();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAccount(Map<String, dynamic> data) async {
    try {
      await _service.addBankAccount(data);
      await loadData();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
