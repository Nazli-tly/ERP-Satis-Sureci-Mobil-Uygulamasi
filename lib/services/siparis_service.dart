import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/siparis_model.dart';

class SiparisService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addSiparis(Siparis siparis) async {
    await _db.collection("siparisler").add(siparis.toMap());
  }

  Stream<List<Siparis>> getSiparisler() {
    return _db.collection("siparisler").snapshots().map(
          (snapshot) {
        return snapshot.docs
            .map((doc) => Siparis.fromMap(doc.id, doc.data()))
            .toList();
      },
    );
  }
}
