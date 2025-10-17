import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/product_viewmodel.dart';

class SiparisOlusturPage extends StatefulWidget {
  const SiparisOlusturPage({super.key});

  @override
  State<SiparisOlusturPage> createState() => _SiparisOlusturPageState();
}

class _SiparisOlusturPageState extends State<SiparisOlusturPage> {
  String? secilenCariId;
  String? secilenFirmaId;
  String? secilenUrunId;
  int miktar = 1;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductViewModel>(context, listen: false).fetchProducts());
  }

  Future<void> siparisKaydet(ProductViewModel viewModel) async {
    if (secilenUrunId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen ürün seçin")),
      );
      return;
    }

    // seçilen ürünü bul
    final urun = viewModel.products.firstWhere((p) => p.id == secilenUrunId);

    if (miktar > urun.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Yetersiz stok! Mevcut stok: ${urun.stock}")),
      );
      return;
    }

    try {
      String? cariAdi;
      String? firmaAdi;

      // Cari adı çek
      if (secilenCariId != null) {
        final cariDoc = await _db.collection('cariler').doc(secilenCariId).get();
        if (cariDoc.exists) {
          final data = cariDoc.data() as Map<String, dynamic>?;
          cariAdi = data?['ad'];
        }
      }

      // Firma adı çek
      if (secilenFirmaId != null) {
        final firmaDoc = await _db.collection('firmalar').doc(secilenFirmaId).get();
        if (firmaDoc.exists) {
          final data = firmaDoc.data() as Map<String, dynamic>?;
          firmaAdi = data?['ad'];
        }
      }

      // Siparişi kaydet
      await _db.collection("siparisler").add({
        "cariId": secilenCariId,
        "cariAdi": cariAdi,
        "firmaId": secilenFirmaId,
        "firmaAdi": firmaAdi,
        "urunId": urun.id,
        "urunAdi": urun.title,
        "fiyat": urun.price,
        "miktar": miktar,
        "tarih": Timestamp.fromDate(DateTime.now()),
        "durum": "Beklemede",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sipariş kaydedildi ✅")),
      );

      setState(() {
        secilenCariId = null;
        secilenFirmaId = null;
        secilenUrunId = null;
        miktar = 1;
      });

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydederken hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Sipariş Oluştur"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Firma seçimi
            const Text("Firma Seç"),
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection("firmalar").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final firmalar = snapshot.data!.docs;
                return DropdownButton<String>(
                  isExpanded: true,
                  value: secilenFirmaId,
                  hint: const Text("Firma seçiniz"),
                  items: firmalar.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data["ad"] ?? "Adsız"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => secilenFirmaId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Cari seçimi
            const Text("Müşteri (Cari) Seç"),
            StreamBuilder<QuerySnapshot>(
              stream: _db.collection("cariler").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final cariler = snapshot.data!.docs;
                return DropdownButton<String>(
                  isExpanded: true,
                  value: secilenCariId,
                  hint: const Text("Müşteri seçiniz"),
                  items: cariler.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data["ad"] ?? "Adsız"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => secilenCariId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Ürün seçimi
            const Text("Ürün Seç"),
            Consumer<ProductViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.products.isEmpty) {
                  return const Text("Stok listesi boş!");
                }
                return DropdownButton<String>(
                  isExpanded: true,
                  value: secilenUrunId,
                  hint: const Text("Ürün seçiniz"),
                  items: viewModel.products.map((product) {
                    return DropdownMenuItem<String>(
                      value: product.id,
                      child: Text("${product.title} - Stok: ${product.stock}"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => secilenUrunId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Miktar
            Row(
              children: [
                const Text("Miktar: "),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (miktar > 1) setState(() => miktar--);
                  },
                ),
                Text(miktar.toString(), style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() => miktar++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔹 Kaydet
            Center(
              child: Consumer<ProductViewModel>(
                builder: (context, viewModel, child) => ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Siparişi Kaydet"),
                  onPressed: () => siparisKaydet(viewModel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
