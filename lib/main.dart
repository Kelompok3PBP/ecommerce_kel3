import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/payment_page.dart';

import 'model/cart.dart'; // 💡 Pastikan path model/cart.dart kamu benar
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/cart_page.dart';
import 'pages/device_info_page.dart';
import 'pages/shared_preferences_page.dart';
import 'pages/feedback_page.dart';
import 'pages/theme_page.dart'; // ✅ Panggil file tema

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cart = CartModel();
  await cart.loadCart();

  runApp(ChangeNotifierProvider(create: (_) => cart, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaroonMart', // ✅ Ganti judul
      debugShowCheckedModeBanner: false,
      
      // ✅ Terapkan tema terpusat dari theme_page.dart
      theme: AppTheme.lightTheme, 
      
      // ✅ Jadikan SplashPage sebagai halaman pembuka
      home: const SplashPage(),
      
      // ✅ Rute navigasi
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return DashboardPage(email: args ?? "user@mail.com");
        },
        '/cart': (context) => const CartPage(),
        '/payment': (context) {
          final total =
              ModalRoute.of(context)?.settings.arguments as double? ?? 0.0;
          return PaymentPage(total: total);
        },
        '/device_info': (context) => const DeviceInfoPage(),
        '/shared': (context) => const SharedPreferencesPage(),
        '/feedback': (context) => const FeedbackPage(),
      },
    );
  }
}