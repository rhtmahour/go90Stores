import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go90stores/consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<bool> makePayment(double totalAmount) async {
    try {
      int amountInPaisa = (totalAmount * 100).toInt();
      final clientSecret = await _createPaymentIntent(amountInPaisa, "inr");

      if (clientSecret == null) {
        print("Client secret was null");
        return false;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Go90Store",
          style: ThemeMode.light, // or dark based on your app theme
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Optional: confirm if not auto-confirmed
      // await Stripe.instance.confirmPaymentSheetPayment();

      print("Payment successful");
      return true;
    } on StripeException catch (e) {
      print("Stripe error: ${e.error.code} - ${e.error.message}");
      return false;
    } catch (e) {
      print("Payment failed: $e");
      return false;
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': amount.toString(), // Amount should be in paisa
        'currency': currency, // INR
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      print("Error in _createPaymentIntent: $e");
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print("Error in _processPayment: $e");
      throw Exception("Payment process failed");
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
