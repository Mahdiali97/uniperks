import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
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

    print('📤 Sending request to: $url');
    print('⚡ Creating PaymentIntent for $username...');

    // Send request with Supabase anon key as apikey header
    // This tells Supabase it's an authenticated public request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9heGxqaXR5anpqeWx2dm1mcnRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwNjc3MjAsImV4cCI6MjA3NzY0MzcyMH0.DFdoQ7nIgxVzRXgjjecsEBEcED4z2zngtq6XWEtTegM',
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

    print('📨 Response status: ${response.statusCode}');
    print('📨 Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create PaymentIntent (${response.statusCode}): ${response.body}',
      );
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
      print('💰 Simulated payment: RM${amount.toStringAsFixed(2)}');
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      print('✅ Simulated payment completed successfully');
      return true; // Return success for web testing
    }

    await init();

    // Stripe expects amounts in the smallest currency unit (e.g., cents)
    final amountInMinorUnit = (amount * 100).round();

    print('📱 Mobile platform detected - using real Stripe PaymentSheet');

    // 1) Create PaymentIntent on backend
    final clientSecret = await _createPaymentIntent(
      amountInMinorUnit: amountInMinorUnit,
      currency: currency,
      username: username,
      description: description,
    );

    print('✅ PaymentIntent created, initializing PaymentSheet...');

    // 2) Init PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'UniPerks',
        style: ThemeMode.system,
        allowsDelayedPaymentMethods: false,
      ),
    );

    print('🎫 PaymentSheet initialized, presenting to user...');

    // 3) Present PaymentSheet
    await Stripe.instance.presentPaymentSheet();

    print('✅ Payment completed successfully');
    return true;
  }
}
