import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _service.getProducts();

    _isLoading = false;
    notifyListeners();
  }
  Future<void> addProduct(Product product) async {
    await _service.addProduct(product);
    await fetchProducts();
  }
}
