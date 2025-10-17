import 'package:flutter/foundation.dart';
import '../models/cek_senet_model.dart';
import '../services/cek_senet_service.dart';

class CekSenetViewModel extends ChangeNotifier {
  final CekSenetService _service = CekSenetService();

  List<CekSenet> _cekSenetler = [];
  List<CekSenet> get cekSenetler => _cekSenetler;

  // Veri akışı başlat
  void fetchCekSenetler() {
    _service.getAllCekSenet().listen((data) {
      _cekSenetler = data;
      notifyListeners();
    });
  }

  // Yeni kayıt ekle
  Future<void> addCekSenet(CekSenet cs) async {
    await _service.addCekSenet(cs);
  }

  // Belirli faturaya göre listeleme
  Future<void> fetchByFatura(String faturaId) async {
    _service
        .getCekSenetByFatura(faturaId)
        .listen((data) {
      _cekSenetler = data;
      notifyListeners();
    });
  }


  // Sil
  Future<void> deleteCekSenet(String id) async {
    await _service.deleteCekSenet(id);
  }

  // Durum güncelle
  Future<void> updateDurum(String id, String yeniDurum) async {
    await _service.updateDurum(id, yeniDurum);
  }
}
