import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go90stores/consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<bool> makePayment(double totalAmount) async {
    try {
      int amountInPaisa = (totalAmount * 100).toInt();
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amountInPaisa, "inr");

      if (paymentIntentClientSecret == null) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Go90Store",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      print("Stripe payment failed: $e");

      if (e is StripeException) {
        final error = e.error;
        print("Stripe error: ${error.code} | ${error.message}");
      }

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
