import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fatura_model.dart';

class FaturaService {
  final _db = FirebaseFirestore.instance;
  final String _collectionPath = "faturalar";

  // 📄 Fatura oluştur
  Future<void> faturaOlustur(Fatura fatura) async {
    await _db.collection(_collectionPath).add(fatura.toMap());
  }

  // 📊 Faturaları canlı dinle
  Stream<List<Fatura>> getFaturalar() {
    return _db
        .collection(_collectionPath)
        .orderBy("tarih", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Fatura.fromMap(doc.data(), doc.id)).toList());
  }

  // ❌ Fatura sil
  Future<void> faturaSil(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }

  // ✏️ Fatura güncelle
  Future<void> faturaGuncelle(String id, Map<String, dynamic> yeniData) async {
    await _db.collection(_collectionPath).doc(id).update(yeniData);
  }
}
