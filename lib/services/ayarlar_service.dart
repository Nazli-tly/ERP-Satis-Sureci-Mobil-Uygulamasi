import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ayarlar_model.dart';

class AyarlarService {
  final _db = FirebaseFirestore.instance;

  Future<void> kaydetVeyaGuncelle(Ayarlar ayarlar) async {
    final query = await _db
        .collection("ayarlar")
        .where("userId", isEqualTo: ayarlar.userId)
        .get();

    if (query.docs.isEmpty) {
      await _db.collection("ayarlar").add(ayarlar.toMap());
    } else {
      await _db
          .collection("ayarlar")
          .doc(query.docs.first.id)
          .update(ayarlar.toMap());
    }
  }

  Future<Ayarlar?> getirAyarlar(String userId) async {
    final snapshot = await _db
        .collection("ayarlar")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Ayarlar.fromMap(doc.id, doc.data());
  }
}
