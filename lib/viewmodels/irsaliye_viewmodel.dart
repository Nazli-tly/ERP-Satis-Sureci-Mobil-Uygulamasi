import 'package:flutter/material.dart';
import '../models/irsaliye_model.dart';
import '../services/irsaliye_service.dart';

class IrsaliyeViewModel extends ChangeNotifier {
  final IrsaliyeService _service = IrsaliyeService();
  List<IrsaliyeModel> _irsaliyeler = [];

  List<IrsaliyeModel> get irsaliyeler => _irsaliyeler;

  void fetchIrsaliyeler() {
    _service.getIrsaliyeler().listen((data) {
      _irsaliyeler = data;
      notifyListeners();
    });
  }

  Future<void> addIrsaliye(IrsaliyeModel irsaliye) async {
    await _service.addIrsaliye(irsaliye);
  }

  Future<void> deleteIrsaliye(String id) async {
    await _service.deleteIrsaliye(id);
  }
}
