import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/firma_viewmodel.dart';
import '../models/firma_model.dart';
import '../models/sube_model.dart';
import '../models/depo_model.dart';

class FirmaDetayPage extends StatefulWidget {
  const FirmaDetayPage({super.key});

  @override
  State<FirmaDetayPage> createState() => _FirmaDetayPageState();
}

class _FirmaDetayPageState extends State<FirmaDetayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FirmaViewModel>(context, listen: false).loadFirmalar();
    });
  }

  // --- Dialoglar ---
  Future<void> _showAddFirmaDialog(BuildContext ctx) async {
    final c = TextEditingController();
    final vm = Provider.of<FirmaViewModel>(ctx, listen: false);
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Firma"),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: "Firma adı")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton.icon(
            onPressed: () async {
              final name = c.text.trim();
              if (name.isNotEmpty) {
                await vm.addFirma(Firma(id: '', ad: name));
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.check),
            label: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  Future<void> _showAddSubeDialog(BuildContext ctx, String firmaId) async {
    final c = TextEditingController();
    final vm = Provider.of<FirmaViewModel>(ctx, listen: false);
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Şube"),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: "Şube adı")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton.icon(
            onPressed: () async {
              final name = c.text.trim();
              if (name.isNotEmpty) {
                await vm.addSube(firmaId, Sube(id: '', firmaId: firmaId, ad: name));
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.check),
            label: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  Future<void> _showAddDepoDialog(BuildContext ctx, String firmaId, String subeId) async {
    final c = TextEditingController();
    final vm = Provider.of<FirmaViewModel>(ctx, listen: false);
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Depo"),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: "Depo adı")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton.icon(
            onPressed: () async {
              final name = c.text.trim();
              if (name.isNotEmpty) {
                await vm.addDepo(firmaId, subeId, Depo(id: '', firmaId: firmaId, subeId: subeId, ad: name));
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.check),
            label: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Firmalar"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Consumer<FirmaViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoadingFirmalar) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.firmalar.isEmpty) {
            return const Center(child: Text("Henüz firma eklenmedi."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: vm.firmalar.length,
            itemBuilder: (context, i) {
              final firma = vm.firmalar[i];
              final subeler = vm.subelerByFirma[firma.id] ?? [];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: const Icon(Icons.business, color: Colors.black87),
                  ),
                  title: Text(firma.ad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("${subeler.length} şube"),
                  onExpansionChanged: (expanded) {
                    if (expanded) vm.loadSubelerFor(firma.id);
                  },
                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  children: [
                    if (vm.subeLoading[firma.id] == true)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    // şube kartları
                    ...subeler.map((sube) {
                      final depolar = vm.depolarBySube[sube.id] ?? [];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ExpansionTile(
                          leading: const Icon(Icons.location_city, color: Colors.blueAccent),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sube.ad),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () async {
                                  await vm.deleteSube(firma.id, sube.id);
                                },
                              )
                            ],
                          ),
                          subtitle: Text("${depolar.length} depo"),
                          onExpansionChanged: (expanded) {
                            if (expanded) vm.loadDepolarFor(firma.id, sube.id);
                          },
                          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                          children: [
                            if (vm.depoLoading[sube.id] == true)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            ...depolar.map((depo) => ListTile(
                              leading: const Icon(Icons.warehouse, color: Colors.green),
                              title: Text(depo.ad),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () async {
                                  await vm.deleteDepo(firma.id, sube.id, depo.id);
                                },
                              ),
                            )),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showAddDepoDialog(context, firma.id, sube.id),
                                icon: const Icon(Icons.add, color: Colors.green),
                                label: const Text("Depo Ekle"),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showAddSubeDialog(context, firma.id),
                        icon: const Icon(Icons.add, color: Colors.blueAccent),
                        label: const Text("Şube Ekle"),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFirmaDialog(context),
        icon: const Icon(Icons.add_business),
        label: const Text("Firma Ekle"),
      ),
    );
  }
}
