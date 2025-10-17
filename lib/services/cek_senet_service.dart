import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cek_senet_model.dart';

class CekSenetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Yeni çek/senet ekleme
  Future<void> addCekSenet(CekSenet cs) async {
    await _db.collection("cek_senet").add(cs.toMap());
  }

  // Fatura bazlı çek/senet ekleme (alt koleksiyon)
  Future<void> addCekSenetForFatura(String faturaId, CekSenet cs) async {
    await _db
        .collection("faturalar")
        .doc(faturaId)
        .collection("cek_senet")
        .add(cs.toMap());
  }

  // Tüm çek/senetleri listeleme
  Stream<List<CekSenet>> getAllCekSenet() {
    return _db
        .collection("cek_senet")
        .orderBy("tarih", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CekSenet.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Belirli faturaya ait çek/senetleri getir
  Stream<List<CekSenet>> getCekSenetByFatura(String faturaId) {
    return _db
        .collection("faturalar")
        .doc(faturaId)
        .collection("cek_senet")
        .orderBy("tarih", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CekSenet.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Çek/senet silme
  Future<void> deleteCekSenet(String id) async {
    await _db.collection("cek_senet").doc(id).delete();
  }

  // Durum güncelleme
  Future<void> updateDurum(String id, String yeniDurum) async {
    await _db.collection("cek_senet").doc(id).update({"durum": yeniDurum});
  }
}
