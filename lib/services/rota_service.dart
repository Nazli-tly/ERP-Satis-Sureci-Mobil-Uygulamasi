import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/siparis_model.dart';
import '../models/cari_model.dart';
import '../models/rota_item_model.dart';

class RotaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Rota>> getOnayliRotalar() async {
    try {
      final siparisSnapshot = await _db
          .collection("siparisler")
          .where("durum", isEqualTo: "Onaylandı")
          //.orderBy("tarih", descending: true)
          .get();

      List<Rota> rotalar = [];

      for (var doc in siparisSnapshot.docs) {
        final siparis = Siparis.fromMap(doc.id, doc.data());

        // cari bilgilerini çek
        final cariDoc = await _db.collection("cariler").doc(siparis.cariId).get();
        if (!cariDoc.exists) continue;

        final cari = Cari.fromMap(cariDoc.id, cariDoc.data()!);

        rotalar.add(Rota(siparis: siparis, cari: cari));
      }

      return rotalar;
    } catch (e) {
      print("Hata (getOnayliRotalar): $e");
      return [];
    }
  }
}
