import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/payment_page.dart';

import 'model/cart.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/cart_page.dart';
import 'pages/device_info_page.dart';
import 'pages/shared_preferences_page.dart';
import 'pages/feedback_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cart = CartModel();
  await cart.loadCart();

  runApp(ChangeNotifierProvider(create: (_) => cart, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _checkLoginOrRegister() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');
    await Future.delayed(const Duration(seconds: 2));
    return (email != null &&
            email.isNotEmpty &&
            password != null &&
            password.isNotEmpty)
        ? email
        : '';
  }

  Future<bool> _isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');
    return email != null && password != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luminé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      home: FutureBuilder<String>(
        future: _checkLoginOrRegister(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashPage();
          }

          final email = snapshot.data ?? '';
          if (email.isNotEmpty) {
            return DashboardPage(email: email);
          } else {
            return FutureBuilder<bool>(
              future: _isRegistered(),
              builder: (context, regSnapshot) {
                if (regSnapshot.connectionState != ConnectionState.done) {
                  return const SplashPage();
                }
                if (regSnapshot.data == true) {
                  return const LoginPage();
                } else {
                  return const RegisterPage();
                }
              },
            );
          }
        },
      ),
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
