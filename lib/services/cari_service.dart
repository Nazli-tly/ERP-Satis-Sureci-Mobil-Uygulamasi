import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cari_model.dart';

class CariService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Cari>> fetchCariler() async {
    final snapshot = await _db.collection("cariler").get();
    return snapshot.docs
        .map((doc) => Cari.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteCari(String id) async{
    await _db.collection("cariler").doc(id).delete();
  }

  Future<void> addCari(Cari cari) async {
    await _db.collection("cariler").add(cari.toMap());
  }
}
