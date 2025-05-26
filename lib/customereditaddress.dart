import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAddressPage extends StatefulWidget {
  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();

  String selectedAddressType = "Home";
  bool isDefaultAddress = true;

  void _saveAddress() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_pincodeController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _localityController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the fields.")),
      );
      return;
    }

    final addressData = {
      "address": _addressController.text.trim(),
      "locality": _localityController.text.trim(),
      "city": _cityController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "state": _stateController.text.trim(),
      "addressType": selectedAddressType,
      "isDefault": isDefaultAddress,
    };

    await _firestore.collection('customers').doc(uid).set(
      {"address": addressData},
      SetOptions(merge: true),
    );

    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text("Edit Address", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildTextField(
                "Address (House No, Street, Area)", _addressController),
            SizedBox(height: 16),
            _buildTextField("Locality/Town", _localityController),
            SizedBox(height: 16),
            _buildTextField("City/District", _cityController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField("Pincode", _pincodeController)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField("State", _stateController)),
              ],
            ),
            SizedBox(height: 20),
            Text("Address Type", style: TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                _buildRadioOption("Home"),
                SizedBox(width: 16),
                _buildRadioOption("Office"),
              ],
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: isDefaultAddress,
              onChanged: (val) => setState(() => isDefaultAddress = val!),
              title: Text("Set as default address"),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text("CANCEL"),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text("SAVE"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "$label *",
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedAddressType,
          onChanged: (val) => setState(() => selectedAddressType = val!),
          activeColor: Colors.purple,
        ),
        Text(value),
      ],
    );
  }
}
