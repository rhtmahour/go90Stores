import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go90stores/orderpage.dart';
import 'package:go90stores/services/stripe_service.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ProceedToCheckout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Checkout",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Shipping Address"),
              _buildAddressCard(),
              _buildSectionTitle("Order Summary"),
              _buildOrderSummary(cartProvider),
              _buildSectionTitle("Payment Method"),
              _buildPaymentMethod(),
              SizedBox(
                height: 10,
              ),
              _buildCheckoutButton(cartProvider, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // Add address selection logic here
        },
        leading: Icon(Icons.location_on,
            color: const Color.fromARGB(255, 176, 120, 120), size: 28),
        title: Text(
          "KH No. 91, Bijwasan Road, Kapashera, Gurgaon Road, New Delhi 110037",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: Icon(Icons.edit, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      height: 150, // Fixes the height for scrollability
      child: ListView.builder(
        itemCount: cartProvider.cartItems.length,
        itemBuilder: (context, index) {
          final product = cartProvider.cartItems[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['productImage'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              title: Text(
                product['name'] ?? 'Unknown Product',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '₹${product['salePrice']} x ${product['quantity']}',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
              trailing: Text(
                '₹${(double.parse(product['salePrice']) * product['quantity']).toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          RadioListTile(
            activeColor: Colors.deepPurple,
            title: Text("Credit/Debit Card"),
            value: "card",
            groupValue: "card",
            onChanged: (value) {},
          ),
          Divider(),
          RadioListTile(
            activeColor: Colors.deepPurple,
            title: Text("Cash on Delivery"),
            value: "cod",
            groupValue: "card",
            onChanged: (value) {},
          ),
          Divider(),
          RadioListTile(
            activeColor: Colors.deepPurple,
            title: Text("UPI"),
            value: "upi",
            groupValue: "payment",
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider, BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          if (cartProvider.cartItems.isEmpty) return;

          final total = cartProvider.getTotalPrice();
          final paymentSuccess =
              await StripeService.instance.makePayment(total);

          if (paymentSuccess) {
            final user = FirebaseAuth.instance.currentUser;
            final orderId = DateTime.now().millisecondsSinceEpoch.toString();

            final orderData = {
              'userId': user?.uid,
              'orderId': orderId,
              'products': cartProvider.cartItems,
              'totalAmount': total,
              'date': DateTime.now().toIso8601String(),
              'status': 'Pending',
            };

            await FirebaseFirestore.instance
                .collection('orders')
                .doc(orderId)
                .set(orderData);

            cartProvider.clearCart();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Orderpage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment failed. Try again.")),
            );
          }
        },
        child: const Text(
          "Place Order",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
