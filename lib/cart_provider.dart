import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  // Get cart items
  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Get total quantity in cart (Fixed Type Issue)
  int get counter {
    return _cartItems.fold<int>(
        0, (sum, item) => sum + (item['quantity'] as int));
  }

  // Get total price of cart items
  double getTotalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item['salePrice'].toString()) ?? 0.0;
      return sum + (price * (item['quantity'] as int));
    });
  }

  // Add an item to the cart
  void addItemToCart(Map<String, dynamic> product) {
    int index = _cartItems.indexWhere((item) => item['key'] == product['key']);

    if (index != -1) {
      _cartItems[index]['quantity'] += 1;
    } else {
      _cartItems.add({
        'key': product['key'],
        'name': product['name'],
        'salePrice': product['salePrice'], // ✅ Ensure salePrice is stored
        'productImage': product['productImage'], // ✅ Ensure image is stored
        'quantity': 1,
      });
    }

    notifyListeners();
  }

  // Remove an item from the cart
  void removeItemFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  // Increase the quantity of an item
  void increaseQuantity(int index) {
    _cartItems[index]['quantity'] += 1;
    notifyListeners();
  }

  // Decrease the quantity of an item or remove if it reaches 0
  void decreaseQuantity(int index) {
    if (_cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity'] -= 1;
    } else {
      _cartItems.removeAt(index); // Remove the item if quantity reaches 0
    }
    notifyListeners();
  }
}
