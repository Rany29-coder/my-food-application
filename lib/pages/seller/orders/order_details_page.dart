import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart' as my_app_order;

class OrderDetailsPage extends StatefulWidget {
  final my_app_order.Order order;

  const OrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateOrderStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('orders').doc(widget.order.id).update({
        'status': status,
      });

      setState(() {
        widget.order.status = status;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Customer ID: ${widget.order.buyerId}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Product Name: ${widget.order.productName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Quantity: ${widget.order.quantity}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Total Amount: \$${widget.order.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${widget.order.status}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (!_isLoading) ...[
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Processing'),
                child: Text('Mark as Processing'),
              ),
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Completed'),
                child: Text('Mark as Completed'),
              ),
              ElevatedButton(
                onPressed: () => _updateOrderStatus('Cancelled'),
                child: Text('Mark as Cancelled'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
