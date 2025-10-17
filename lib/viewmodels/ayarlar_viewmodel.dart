import 'package:flutter/material.dart';
import '../models/ayarlar_model.dart';
import '../services/ayarlar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AyarlarViewModel extends ChangeNotifier {
  final AyarlarService _service = AyarlarService();
  Ayarlar? ayarlar;

  Future<void> getirAyarlar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    ayarlar = await _service.getirAyarlar(user.uid);
    notifyListeners();
  }

  Future<void> kaydet(String adSoyad, String telefon, String departman, String tema) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final yeniAyar = Ayarlar(
      id: ayarlar?.id ?? "",
      userId: user.uid,
      adSoyad: adSoyad,
      telefon: telefon,
      departman: departman,
      tema: tema,
    );

    await _service.kaydetVeyaGuncelle(yeniAyar);
    ayarlar = yeniAyar;
    notifyListeners();
  }
}
