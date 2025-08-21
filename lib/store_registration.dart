import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _verificationId;
  String _statusMessage = '';
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      await FirebaseFirestore.instance.collection('stores').add({
        'storename': _storeNameController.text,
        'storeAddress': _storeAddressController.text,
        'aadharNumber': _aadharController.text,
        'phone': _phoneController.text,
        'gstNumber': _gstController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'storeImage': 'Uploaded Image URL or Path',
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
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = '+91${_phoneController.text}';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolved (optional)
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _statusMessage = 'Verification failed: ${e.message}';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _showOtpDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter OTP"),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'OTP',
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Verify"),
            onPressed: () async {
              final otp = _otpController.text.trim();

              try {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: otp,
                );

                await FirebaseAuth.instance.signInWithCredential(credential);

                setState(() {
                  _statusMessage = '✅ Phone Number Verified Successfully!';
                });

                Navigator.of(context).pop();
              } catch (e) {
                setState(() {
                  _statusMessage = '❌ Incorrect OTP. Please try again.';
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Store Registration',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                  const SizedBox(height: 10),
                  StoreImagePicker(onImagePicked: _setImage),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _storeNameController,
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
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _verifyPhoneNumber();
                      }
                    },
                    child: const Text('Verify'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains("✅")
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _storeAddressController,
                    decoration: InputDecoration(
                      labelText: 'Store Address',
                      hintText: 'Enter store address',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2, // Allow multiline error messages
                    ),
                    maxLength: 100, // Condition: Limit address length
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Store address is required';
                      }
                      if (value.length < 5) {
                        return 'Address must be at least 5 characters';
                      }
                      if (RegExp(r'[!@#\$%^&*(),?":{}|<>]').hasMatch(value)) {
                        return 'Special characters are not allowed';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode
                        .onUserInteraction, // Validates as user types
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
                  ElevatedButton(
                    onPressed: _registerStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Register Store',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
