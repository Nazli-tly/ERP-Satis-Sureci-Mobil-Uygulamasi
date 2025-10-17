import 'package:cloud_firestore/cloud_firestore.dart';

class IrsaliyeModel {
  final String id;
  final String irsaliyeNo;
  final String cariAdi;
  final String urunAdi;
  final int miktar;
  final double fiyat;
  final DateTime tarih;

  IrsaliyeModel({
    required this.id,
    required this.irsaliyeNo,
    required this.cariAdi,
    required this.urunAdi,
    required this.miktar,
    required this.fiyat,
    required this.tarih,
  });

  factory IrsaliyeModel.fromMap(Map<String, dynamic> map, String docId) {
    return IrsaliyeModel(
      id: docId,
      irsaliyeNo: map["irsaliyeNo"] ?? "",
      cariAdi: map["cariAdi"] ?? "",
      urunAdi: map["urunAdi"] ?? "",
      miktar: map["miktar"] ?? 0,
      fiyat: (map["fiyat"] ?? 0).toDouble(),
      tarih: (map["tarih"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "irsaliyeNo": irsaliyeNo,
      "cariAdi": cariAdi,
      "urunAdi": urunAdi,
      "miktar": miktar,
      "fiyat": fiyat,
      "tarih": tarih,
    };
  }
}
