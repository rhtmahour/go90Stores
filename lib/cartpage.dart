import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Your Cart", style: TextStyle(color: Colors.white)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) => badges.Badge(
              badgeContent: Text(
                cartProvider.counter.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.shopping_cart, color: Colors.white),
            ),
          ),
          SizedBox(width: 16),
        ],
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
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return cartProvider.cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(context, cartProvider);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) =>
            _buildBottomNavBar(cartProvider),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Your cart is empty 😌',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 18),
          ),
          SizedBox(height: 20),
          Text(
            'Explore products and shop your favorite items',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cartProvider) {
    return ListView.builder(
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final product = cartProvider.cartItems[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['productImage'] != null &&
                            product['productImage'].isNotEmpty
                        ? product['productImage'] // ✅ Use correct key
                        : 'https://placehold.co/70x70',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Unknown Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹${product['salePrice'] ?? '0'}', // ✅ Use salePrice instead of price
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () =>
                                cartProvider.decreaseQuantity(index),
                          ),
                          Text(
                            product['quantity'].toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                                cartProvider.increaseQuantity(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => cartProvider.removeItemFromCart(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 20, thickness: 2, color: Colors.grey[300]),
            Text(
              'Total: Rs.${cartProvider.getTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Divider(height: 20, thickness: 2, color: Colors.grey[300]),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              onPressed: cartProvider.cartItems.isEmpty ? null : () {},
              child: Text("Pay Now",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
