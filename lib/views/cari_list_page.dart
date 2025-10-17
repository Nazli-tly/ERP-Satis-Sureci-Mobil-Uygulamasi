import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cari_viewmodel.dart';
import '../models/cari_model.dart';

class CariListPage extends StatefulWidget {
  const CariListPage({super.key});

  @override
  State<CariListPage> createState() => _CariListPageState();
}

class _CariListPageState extends State<CariListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CariViewModel>(context, listen: false).loadCariler();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CariViewModel>(context);

    Future<void> _cariSil(String docId) async {
      await Provider.of<CariViewModel>(context, listen: false).deleteCari(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri silindi ✅")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        title: const Text("Cari Kart Listesi"),
        backgroundColor: Colors.teal.shade600,
        elevation: 3,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.cariler.isEmpty
          ? const Center(
        child: Text(
          "Kayıtlı cari bulunamadı.",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: vm.cariler.length,
        itemBuilder: (context, index) {
          final cari = vm.cariler[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              title: Text(
                cari.ad,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "${cari.telefon}\n${cari.adres}\n${cari.gmail}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Müşteri Sil"),
                      content: const Text("Bu müşteriyi silmek istediğinize emin misiniz?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Vazgeç")),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _cariSil(cari.id);
                          },
                          child: const Text("Sil"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCariDialog(context),
        backgroundColor: Colors.teal.shade600,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Cari"),
      ),
    );
  }

  void _showAddCariDialog(BuildContext context) {
    final adController = TextEditingController();
    final telController = TextEditingController();
    final adresController = TextEditingController();
    final gmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Yeni Cari Ekle"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(adController, "Ad Soyad", Icons.person),
              _buildTextField(telController, "Telefon", Icons.phone),
              _buildTextField(adresController, "Adres", Icons.location_on),
              _buildTextField(gmailController, "Gmail", Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              final cari = Cari(
                id: '',
                ad: adController.text,
                telefon: telController.text,
                adres: adresController.text,
                gmail: gmailController.text,
              );
              Provider.of<CariViewModel>(context, listen: false).addCari(cari);
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
