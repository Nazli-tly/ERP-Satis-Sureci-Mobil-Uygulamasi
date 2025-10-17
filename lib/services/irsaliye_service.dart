import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/irsaliye_model.dart';

class IrsaliyeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<IrsaliyeModel>> getIrsaliyeler() {
    return _db
        .collection("irsaliyeler")
        .orderBy("tarih", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => IrsaliyeModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addIrsaliye(IrsaliyeModel irsaliye) async {
    await _db.collection("irsaliyeler").add(irsaliye.toMap());
  }

  Future<void> deleteIrsaliye(String id) async {
    await _db.collection("irsaliyeler").doc(id).delete();
  }
}
