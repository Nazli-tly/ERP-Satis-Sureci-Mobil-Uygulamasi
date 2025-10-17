import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'cek_senet_page.dart';

class FaturaListePage extends StatelessWidget {
  const FaturaListePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Faturalar"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("faturalar")
            .orderBy("tarih", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz fatura bulunmuyor"));
          }

          final faturalar = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faturalar.length,
            itemBuilder: (context, index) {
              final fatura = faturalar[index];
              final data = fatura.data() as Map<String, dynamic>;
              final tarih =
              DateFormat("dd/MM/yyyy HH:mm").format((data["tarih"] as Timestamp).toDate());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
                  ),
                  title: Text(
                    "Fatura No: ${data["faturaNo"] ?? "-"}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("Tarih: $tarih"),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FaturaDetayPage(
                            faturaId: fatura.id,
                            faturaData: data,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text("Görüntüle"),
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

class FaturaDetayPage extends StatelessWidget {
  final String faturaId;
  final Map<String, dynamic> faturaData;

  const FaturaDetayPage({super.key, required this.faturaData, required this.faturaId});

  Future<void> _pdfOlustur(BuildContext context) async {
    final pdf = pw.Document();
    final tarih = (faturaData["tarih"] as Timestamp).toDate();
    final miktar = faturaData["miktar"] ?? 0;
    final fiyat = faturaData["fiyat"] ?? 0;
    final araToplam = miktar * fiyat;
    final kdv = araToplam * 0.18;
    final genelToplam = araToplam + kdv;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("FATURA DETAYI",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 10),
              pw.Text("Fatura No: ${faturaData["faturaNo"] ?? "-"}"),
              pw.Text("Tarih: ${DateFormat("dd/MM/yyyy HH:mm").format(tarih)}"),
              pw.Divider(),
              pw.Text("Firma: ${faturaData["firmaAdi"] ?? "-"}"),
              pw.Text("Müşteri: ${faturaData["cariAdi"] ?? "-"}"),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Ürün", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(faturaData["urunAdi"] ?? "-")),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child:
                        pw.Text("Miktar", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("$miktar")),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Birim Fiyat",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("$fiyat ₺")),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Ara Toplam",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("${araToplam.toStringAsFixed(2)} ₺")),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child:
                        pw.Text("KDV (%18)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("${kdv.toStringAsFixed(2)} ₺")),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Genel Toplam",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("${genelToplam.toStringAsFixed(2)} ₺")),
                  ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Teşekkür ederiz!",
                    style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );

    // printing paketiyle yazdırma / indirme penceresini aç
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _silFatura(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    await db.collection("faturalar").doc(faturaId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fatura başarıyla silindi.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tarih = (faturaData["tarih"] as Timestamp).toDate();
    final miktar = faturaData["miktar"] ?? 0;
    final fiyat = faturaData["fiyat"] ?? 0;
    final araToplam = miktar * fiyat;
    final kdv = araToplam * 0.18;
    final genelToplam = araToplam + kdv;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fatura Detayı"),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white,),
            tooltip: "PDF indir",
            onPressed: () => _pdfOlustur(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color:Colors.white),
            tooltip: "Faturayı sil",
            onPressed: () => _silFatura(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧾 Üst Bilgi Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.deepPurple, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fatura No: ${faturaData["faturaNo"] ?? "-"}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(DateFormat("dd/MM/yyyy HH:mm").format(tarih),
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🏢 Firma & Müşteri Bilgileri Kartı
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Firma & Müşteri Bilgileri",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Firma:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(faturaData["firmaAdi"] ?? "-"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Müşteri:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(faturaData["cariAdi"] ?? "-"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Ürün Detay Kartı
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Ürün Detayı",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    _buildRow("Ürün", faturaData["urunAdi"] ?? "-"),
                    _buildRow("Miktar", "$miktar"),
                    _buildRow("Birim Fiyat", "$fiyat ₺"),
                    _buildRow("Ara Toplam", "${araToplam.toStringAsFixed(2)} ₺"),
                    _buildRow("KDV (%18)", "${kdv.toStringAsFixed(2)} ₺"),
                    const Divider(),
                    _buildRow("Genel Toplam", "${genelToplam.toStringAsFixed(2)} ₺",
                        color: Colors.deepPurple, bold: true),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final db = FirebaseFirestore.instance;

                        // Bu faturaya ait çek/senet var mı kontrol et
                        final existing = await db
                            .collection("cek_senet")
                            .where("faturaId", isEqualTo: faturaId)
                            .limit(1)
                            .get();

                        if (existing.docs.isNotEmpty) {
                          // Zaten kayıt varsa tekrar eklemeyi engelle
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bu fatura için zaten bir ödeme kaydı mevcut."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        // Eğer yoksa yönlendir
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CekSenetPage(
                              faturaId: faturaId,
                              faturaData: faturaData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text("Ödemeye Geç"),
                    )

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


