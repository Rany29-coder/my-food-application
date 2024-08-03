import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'product_model.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController(); // New controller for original price
  final _expiryDateController = TextEditingController();
  final _detailsController = TextEditingController();
  final _weightController = TextEditingController(); // New controller for weight
  final _ratingController = TextEditingController(); // New controller for rating
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _originalPriceController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ratingController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final productId = _firestore.collection('products').doc().id;

        // Save image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child(DateTime.now().toString() + '.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();

        final product = Product(
          id: productId,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          originalPrice: double.parse(_originalPriceController.text),
          expiryDate: DateTime.parse(_expiryDateController.text),
          details: _detailsController.text,
          imageUrl: imageUrl,
          weight: double.parse(_weightController.text),
          rating: double.parse(_ratingController.text),
        );

        await _firestore.collection('products').doc(productId).set(product.toMap());

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _originalPriceController,
              decoration: InputDecoration(labelText: 'Original Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Details'),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (0-5)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 200)
                : Text('No image selected.'),
            TextButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addProduct,
                    child: Text('Add Product'),
                  ),
          ],
        ),
      ),
    );
  }
}
