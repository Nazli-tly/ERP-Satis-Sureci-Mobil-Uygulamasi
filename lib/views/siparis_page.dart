import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/siparis_model.dart';
import '../viewmodels/siparis_viewmodel.dart';
import 'siparis_olustur_page.dart';
import 'siparis_listesi_page.dart';

class SiparisPage extends StatelessWidget {
  const SiparisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş İşlemleri"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Yeni Sipariş Oluştur Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Yeni Sipariş Oluştur"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal.shade300,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SiparisOlusturPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Siparişleri Görüntüle Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text("Oluşturulan Siparişler"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SiparisListesiPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
