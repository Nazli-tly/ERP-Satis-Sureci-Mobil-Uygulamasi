import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiparisListesiPage extends StatelessWidget {
  const SiparisListesiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    // 🗑 Sipariş Silme
    Future<void> _siparisSil(String docId) async {
      await _db.collection("siparisler").doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sipariş silindi ❌")),
      );
    }

    // ✏ Sipariş Güncelleme (miktar)
    Future<void> _siparisGuncelle(
        BuildContext context, String docId, int mevcutMiktar) async {
      final TextEditingController miktarController =
      TextEditingController(text: mevcutMiktar.toString());

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Siparişi Güncelle"),
          content: TextField(
            controller: miktarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Yeni miktar"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Vazgeç"),
            ),
            ElevatedButton(
              onPressed: () async {
                final yeniMiktar = int.tryParse(miktarController.text);
                if (yeniMiktar != null && yeniMiktar > 0) {
                  await _db
                      .collection("siparisler")
                      .doc(docId)
                      .update({"miktar": yeniMiktar});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sipariş güncellendi ✅")),
                  );
                }
                Navigator.pop(ctx);
              },
              child: const Text("Kaydet"),
            ),
          ],
        ),
      );
    }

    // 🔧 Stok düşürme (atomik, transaction ile)
    Future<void> _stokDusurTransactionere(
        String urunId, int siparisMiktari) async {
      final DocumentReference urunRef = _db.collection('products').doc(urunId);

      await _db.runTransaction((transaction) async {
        final urunSnap = await transaction.get(urunRef);
        if (!urunSnap.exists) {
          throw Exception('Ürün bulunamadı');
        }

        // stock alanı integer olarak saklanmalı
        final int mevcutStok = (urunSnap.get('stock') ?? 0) is int
            ? urunSnap.get('stock')
            : (urunSnap.get('stock') as num).toInt();

        final int yeniStok = mevcutStok - siparisMiktari;

        if (yeniStok < 0) {
          throw Exception(
              'Stok yetersiz (mevcut: $mevcutStok, istenen: $siparisMiktari)');
        }

        transaction.update(urunRef, {'stock': yeniStok});
      });
    }

    // ✅ Onayla butonuna tıklandığında: önce stok kontrol & düşür, sonra sipariş durumunu güncelle
    Future<void> _onaylaVeStokDusur(
        BuildContext context, String siparisId, Map<String, dynamic> data) async {
      final urunId = data['urunId'];
      final siparisMiktar = (data['miktar'] ?? 0) is int
          ? data['miktar']
          : (data['miktar'] as num).toInt();

      if (urunId == null || urunId.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Siparişte ürün id yok, işlem iptal edildi.")),
        );
        return;
      }

      try {
        // 1) stok düşürme (transaction içinde)
        await _stokDusurTransactionere(urunId.toString(), siparisMiktar);

        // 2) sipariş durumunu güncelle (stok düşürme başarılı ise)
        await _db.collection("siparisler").doc(siparisId).update({
          'durum': 'Onaylandı',
          'stokDusuldu': true,
          'onayTarihi': Timestamp.fromDate(DateTime.now()),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sipariş onaylandı ve stok güncellendi ✅")),
        );
      } catch (e) {
        // hata: ürün yok veya stok yetersiz veya transaction hatası
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Onay başarısız: ${e.toString()}")),
        );
      }
    }

    // 🔄 Reddet (yalnızca durum değiştirir)
    Future<void> _durumGuncelle(String docId, String durum) async {
      await _db.collection("siparisler").doc(docId).update({"durum": durum});
    }

    // 📑 Faturalandırma
    Future<void> _faturalandir(Map<String, dynamic> data, String docId) async {
      await _db.collection("faturalar").add({
        "cariAdi": data["cariAdi"],
        "urunAdi": data["urunAdi"],
        "firmaAdi": data["firmaAdi"],
        "miktar": data["miktar"],
        "fiyat": data["fiyat"],
        "siparisId": docId,
        "tarih": DateTime.now(),
      });

      await _db
          .collection("siparisler")
          .doc(docId)
          .update({"faturalandi": true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sipariş faturalandırıldı 📑")),
      );
    }

    // 🚚 İrsaliye Çıkartma
    Future<void> _irsaliyeCikar(Map<String, dynamic> data, String docId) async {
      await _db.collection("irsaliyeler").add({
        "cariAdi": data["cariAdi"],
        "firmaAdi": data["firmaAdi"],
        "urunAdi": data["urunAdi"],
        "miktar": data["miktar"],
        "fiyat": data["fiyat"],
        "siparisId": docId,
        "tarih": DateTime.now(),
      });

      await _db
          .collection("siparisler")
          .doc(docId)
          .update({"irsaliyeCikti": true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İrsaliye belgesi çıkarıldı 🚚")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş Listesi"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        _db.collection("siparisler").orderBy("tarih", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz sipariş bulunmuyor"));
          }

          final siparisler = snapshot.data!.docs;

          return ListView.separated(
            itemCount: siparisler.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final siparis = siparisler[index];
              final data = siparis.data() as Map<String, dynamic>;

              final durum = data["durum"] ?? "Beklemede";
              final faturalandi = data["faturalandi"] ?? false;
              final irsaliyeCikti = data["irsaliyeCikti"] ?? false;

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.shopping_cart, color: Colors.teal),
                  ),
                  title: Text(
                    data["urunAdi"] ?? "Ürün adı yok",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Firma: ${data["firmaAdi"] ?? data["firmaId"] ?? "-"}"),
                      Text("Cari: ${data["cariAdi"] ?? data["cariId"] ?? "-"}"),
                      Text("Miktar: ${data["miktar"]}"),
                      Text("Fiyat: ${data["fiyat"]} ₺"),
                      Text("Durum: $durum"),
                      if (faturalandi)
                        const Text("📑 Faturalandı", style: TextStyle(color: Colors.green)),
                      if (irsaliyeCikti)
                        const Text("🚚 İrsaliye Çıktı", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      // ✅ Onay (artık stok düşürme ile birlikte)
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _onaylaVeStokDusur(context, siparis.id, data),
                      ),
                      // ❌ Reddet
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _durumGuncelle(siparis.id, "Reddedildi"),
                      ),
                      // 📑 Faturalandırma
                      IconButton(
                        icon: const Icon(Icons.receipt_long, color: Colors.orange),
                        onPressed: (durum == "Teslim Edildi" && !faturalandi)
                            ? () => _faturalandir(data, siparis.id)
                            : null,
                      ),
                      // 🚚 İrsaliye Çıkartma
                      IconButton(
                        icon: const Icon(Icons.local_shipping, color: Colors.blueAccent),
                        onPressed: (durum == "Onaylandı" && !irsaliyeCikti)
                            ? () => _irsaliyeCikar(data, siparis.id)
                            : null,
                      ),
                      // ✏ Güncelleme
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _siparisGuncelle(context, siparis.id, data["miktar"]),
                      ),
                      // 🗑 Silme
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Siparişi Sil"),
                              content: const Text("Bu siparişi silmek istediğinize emin misiniz?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _siparisSil(siparis.id);
                                  },
                                  child: const Text("Sil"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
