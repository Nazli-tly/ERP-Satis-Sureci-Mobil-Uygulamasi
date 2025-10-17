import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class IrsaliyeListesiPage extends StatelessWidget {
  const IrsaliyeListesiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("İrsaliye Listesi"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("irsaliyeler")
            .orderBy("tarih", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz irsaliye bulunmuyor"));
          }

          final irsaliyeler = snapshot.data!.docs;

          return ListView.separated(
            itemCount: irsaliyeler.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final irsaliye = irsaliyeler[index];
              final data = irsaliye.data() as Map<String, dynamic>;

              final tarih = (data["tarih"] as Timestamp).toDate();
              final formattedDate =
              DateFormat("dd/MM/yyyy HH:mm").format(tarih);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.local_shipping, color: Colors.deepOrange),
                  ),
                  title: Text(
                    "İrsaliye No: ${data["irsaliyeNo"] ?? "-"}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cari: ${data["cariAdi"] ?? "-"}"),
                      Text("Ürün: ${data["urunAdi"] ?? "-"}"),
                      Text("Miktar: ${data["miktar"]}"),
                      Text("Fiyat: ${data["fiyat"]} ₺"),
                      Text("Tarih: $formattedDate"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("İrsaliye Detayı"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("İrsaliye No: ${data["irsaliyeNo"]}"),
                              Text("Firma: ${data["firmaAdi"]}"),
                              Text("Cari: ${data["cariAdi"]}"),
                              Text("Ürün: ${data["urunAdi"]}"),
                              Text("Miktar: ${data["miktar"]}"),
                              Text("Fiyat: ${data["fiyat"]} ₺"),
                              Text("Tarih: $formattedDate"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Kapat"),
                            ),
                          ],
                        ),
                      );
                    },
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
