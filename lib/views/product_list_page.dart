import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'package:mobil_satis/models/product_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductViewModel>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürünler / Stok Listesi"),
        backgroundColor: Colors.green,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: viewModel.products.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = viewModel.products[index];
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                product.title.isNotEmpty
                    ? product.title[0].toUpperCase()
                    : "?",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              product.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kod: ${product.id}"),
                Text("Stok: ${product.stock}"),
              ],
            ),
            trailing: Text(
              "${product.price.toStringAsFixed(2)} ₺",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green),
            ),
            onTap: () {
              _showProductDetail(context, product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _showAddProductDialog(context),
      ),
    );
  }

  void _showProductDetail(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ürün Kodu: ${product.id}"),
            Text("Açıklama: ${product.description}"),
            Text("Stok: ${product.stock}"),
            Text("Fiyat: ${product.price} ₺"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Ürün Ekle"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Ürün Adı"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Açıklama"),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Fiyat"),
              ),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stok Miktarı"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final desc = _descriptionController.text.trim();
              final price = double.tryParse(_priceController.text) ?? 0;
              final stock = int.tryParse(_stockController.text) ?? 0;

              if (title.isNotEmpty) {
                final newProduct = Product(
                  id: '',
                  code: '',
                  title: title,
                  description: desc,
                  price: price,
                  stock: stock,
                  image: '',
                );

                await Provider.of<ProductViewModel>(context, listen: false)
                    .addProduct(newProduct);
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
