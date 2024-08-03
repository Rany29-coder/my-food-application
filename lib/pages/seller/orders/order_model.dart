class Order {
  final String id;
  final String buyerId;
  final String ownerId;
  final String productId;
  final String productName;
  final int quantity;
  late final String status;
  final double totalPrice;

  Order({
    required this.id,
    required this.buyerId,
    required this.ownerId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.totalPrice,
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      id: data['orderId'],
      buyerId: data['buyerId'],
      ownerId: data['ownerId'],
      productId: data['productId'],
      productName: data['productName'],
      quantity: data['quantity'],
      status: data['status'],
      totalPrice: data['totalPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': id,
      'buyerId': buyerId,
      'ownerId': ownerId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'status': status,
      'totalPrice': totalPrice,
    };
  }
}
