import 'package:flutter/material.dart';
import '../models/siparis_model.dart';
import '../services/siparis_service.dart';

class SiparisViewModel extends ChangeNotifier {
  final SiparisService _service = SiparisService();
  bool isLoading = false;

  Future<void> addSiparis(Siparis siparis) async {
    isLoading = true;
    notifyListeners();

    await _service.addSiparis(siparis);

    isLoading = false;
    notifyListeners();
  }

  Stream<List<Siparis>> get siparisler => _service.getSiparisler();
}
