import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go90stores/orderpage.dart';
import 'package:go90stores/services/stripe_service.dart';
import 'package:go90stores/user_current_location.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'package:geolocator/geolocator.dart';

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
              _buildAddressCard(context),
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

  Widget _buildAddressCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserCurrentLocation(),
            ),
          );
        },
        leading: Icon(
          Icons.location_on,
          color: Colors.purple,
          size: 30,
        ),
        title: Text(
          "Select Address",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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

  // Update the _buildCheckoutButton method
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
          if (cartProvider.cartItems.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart is empty")),
            );
            return;
          }

          try {
            final total = cartProvider.getTotalPrice();
            final paymentSuccess =
                await StripeService.instance.makePayment(total);

            if (!paymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment failed. Try again.")),
              );
              return;
            }

            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not logged in")),
              );
              return;
            }

            // Get customer location
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

            final orderId = DateTime.now().millisecondsSinceEpoch.toString();
            final orderData = {
              'userId': user.uid,
              'orderId': orderId,
              'products': cartProvider.cartItems,
              'totalAmount': total,
              'date': DateTime.now().toIso8601String(),
              'status': 'Pending',
              'customerLat': position.latitude,
              'customerLng': position.longitude,
            };

            // Save order to Firestore
            await FirebaseFirestore.instance
                .collection('orders')
                .doc(orderId)
                .set(orderData);

            // Find nearby stores (within 5km radius) using geolocator
            final nearbyStores = await FirebaseFirestore.instance
                .collection('stores')
                .where('location', isNull: false)
                .get()
                .then((snapshot) async {
              List<QueryDocumentSnapshot> nearbyStores = [];

              for (final doc in snapshot.docs) {
                final storeLocation = doc.data()['location'];
                if (storeLocation == null) continue;

                final storeLat = storeLocation['latitude'];
                final storeLng = storeLocation['longitude'];

                if (storeLat == null || storeLng == null) continue;

                final distanceInMeters = await Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  storeLat,
                  storeLng,
                );

                // 5km radius (5000 meters)
                if (distanceInMeters <= 5000) {
                  nearbyStores.add(doc);
                }
              }
              return nearbyStores;
            });

            // Send notifications to nearby stores
            // Update the notification sending part to convert all values to strings
            for (final store in nearbyStores) {
              final storeId = store.id;
              final timestamp = DateTime.now();

              final notificationData = {
                'type': 'new_order',
                'order_id': orderId,
                'customer_address': 'Current Location',
                'total_amount': total.toString(), // Convert double to string
                'timestamp':
                    timestamp.toIso8601String(), // Convert DateTime to string
                'read': 'false', // Convert bool to string
              };

              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('notifications')
                  .add({
                ...notificationData,
                'timestamp':
                    FieldValue.serverTimestamp(), // Keep original for Firestore
              });

              // Send push notification with string-only data
              await FirebaseMessaging.instance.subscribeToTopic(storeId);
              await FirebaseMessaging.instance.sendMessage(
                to: '/topics/$storeId',
                data:
                    notificationData, // Now properly typed as Map<String, String>
              );
            }

            cartProvider.clearCart();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrderPage()),
            );
          } catch (e) {
            print("Checkout Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Something went wrong: ${e.toString()}")),
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
