class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice; // New field for original price
  final DateTime expiryDate;
  final String details;
  final String imageUrl;
  final double weight; // New field for weight
  final double rating; // New field for rating

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice, // Include original price in constructor
    required this.expiryDate,
    required this.details,
    required this.imageUrl,
    required this.weight, // Include weight in constructor
    required this.rating, // Include rating in constructor
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['productName'],
      price: map['price'],
      originalPrice: map['originalPrice'],
      expiryDate: DateTime.parse(map['expiryDate']),
      details: map['details'],
      imageUrl: map['imageUrl'],
      weight: map['weight'],
      rating: map['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': name,
      'price': price,
      'originalPrice': originalPrice,
      'expiryDate': expiryDate.toIso8601String(),
      'details': details,
      'imageUrl': imageUrl,
      'weight': weight,
      'rating': rating,
    };
  }
}
