import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String productId;
  final String productName;
  final double productPrice;
  final double originalPrice; // New field for original price
  final String productDetails;
  final String productImageUrl;
  final String ownerId;
  final double weight; // New field for weight
  final double rating; // New field for rating

  const Details({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.originalPrice, // Include original price in constructor
    required this.productDetails,
    required this.productImageUrl,
    required this.ownerId,
    required this.weight, // Include weight in constructor
    required this.rating, // Include rating in constructor
    Key? key,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final order = {
        'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
        'buyerId': user.uid,
        'ownerId': widget.ownerId,
        'productId': widget.productId,
        'productName': widget.productName,
        'quantity': _quantity,
        'status': 'Pending',
        'totalPrice': widget.productPrice * _quantity,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(order);

      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(widget.ownerId).get();
      final totalSales = (storeDoc.data()?['totalSales'] ?? 0).toDouble();
      await FirebaseFirestore.instance.collection('stores').doc(widget.ownerId).update({
        'totalSales': totalSales + order['totalPrice'],
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(widget.productImageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(widget.productName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.productDetails, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Original Price: \$${widget.originalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, decoration: TextDecoration.lineThrough)),
            Text('Discounted Price: \$${widget.productPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Weight: ${widget.weight} kg', style: TextStyle(fontSize: 16)),
            Text('Rating: ${widget.rating} / 5', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _decrementQuantity, icon: Icon(Icons.remove)),
                Text('$_quantity', style: TextStyle(fontSize: 24)),
                IconButton(onPressed: _incrementQuantity, icon: Icon(Icons.add)),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _placeOrder, child: Text('Order Now')),
            SizedBox(height: 8),
            Text('You are saving \$${(widget.originalPrice - widget.productPrice) * _quantity}', style: TextStyle(fontSize: 16, color: Colors.green)),
            Text('You are saving ${widget.weight * _quantity} kg of food', style: TextStyle(fontSize: 16, color: Colors.green)),
            SizedBox(height: 16),
            Text('Note: Don\'t take something without our label', style: TextStyle(fontSize: 14, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
