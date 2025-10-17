class Product {
  final String id;
  final String code;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String image;

  Product({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      code: data['code'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      image: data['image'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

}
