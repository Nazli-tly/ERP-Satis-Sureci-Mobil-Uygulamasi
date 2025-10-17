import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rota_item_model.dart';

class RotaDetayPage extends StatelessWidget {
  final Rota rota;
  const RotaDetayPage({super.key, required this.rota});

  Future<void> _teslimEt(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("siparisler")
          .doc(rota.siparis.id)
          .update({
        "durum": "Teslim Edildi",
        "teslimTarihi": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teslimat tamamlandı ✅")),
      );

      Navigator.pop(context); // listeye geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  Widget _buildTimelineStep(String title, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: done ? FontWeight.bold : FontWeight.normal,
            color: done ? Colors.green : Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final siparis = rota.siparis;
    final cari = rota.cari;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rota Detayı"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 📌 Müşteri Kartı
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("👤 Müşteri Bilgileri",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text("Ad: ${cari.ad}", style: const TextStyle(fontSize: 16)),
                        Text("Telefon: ${cari.telefon}"),
                        Text("Adres: ${cari.adres}"),
                        Text("Gmail: ${cari.gmail}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 📌 Sipariş Kartı
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("📦 Sipariş Bilgileri",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text("Ürün ID: ${siparis.urunId}"),
                        Text("Miktar: ${siparis.miktar}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 📌 Teslim Et Butonu
          SafeArea(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _teslimEt(context),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Teslim Edildi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
