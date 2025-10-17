import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/senkron_model.dart';

class SenkronService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<SenkronDurum> senkronizeEt(String koleksiyonAdi) async {
    try {
      final snapshot = await _db.collection(koleksiyonAdi).get();
      for (var doc in snapshot.docs) {
        print("✅ [$koleksiyonAdi] ${doc.id} => ${doc.data()}");
      }

      final durum = SenkronDurum(
        id: '',
        koleksiyonAdi: koleksiyonAdi,
        basarili: true,
        zaman: DateTime.now(),
        mesaj: "$koleksiyonAdi başarıyla senkronize edildi",
      );

      await _db.collection("senkronGecmisi").add(durum.toMap());
      return durum;
    } catch (e) {
      final durum = SenkronDurum(
        id: '',
        koleksiyonAdi: koleksiyonAdi,
        basarili: false,
        zaman: DateTime.now(),
        mesaj: "❌ $koleksiyonAdi senkron hatası: $e",
      );
      await _db.collection("senkronGecmisi").add(durum.toMap());
      return durum;
    }
  }

  Future<List<SenkronDurum>> fetchGecmis() async {
    final snapshot = await _db
        .collection("senkronGecmisi")
        .orderBy("zaman", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SenkronDurum.fromMap(doc.id, doc.data()))
        .toList();
  }
}
