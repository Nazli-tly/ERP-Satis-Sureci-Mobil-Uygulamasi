import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/rota_viewmodel.dart';
import 'rota_detay_page.dart';

class RotaListPage extends StatefulWidget {
  const RotaListPage({super.key});

  @override
  State<RotaListPage> createState() => _RotaListPageState();
}

class _RotaListPageState extends State<RotaListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RotaViewModel>(context, listen: false).loadOnayliRotalar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rota Listesi"), backgroundColor: Colors.blue),
      body: Consumer<RotaViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.rotalar.isEmpty) {
            return const Center(
              child: Text("Onaylı sipariş bulunmamaktadır."),
            );
          }

          return ListView.builder(
            itemCount: vm.rotalar.length,
            itemBuilder: (context, index) {
              final rota = vm.rotalar[index];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.local_shipping, color: Colors.blue),
                  title: Text(rota.cari.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Adres: ${rota.cari.adres}\nTelefon: ${rota.cari.telefon}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RotaDetayPage(rota: rota)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
