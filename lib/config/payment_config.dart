class PaymentConfig {
  // IMPORTANT: Set this to your Stripe Publishable Key (Test mode for development)
  // Prefer using --dart-define for secrets; this constant is a fallback for development only.
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SSIAy0BquWskqyaMRovb95LcmqT50KSS5eqA0f6QuPyMnf01D2NTz5ZCnMXo5EX1mr7dmL5YaXeBil9hhv2Gt2A004aAgjaT5',
  );

  // Backend endpoint that creates PaymentIntents and returns clientSecret
  // Example: your Supabase Edge Function URL (see PAYMENTS_STRIPE_SETUP.md)
  static const String backendBaseUrl = String.fromEnvironment(
    'PAYMENTS_BACKEND_URL',
    defaultValue: 'https://oaxljityjzjylvvmfrta.supabase.co/functions/v1',
  );

  // Currency for charges (must match backend PaymentIntent creation)
  static const String currency = 'myr';
}
