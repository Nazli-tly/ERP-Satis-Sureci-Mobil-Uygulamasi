import 'package:flutter/material.dart';
import 'package:mobil_satis/views/cari_list_page.dart';
import 'package:mobil_satis/views/siparis_page.dart';
import 'package:mobil_satis/views/fatura_page.dart';
import 'package:mobil_satis/views/irsaliye_list_page.dart';
import 'package:mobil_satis/views/cek_senet_page.dart';
import 'package:mobil_satis/views/rota_list_page.dart';
import 'package:mobil_satis/views/senkron_page.dart';
import 'package:mobil_satis/views/ayarlar_page.dart';
import 'package:mobil_satis/views/product_list_page.dart';
import 'package:mobil_satis/views/firma_detay_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"title": "Cari", "icon": Icons.account_box, "color": Colors.teal, "page": const CariListPage()},
      {"title": "Stok", "icon": Icons.inventory_2, "color": Colors.green, "page": const ProductListPage()},
      {"title": "Fatura", "icon": Icons.receipt_long, "color": Colors.deepPurple, "page": const FaturaListePage()},
      {"title": "Sipariş", "icon": Icons.shopping_cart, "color": Colors.indigo, "page": const SiparisPage()},
      {"title": "İrsaliye", "icon": Icons.local_shipping, "color": Colors.deepOrange, "page": const IrsaliyeListesiPage()},
      {"title": "Çek Senet", "icon": Icons.account_balance_wallet, "color": Colors.pink, "page": const CekSenetPage()},
      {"title": "Ayarlar", "icon": Icons.settings, "color": Colors.grey, "page": const AyarlarPage()},
      {"title": "Senkron", "icon": Icons.sync, "color": Colors.cyan, "page": const SenkronPage()},
      {"title": "Rota", "icon": Icons.map, "color": Colors.blue, "page": const RotaListPage()},
      {"title": "Firma", "icon": Icons.add_business, "color": Colors.lightGreen, "page": FirmaDetayPage()}
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 2,
        title: const Text(
          "Mobil Satış Paneli",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Üst bilgi alanı
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: const [
                Text(
                  "v.02.01",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  "Şirket Kodu: TST",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Menü kartları
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: GridView.builder(
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95, // kartları biraz küçültür
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item["page"]),
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(1, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (item["color"] as Color).withOpacity(0.15),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                item["icon"],
                                size: 30,
                                color: item["color"],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["title"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Alt bilgi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
              color: Colors.white,
            ),
            child: const Text(
              "© 2025 Mobil Satış Sistemi",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
