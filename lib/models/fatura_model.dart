import 'package:cloud_firestore/cloud_firestore.dart';

class Fatura {
  final String id;
  final String siparisId;
  final String cariAdi;
  final String firmaAdi;
  final List<Map<String, dynamic>> urunler;
  final double toplamTutar;
  final DateTime tarih;

  Fatura({
    required this.id,
    required this.siparisId,
    required this.cariAdi,
    required this.firmaAdi,
    required this.urunler,
    required this.toplamTutar,
    required this.tarih,
  });

  factory Fatura.fromMap(Map<String, dynamic> data, String docId) {
    return Fatura(
      id: docId,
      siparisId: data["siparisId"] ?? "",
      cariAdi: data["cariAdi"] ?? "",
      firmaAdi: data["firmaAdi"] ?? "",
      urunler: List<Map<String, dynamic>>.from(data["urunler"] ?? []),
      toplamTutar: (data["toplamTutar"] ?? 0).toDouble(),
      tarih: (data["tarih"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "siparisId": siparisId,
      "cariAdi": cariAdi,
      "firmaAdi": firmaAdi,
      "urunler": urunler,
      "toplamTutar": toplamTutar,
      "tarih": tarih,
    };
  }
}
