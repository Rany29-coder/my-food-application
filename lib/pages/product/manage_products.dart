import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_product.dart';
import 'product_model.dart';
import 'add_product.dart';  // Import the AddProductPage

class ManageProducts extends StatefulWidget {
  const ManageProducts({Key? key}) : super(key: key);

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
  }

  Future<void> _incrementActiveListings() async {
    try {
      final storeDoc = await _firestore.collection('stores').doc(userId).get();
      if (storeDoc.exists) {
        int currentActiveListings = storeDoc.data()?['activeListings'] ?? 0;
        await _firestore.collection('stores').doc(userId).update({
          'activeListings': currentActiveListings + 1,
        });
      }
    } catch (e) {
      print('Error incrementing active listings: $e');
    }
  }

  Future<void> _deleteProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product['imageUrl']),
                title: Text(product['productName']),
                subtitle: Text('Price: ${product['originalPrice']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductPage(
                              product: Product.fromMap(product.data() as Map<String, dynamic>, product.id),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
