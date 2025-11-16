import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/payment_config.dart';
import 'package:uniperks/pages/logo_reveal_screen.dart';

const supabaseUrl = 'https://oaxljityjzjylvvmfrta.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9heGxqaXR5anpqeWx2dm1mcnRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwNjc3MjAsImV4cCI6MjA3NzY0MzcyMH0.DFdoQ7nIgxVzRXgjjecsEBEcED4z2zngtq6XWEtTegM';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Initialize Stripe publishable key with timeout
  if (!PaymentConfig.publishableKey.contains('XXXXXXXXXXXXXXXXXXXXXXXX')) {
    try {
      Stripe.publishableKey = PaymentConfig.publishableKey;
      await Stripe.instance.applySettings().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(
            '⚠️  Stripe initialization timeout - app will continue without Stripe',
          );
        },
      );
    } catch (e) {
      print(
        '⚠️  Stripe initialization error: $e - app will continue without Stripe',
      );
    }
  }

  runApp(const MyApp());
}

// Premium Blue & White Color Palette
const Color premiumBlue = Color(0xFF0066CC);
const Color premiumBlueDark = Color(0xFF0052A3);
const Color lightBlueLight = Color(0xFFF0F7FF);
const Color darkGray = Color(0xFF424242);
const Color secondaryGray = Color(0xFF757575);
const Color lightGrayBg = Color(0xFFF5F5F5);
const Color borderGray = Color(0xFFEEEEEE);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPerks',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: premiumBlue,
          brightness: Brightness.light,
          primary: premiumBlue,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: premiumBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: premiumBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: premiumBlue,
            side: const BorderSide(color: premiumBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightGrayBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: premiumBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: secondaryGray),
          hintStyle: const TextStyle(color: secondaryGray),
          prefixIconColor: premiumBlue,
          suffixIconColor: premiumBlue,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: darkGray,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          headlineMedium: TextStyle(
            color: darkGray,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          titleLarge: TextStyle(
            color: darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          bodyLarge: TextStyle(color: darkGray, fontSize: 16),
          bodyMedium: TextStyle(color: secondaryGray, fontSize: 14),
          labelLarge: TextStyle(
            color: premiumBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: borderGray, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderGray,
          thickness: 1,
          space: 16,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: premiumBlue,
          unselectedItemColor: secondaryGray,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
      home: const LogoRevealScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
