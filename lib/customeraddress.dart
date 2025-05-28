import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go90stores/customereditaddress.dart';

class CustomerAddressPage extends StatefulWidget {
  const CustomerAddressPage({Key? key}) : super(key: key);

  @override
  _CustomerAddressPageState createState() => _CustomerAddressPageState();
}

class _CustomerAddressPageState extends State<CustomerAddressPage> {
  Map<String, dynamic>? addressData;

  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  Future<void> fetchAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .get();

      final data = doc.data();
      setState(() {
        addressData = data != null && data.containsKey('address')
            ? Map<String, dynamic>.from(data['address'])
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Customer Address',
          style: TextStyle(color: Colors.white),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: addressData != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.location_on, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Saved Address',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("Address: ${addressData!['address'] ?? ''}"),
                          Text("Locality: ${addressData!['locality'] ?? ''}"),
                          Text("City: ${addressData!['city'] ?? ''}"),
                          Text("Pincode: ${addressData!['pincode'] ?? ''}"),
                          Text("State: ${addressData!['state'] ?? ''}"),
                          Text("Type: ${addressData!['addressType'] ?? ''}"),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No address found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAddressPage(),
                      ),
                    ).then((_) => fetchAddress());
                  },
                  icon: const Icon(Icons.add_location, color: Colors.white),
                  label:
                      const Text("Add", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: addressData != null
                      ? () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await FirebaseFirestore.instance
                                .collection('customers')
                                .doc(uid)
                                .update({'address': FieldValue.delete()});
                            setState(() => addressData = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Address removed successfully"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Add the address first"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text("Remove",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
