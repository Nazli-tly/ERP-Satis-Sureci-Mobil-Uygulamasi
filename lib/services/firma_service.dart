import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firma_model.dart';
import '../models/sube_model.dart';
import '../models/depo_model.dart';

class FirmaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firmaları getir
  Future<List<Firma>> getFirmalar() async {
    final snap = await _db.collection('firmalar').get();
    return snap.docs.map((d) => Firma.fromMap(d.id, d.data())).toList();
  }

  // Bir firmaya ait şubeleri getir
  Future<List<Sube>> getSubeler(String firmaId) async {
    final snap = await _db
        .collection('firmalar')
        .doc(firmaId)
        .collection('subeler')
        .get();
    return snap.docs.map((d) => Sube.fromMap(d.id, d.data())).toList();
  }

  // Bir şubeye ait depoları getir
  Future<List<Depo>> getDepolar(String firmaId, String subeId) async {
    final snap = await _db
        .collection('firmalar')
        .doc(firmaId)
        .collection('subeler')
        .doc(subeId)
        .collection('depolar')
        .get();
    return snap.docs.map((d) => Depo.fromMap(d.id, d.data())).toList();
  }

  // Yeni firma ekle
  Future<void> addFirma(Firma f) async {
    await _db.collection('firmalar').add(f.toMap());
  }

  // Yeni şube ekle (sube içinde firmaId tutuluyor)
  Future<void> addSube(Sube s) async {
    await _db
        .collection('firmalar')
        .doc(s.firmaId)
        .collection('subeler')
        .add(s.toMap());
  }

  // Yeni depo ekle
  Future<void> addDepo(Depo d) async {
    await _db
        .collection('firmalar')
        .doc(d.firmaId)
        .collection('subeler')
        .doc(d.subeId)
        .collection('depolar')
        .add(d.toMap());
  }
  Future<void> deleteSube(String firmaId, String subeId) async {
    await _db.collection("firmalar")
        .doc(firmaId)
        .collection("subeler")
        .doc(subeId)
        .delete();
  }

  Future<void> deleteDepo(String firmaId, String subeId, String depoId) async {
    await _db.collection("firmalar")
        .doc(firmaId)
        .collection("subeler")
        .doc(subeId)
        .collection("depolar")
        .doc(depoId)
        .delete();
  }

}

