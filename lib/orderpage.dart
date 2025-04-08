import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Orderpage extends StatelessWidget {
  const Orderpage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
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
      body: user == null
          ? Center(child: Text("Please log in to view orders"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No orders found"));
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text("Order #${order['orderId']}"),
                      subtitle: Text("₹${order['totalAmount']}"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(orderData: order),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final products = List<Map<String, dynamic>>.from(orderData['products']);

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${orderData['orderId']}"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Date"),
            subtitle: Text(orderData['date']),
          ),
          ListTile(
            title: Text("Total"),
            subtitle: Text("₹${orderData['totalAmount']}"),
          ),
          ListTile(
            title: Text("Status"),
            subtitle: Text(orderData['status']),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Text("Products", style: Theme.of(context).textTheme.titleLarge),
          ),
          ...products.map((product) => ListTile(
                leading: Image.network(product['productImage'],
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product['name']),
                subtitle: Text("Qty: ${product['quantity']}"),
                trailing: Text("₹${product['salePrice']}"),
              )),
        ],
      ),
    );
  }
}
