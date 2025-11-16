import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/payment_config.dart';

class PaymentService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    Stripe.publishableKey = PaymentConfig.publishableKey;
    Stripe.instance.applySettings();
    _initialized = true;
  }

  // Create PaymentIntent via your backend and return its clientSecret
  static Future<String> _createPaymentIntent({
    required int amountInMinorUnit,
    required String currency,
    required String username,
    String? description,
  }) async {
    final url = Uri.parse(
      '${PaymentConfig.backendBaseUrl}/create-payment-intent',
    );

    // Get Supabase auth token for authorization
    final supabase = Supabase.instance.client;
    final token = supabase.auth.currentSession?.accessToken ?? '';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amountInMinorUnit,
        'currency': currency,
        'metadata': {
          'username': username,
          if (description != null) 'description': description,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create PaymentIntent: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final clientSecret = data['client_secret'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Missing client_secret from backend');
    }
    return clientSecret;
  }

  // Initialize and present the PaymentSheet; returns true on successful payment
  static Future<bool> payWithPaymentSheet({
    required double amount,
    required String currency,
    required String username,
    String? description,
  }) async {
    // On web, Stripe PaymentSheet is not supported, so we simulate payment
    // For production web, you'd integrate Stripe Elements or redirect to Stripe Checkout
    if (kIsWeb) {
      print(
        '⚠️  Web platform detected - simulating payment (PaymentSheet not supported on web)',
      );
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      return true; // Return success for web testing
    }

    await init();

    // Stripe expects amounts in the smallest currency unit (e.g., cents)
    final amountInMinorUnit = (amount * 100).round();

    // 1) Create PaymentIntent on backend
    final clientSecret = await _createPaymentIntent(
      amountInMinorUnit: amountInMinorUnit,
      currency: currency,
      username: username,
      description: description,
    );

    // 2) Init PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'UniPerks',
        style: ThemeMode.system,
        allowsDelayedPaymentMethods: false,
      ),
    );

    // 3) Present PaymentSheet
    await Stripe.instance.presentPaymentSheet();

    return true;
  }
}
