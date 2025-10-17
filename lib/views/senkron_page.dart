import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/senkron_viewmodel.dart';

class SenkronPage extends StatefulWidget {
  const SenkronPage({super.key});

  @override
  State<SenkronPage> createState() => _SenkronPageState();
}

class _SenkronPageState extends State<SenkronPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SenkronViewModel>(context, listen: false).fetchGecmis());
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SenkronViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Veri Senkronizasyonu"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vm.isSyncing) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              vm.durumMesaji,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: vm.isSyncing ? null : vm.tumunuSenkronizeEt,
                    icon: const Icon(Icons.sync),
                    label: const Text("Tüm Verileri Senkronize Et"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade100,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: vm.fetchGecmis,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Geçmişi Yenile",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: vm.senkronGecmisi.isEmpty
                  ? const Center(child: Text("Henüz senkron geçmişi yok"))
                  : ListView.builder(
                itemCount: vm.senkronGecmisi.length,
                itemBuilder: (context, index) {
                  final item = vm.senkronGecmisi[index];
                  final formattedDate = DateFormat("dd/MM/yyyy HH:mm")
                      .format(item.zaman);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        item.basarili
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: item.basarili
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                      title: Text(
                        item.koleksiyonAdi.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                          "${item.mesaj}\nTarih: $formattedDate",
                          style: const TextStyle(fontSize: 13)),
                      isThreeLine: true,
                    ),
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
