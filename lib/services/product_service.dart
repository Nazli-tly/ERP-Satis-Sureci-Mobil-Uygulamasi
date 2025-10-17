import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobil_satis/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    final snapshot = await _db.collection("products").get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .toList();
  }
  Future<void> addProduct(Product product) async {
    await _db.collection("products").add(product.toMap());
  }
}
