import 'package:cloud_firestore/cloud_firestore.dart';

class CekSenet {
  final String? id;
  final String tur; // "Çek" veya "Senet"
  final double tutar;
  final Timestamp tarih;
  final String durum; // "Bekliyor", "Tahsil Edildi", "Karşılıksız"
  final String aciklama;
  final String? faturaId; // hangi fatura ile ilişkili (opsiyonel)

  CekSenet({
    this.id,
    required this.tur,
    required this.tutar,
    required this.tarih,
    required this.durum,
    required this.aciklama,
    this.faturaId,
  });

  Map<String, dynamic> toMap() {
    return {
      "tur": tur,
      "tutar": tutar,
      "tarih": tarih,
      "durum": durum,
      "aciklama": aciklama,
      "faturaId": faturaId,
    };
  }

  factory CekSenet.fromMap(Map<String, dynamic> map, String id) {
    return CekSenet(
      id: id,
      tur: map["tur"] ?? "",
      tutar: (map["tutar"] ?? 0).toDouble(),
      tarih: map["tarih"] ?? Timestamp.now(),
      durum: map["durum"] ?? "Bekliyor",
      aciklama: map["aciklama"] ?? "",
      faturaId: map["faturaId"],
    );
  }
}
