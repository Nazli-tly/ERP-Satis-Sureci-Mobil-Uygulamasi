import 'package:cloud_firestore/cloud_firestore.dart';

class Siparis {
  final String id;
  final String cariId;
  final String urunId;
  final int miktar;
  final DateTime tarih;
  final bool onay;      // Sipariş onaylandı mı?
  final String durum;   // Siparişin durumu: "Beklemede", "Teslim Edildi" vs.

  Siparis({
    required this.id,
    required this.cariId,
    required this.urunId,
    required this.miktar,
    required this.tarih,
    required this.onay,
    required this.durum,
  });

  factory Siparis.fromMap(String id, Map<String, dynamic> map) {
    return Siparis(
      id: id,
      cariId: map["cariId"] ?? "",
      urunId: map["urunId"] ?? "",
      miktar: map["miktar"] ?? 0,
      tarih: (map["tarih"] as Timestamp).toDate(),
      onay: map["onay"] ?? false,
      durum: map["durum"] ?? "Beklemede", // Varsayılan değer
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "cariId": cariId,
      "urunId": urunId,
      "miktar": miktar,
      "tarih": tarih,
      "onay": onay,
      "durum": durum,
    };
  }
}
