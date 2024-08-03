import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellerSignUpPage extends StatefulWidget {
  const SellerSignUpPage({Key? key}) : super(key: key);

  @override
  _SellerSignUpPageState createState() => _SellerSignUpPageState();
}

class _SellerSignUpPageState extends State<SellerSignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  String _storeName = '';
  List<String> _categories = [];
  String _storeLocation = '';
  File? _storeImage;
  String _nationalID = '';
  String _goals = '';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerSeller() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          // Upload store image
          String imageUrl = '';
          if (_storeImage != null) {
            final storageRef = FirebaseStorage.instance.ref().child('store_images').child(user.uid);
            await storageRef.putFile(_storeImage!);
            imageUrl = await storageRef.getDownloadURL();
          }

          await _firestore.collection('sellers').doc(user.uid).update({
            'storeName': _storeName,
            'categories': _categories,
            'storeLocation': _storeLocation,
            'storeImage': imageUrl,
            'nationalID': _nationalID,
            'goals': _goals,
            'status': 'Pending',
            'confirmationStatus': 'Awaiting Confirmation',
          });

          // Show confirmation page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegistrationConfirmationPage()),
          );
        } else {
          setState(() {
            _errorMessage = 'User not authenticated. Please sign in again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
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
        title: const Text('Seller Sign-Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 10),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) => value!.isEmpty ? 'Enter store name' : null,
                onSaved: (value) => _storeName = value!,
              ),
              // Category selection logic here
              TextFormField(
                decoration: const InputDecoration(labelText: 'Store Location'),
                validator: (value) => value!.isEmpty ? 'Enter store location' : null,
                onSaved: (value) => _storeLocation = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'National ID'),
                validator: (value) => value!.isEmpty ? 'Enter national ID' : null,
                onSaved: (value) => _nationalID = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Goals'),
                validator: (value) => value!.isEmpty ? 'Enter goals' : null,
                onSaved: (value) => _goals = value!,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Store Image'),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerSeller,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationConfirmationPage extends StatelessWidget {
  const RegistrationConfirmationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Confirmation'),
      ),
      body: const Center(
        child: Text('We will confirm and reach out to you soon.'),
      ),
    );
  }
}
