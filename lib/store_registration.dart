import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:go90stores/adminlogin.dart';
import 'store_image_picker.dart'; // Import the StoreImagePicker file

class StoreRegistration extends StatefulWidget {
  const StoreRegistration({super.key});

  @override
  State<StoreRegistration> createState() => _StoreRegistrationState();
}

class _StoreRegistrationState extends State<StoreRegistration> {
  final _formKey = GlobalKey<FormState>();
  File? _storeImage;
  bool _isUploading = false; // Track upload progress

  final TextEditingController _storenameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _setImage(File pickedImage) {
    setState(() {
      _storeImage = pickedImage;
    });
  }

  Future<void> _registerStore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_storeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a store image.')),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true; // Start showing loading indicator
      });

      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImageToStorage();

      // Generate a unique store ID based on Firebase random ID
      String uniqueStoreId =
          FirebaseFirestore.instance.collection('stores').doc().id;

      await FirebaseFirestore.instance
          .collection('stores')
          .doc(uniqueStoreId)
          .set({
        'storeId': uniqueStoreId,
        'storename': _storenameController.text,
        'aadharNumber': _aadharController.text,
        'gstNumber': _gstController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'storeImage': imageUrl, // Store the uploaded image URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store registered successfully!')),
      );
      _formKey.currentState!.reset();

      // Navigate to the AdminLogin screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLogin()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during store registration: $error')),
      );
    } finally {
      setState(() {
        _isUploading = false; // Stop loading indicator
      });
    }
  }

  Future<String> _uploadImageToStorage() async {
    // Ensure that the image is not null
    if (_storeImage == null) throw 'No image selected';

    // Create a unique file name for the image
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // Upload the image to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('store_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(_storeImage!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl; // Return the image URL
    } catch (error) {
      throw 'Failed to upload image: $error'; // Throw error if image upload fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Store Registration'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Upload Store Image',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StoreImagePicker(onImagePicked: _setImage),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _storenameController,
                    decoration: const InputDecoration(
                      labelText: 'Store Name',
                      hintText: 'Enter your store name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a store name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _aadharController,
                    decoration: const InputDecoration(
                      labelText: 'Aadhar Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Aadhar number';
                      }
                      if (value.length != 12) {
                        return 'Aadhar number must be 12 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(
                      labelText: 'GST Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter GST number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _isUploading // Display a loading indicator when uploading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _registerStore,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Register Store'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
