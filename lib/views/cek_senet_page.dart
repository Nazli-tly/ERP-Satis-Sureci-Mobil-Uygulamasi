import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/cek_senet_model.dart';
import '../viewmodels/cek_senet_viewmodel.dart';

class CekSenetPage extends StatefulWidget {
  final String? faturaId;
  final Map<String, dynamic>? faturaData;
  const CekSenetPage({super.key, this.faturaId, this.faturaData});

  @override
  State<CekSenetPage> createState() => _CekSenetPageState();
}

class _CekSenetPageState extends State<CekSenetPage> {
  final _formKey = GlobalKey<FormState>();
  final _tutarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  String _tur = "Çek";
  String _durum = "Bekliyor";
  DateTime _tarih = DateTime.now();

  Map<String, dynamic>? _faturaData;
  bool _loadingFatura = false;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CekSenetViewModel>(context, listen: false);

    // 1) Eğer faturaId varsa hem çek/senetleri o faturaya göre al hem de faturayı detay olarak çek
    if (widget.faturaId != null && widget.faturaId!.isNotEmpty) {
      vm.fetchByFatura(widget.faturaId!);
      _loadFatura(widget.faturaId!);
    } else {
      vm.fetchCekSenetler();
    }
  }

  Future<void> _loadFatura(String faturaId) async {
    setState(() {
      _loadingFatura = true;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('faturalar').doc(faturaId).get();
      if (doc.exists) {
        setState(() {
          _faturaData = doc.data();
        });
      } else {
        setState(() {
          _faturaData = null;
        });
      }
    } catch (e) {
      setState(() {
        _faturaData = null;
      });
      // isteğe bağlı: hata göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fatura yüklenirken hata: $e")),
      );
    } finally {
      setState(() {
        _loadingFatura = false;
      });
    }
  }

  @override
  void dispose() {
    _tutarController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  double _computeFaturaTotal() {
    if (_faturaData == null) return 0.0;
    final miktar = (_faturaData!['miktar'] ?? 0);
    final fiyat = (_faturaData!['fiyat'] ?? 0);
    double m = 0, f = 0;
    if (miktar is int) m = miktar.toDouble();
    else if (miktar is double) m = miktar;
    if (fiyat is int) f = fiyat.toDouble();
    else if (fiyat is double) f = fiyat;
    final araToplam = m * f;
    final kdv = araToplam * 0.18;
    return araToplam + kdv;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CekSenetViewModel>(context);
    final cekSenetler = vm.cekSenetler;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Çek / Senet Takibi"),
        backgroundColor: Colors.pink,
        elevation: 3,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink.shade100,
        onPressed: () => _showAddDialog(context),
        label: const Text("Yeni Ekle"),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // --- Fatura Özeti Kartı (opsiyonel) ---
          if (widget.faturaId != null) ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _loadingFatura
                  ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text("Fatura bilgileri yükleniyor..."),
                    ],
                  ),
                ),
              )
                  : _faturaData != null
                  ? Card(
                margin: EdgeInsets.zero,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long, color: Colors.pink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fatura No: ${_faturaData!['faturaNo'] ?? '-'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text("Firma: ${_faturaData!['firmaAdi'] ?? '-'}"),
                            Text("Müşteri: ${_faturaData!['cariAdi'] ?? '-'}"),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${_computeFaturaTotal().toStringAsFixed(2)} ₺",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.pink),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tarih: ${_formatFaturaDate(_faturaData!['tarih'])}",
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 12),
                      Expanded(child: Text("Fatura bulunamadı veya silinmiş.")),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // --- Liste ---
          Expanded(
            child: cekSenetler.isEmpty
                ? const Center(child: Text("Henüz kayıt bulunmuyor"))
                : ListView.builder(
              itemCount: cekSenetler.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final cs = cekSenetler[index];
                final date = _formatDate(cs.tarih);
                final renk = cs.tur == "Çek" ? Colors.indigo : Colors.teal;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: renk.withOpacity(0.2),
                      child: Icon(
                        cs.tur == "Çek" ? Icons.credit_card : Icons.note_alt,
                        color: renk,
                      ),
                    ),
                    title: Text(
                      "${cs.tur} - ${cs.tutar.toStringAsFixed(2)} ₺",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tarih: $date"),
                        Text("Durum: ${cs.durum}"),
                        if (cs.aciklama.isNotEmpty) Text("Açıklama: ${cs.aciklama}"),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case "tahsil":
                            vm.updateDurum(cs.id!, "Tahsil Edildi");
                            break;
                          case "bekle":
                            vm.updateDurum(cs.id!, "Bekliyor");
                            break;
                          case "iptal":
                            vm.updateDurum(cs.id!, "Karşılıksız");
                            break;
                          case "sil":
                            vm.deleteCekSenet(cs.id!);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "tahsil", child: Text("Tahsil Edildi")),
                        const PopupMenuItem(value: "bekle", child: Text("Bekliyor")),
                        const PopupMenuItem(value: "iptal", child: Text("Karşılıksız")),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: "sil",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Sil", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp ts) {
    try {
      final d = ts.toDate();
      return DateFormat("dd/MM/yyyy").format(d);
    } catch (_) {
      return ts.toString();
    }
  }

  String _formatFaturaDate(dynamic value) {
    try {
      if (value is Timestamp) {
        return DateFormat("dd/MM/yyyy HH:mm").format(value.toDate());
      } else if (value is DateTime) {
        return DateFormat("dd/MM/yyyy HH:mm").format(value);
      } else {
        return value?.toString() ?? '-';
      }
    } catch (_) {
      return '-';
    }
  }

  void _showAddDialog(BuildContext context) {
    // Eğer fatura var ise tutarı fatura toplamı ile doldur
    if (_faturaData != null) {
      final toplam = _computeFaturaTotal();
      _tutarController.text = toplam.toStringAsFixed(2);
    } else {
      _tutarController.clear();
    }
    _aciklamaController.clear();
    _tur = "Çek";
    _durum = "Bekliyor";
    _tarih = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yeni Çek / Senet Ekle"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _tur,
                  decoration: const InputDecoration(labelText: "Tür"),
                  items: const [
                    DropdownMenuItem(value: "Çek", child: Text("Çek")),
                    DropdownMenuItem(value: "Senet", child: Text("Senet")),
                  ],
                  onChanged: (v) => setState(() => _tur = v!),
                ),
                TextFormField(
                  controller: _tutarController,
                  decoration: const InputDecoration(labelText: "Tutar (₺)"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? "Tutar giriniz" : null,
                ),
                TextFormField(
                  controller: _aciklamaController,
                  decoration: const InputDecoration(labelText: "Açıklama"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(DateFormat("dd/MM/yyyy").format(_tarih)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _tarih,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _tarih = picked);
                        }
                      },
                      child: const Text("Tarih Seç"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade100),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final vm = Provider.of<CekSenetViewModel>(context, listen: false);
                final cs = CekSenet(
                  tur: _tur,
                  tutar: double.parse(_tutarController.text),
                  tarih: Timestamp.fromDate(_tarih),
                  durum: _durum,
                  aciklama: _aciklamaController.text.trim(),
                  faturaId: widget.faturaId,
                );
                await vm.addCekSenet(cs);
                await vm.fetchByFatura(widget.faturaId!);
                Navigator.pop(context);
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }
}
