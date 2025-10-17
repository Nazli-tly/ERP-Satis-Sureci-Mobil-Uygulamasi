import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kullanici_model.dart';

class KullaniciService {
  final _db = FirebaseFirestore.instance;

  Future<Kullanici?> fetchKullanici(String uid) async {
    final doc = await _db.collection("kullanicilar").doc(uid).get();
    if (!doc.exists) return null;
    return Kullanici.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateKullanici(Kullanici kullanici) async {
    await _db
        .collection("kullanicilar")
        .doc(kullanici.id)
        .update(kullanici.toMap());
  }

  Future<void> kaydetKullanici(Kullanici kullanici) async {
    await _db
        .collection("kullanicilar")
        .doc(kullanici.id)
        .set(kullanici.toMap());
  }
}
