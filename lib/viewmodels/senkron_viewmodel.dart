import 'package:flutter/material.dart';
import '../models/senkron_model.dart';
import '../services/senkron_service.dart';

class SenkronViewModel extends ChangeNotifier {
  final SenkronService _service = SenkronService();

  bool isSyncing = false;
  String durumMesaji = "Hazır";
  List<SenkronDurum> senkronGecmisi = [];

  Future<void> tumunuSenkronizeEt() async {
    isSyncing = true;
    notifyListeners();

    await senkronizeEt("cariler");
    await senkronizeEt("stoklar");
    await senkronizeEt("faturalar");

    durumMesaji = "Tüm veriler başarıyla senkronize edildi 🎉";
    isSyncing = false;
    notifyListeners();
  }

  Future<void> senkronizeEt(String koleksiyonAdi) async {
    durumMesaji = "$koleksiyonAdi senkronize ediliyor...";
    notifyListeners();

    final sonuc = await _service.senkronizeEt(koleksiyonAdi);
    senkronGecmisi.insert(0, sonuc);

    durumMesaji = sonuc.mesaj;
    notifyListeners();
  }

  Future<void> fetchGecmis() async {
    senkronGecmisi = await _service.fetchGecmis();
    notifyListeners();
  }
}
