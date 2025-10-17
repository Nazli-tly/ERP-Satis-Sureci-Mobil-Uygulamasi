import 'package:flutter/material.dart';
import '../models/fatura_model.dart';
import '../services/fatura_service.dart';

class FaturaViewModel extends ChangeNotifier {
  final FaturaService _service = FaturaService();

  List<Fatura> _faturalar = [];
  List<Fatura> get faturalar => _faturalar;

  // 🔄 Faturaları dinle
  void fetchFaturalar() {
    _service.getFaturalar().listen((data) {
      _faturalar = data;
      notifyListeners();
    });
  }

  // ➕ Yeni fatura oluştur
  Future<void> faturaEkle(Fatura fatura) async {
    await _service.faturaOlustur(fatura);
  }

  // ❌ Fatura sil
  Future<void> faturaSil(String id) async {
    await _service.faturaSil(id);
  }

  // ✏️ Fatura güncelle
  Future<void> faturaGuncelle(String id, Map<String, dynamic> yeniData) async {
    await _service.faturaGuncelle(id, yeniData);
  }
}
