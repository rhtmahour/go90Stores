import 'package:flutter/material.dart';

class EditAddressPage extends StatefulWidget {
  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  bool isDefaultAddress = true;
  String selectedAddressType = "Home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 2,
        title: Text(
          "Edit Address",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Address Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildTextField("Full Name", required: true),
              SizedBox(height: 16),
              _buildTextField("Mobile Number", required: true),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Pincode", required: true)),
                  SizedBox(width: 16),
                  Expanded(child: _buildTextField("State", required: true)),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField("Address (House No, Street, Area)",
                  required: true),
              SizedBox(height: 16),
              _buildTextField("Locality/Town", required: true),
              SizedBox(height: 16),
              _buildTextField("City/District", required: true),
              SizedBox(height: 20),
              Text("Address Type",
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
                onChanged: (val) {
                  setState(() => isDefaultAddress = val!);
                },
                title: Text("Set as default address"),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.purple,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
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
                onPressed: () {},
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

  Widget _buildTextField(String label,
      {bool required = false, String? errorText}) {
    return TextField(
      decoration: InputDecoration(
        labelText: "$label ${required ? '*' : ''}",
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
          onChanged: (val) {
            setState(() => selectedAddressType = val!);
          },
          activeColor: Colors.purple,
        ),
        Text(value),
      ],
    );
  }
}
