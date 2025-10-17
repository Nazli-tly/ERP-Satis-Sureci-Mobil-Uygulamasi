import 'package:flutter/material.dart';
import '../models/cari_model.dart';
import '../services/cari_service.dart';

class CariViewModel extends ChangeNotifier {
  final CariService _service = CariService();
  List<Cari> cariler = [];
  bool isLoading = false;

  Future<void> loadCariler() async {
    isLoading = true;
    notifyListeners();

    cariler = await _service.fetchCariler();

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCari(String id) async{
    await _service.deleteCari(id);
    await loadCariler();
  }
  Future<void> addCari(Cari cari) async {
    await _service.addCari(cari);
    await loadCariler();
  }
}
