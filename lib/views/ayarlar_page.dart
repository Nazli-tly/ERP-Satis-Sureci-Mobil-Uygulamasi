import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ayarlar_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AyarlarPage extends StatefulWidget {
  const AyarlarPage({super.key});

  @override
  State<AyarlarPage> createState() => _AyarlarPageState();
}

class _AyarlarPageState extends State<AyarlarPage> {
  final _formKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _telefonController = TextEditingController();
  final _departmanController = TextEditingController();
  String _tema = "Aydınlık";

  bool _duzenlemeModu = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vm = Provider.of<AyarlarViewModel>(context, listen: false);
      await vm.getirAyarlar();
      if (vm.ayarlar != null) {
        _adSoyadController.text = vm.ayarlar!.adSoyad;
        _telefonController.text = vm.ayarlar!.telefon;
        _departmanController.text = vm.ayarlar!.departman;
        _tema = vm.ayarlar!.tema;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AyarlarViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo[400],
        title: const Text("Kullanıcı Ayarları"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _duzenlemeModu ? _buildForm(vm, user) : _buildProfileCard(vm, user),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo[200],
        onPressed: () => setState(() => _duzenlemeModu = !_duzenlemeModu),
        icon: Icon(_duzenlemeModu ? Icons.close : Icons.edit),
        label: Text(_duzenlemeModu ? "İptal" : "Bilgileri Düzenle"),
      ),
    );
  }

  // PROFİL GÖRÜNÜMÜ
  Widget _buildProfileCard(AyarlarViewModel vm, User? user) {
    if (vm.ayarlar == null) {
      return _emptyProfile();
    }

    final data = vm.ayarlar!;
    return Column(
      children: [
        // Profil Kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 3,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                data.adSoyad.isNotEmpty ? data.adSoyad : "Ad Soyad Belirtilmemiş",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.phone, "Telefon", data.telefon),
              _buildInfoRow(Icons.work, "Departman", data.departman),
              _buildInfoRow(Icons.color_lens, "Tema", data.tema),
            ],
          ),
        ),
      ],
    );
  }

  // PROFİL FORMU
  Widget _buildForm(AyarlarViewModel vm, User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.settings, size: 50, color: Colors.indigo),
            const SizedBox(height: 10),
            const Text(
              "Kullanıcı Bilgilerini Güncelle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField(_adSoyadController, "Ad Soyad", Icons.person),
            _buildTextField(_telefonController, "Telefon", Icons.phone),
            _buildTextField(_departmanController, "Departman", Icons.work),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _tema,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.color_lens),
                labelText: "Tema Seçimi",
                border: OutlineInputBorder(),
              ),
              items: ["Aydınlık", "Karanlık"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _tema = val ?? "Aydınlık"),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () async {
                await vm.kaydet(
                  _adSoyadController.text,
                  _telefonController.text,
                  _departmanController.text,
                  _tema,
                );
                setState(() => _duzenlemeModu = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bilgiler başarıyla kaydedildi.")),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text("Kaydet"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo[600], size: 22),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value.isNotEmpty ? value : "-", overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _emptyProfile() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.person_outline, size: 100, color: Colors.grey),
        const SizedBox(height: 10),
        const Text("Henüz kullanıcı bilgileri eklenmemiş.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => setState(() => _duzenlemeModu = true),
          icon: const Icon(Icons.add),
          label: const Text("Bilgileri Ekle"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[600],
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}
