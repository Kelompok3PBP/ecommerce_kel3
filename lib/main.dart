import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart'; // <--- PASTIKAN IMPORT INI ADA
import 'bloc/cart_cubit.dart';
import 'bloc/product_cubit.dart';
import 'services/api_service.dart';

// Pages
import 'pages/payment_page.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/cart_page.dart';
import 'pages/device_info_page.dart';
import 'pages/shared_preferences_page.dart';
import 'pages/feedback_page.dart';
import 'pages/theme_page.dart';
import 'pages/theme_provider.dart';

// Services
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CartCubit()),
          BlocProvider(create: (_) => ProductCubit(ApiService())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        
        // 👇👇 INI PERBAIKAN UTAMANYA 👇👇
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              title: 'Belanja.in',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: const SplashPage(), 
              routes: {
                '/splash': (context) => const SplashPage(),
                '/login': (context) => const LoginPage(),
                '/register': (context) => const RegisterPage(),
                '/dashboard': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  return DashboardPage(email: args ?? "user@mail.com");
                },
                '/cart': (context) => const CartPage(),
                '/payment': (context) {
                  final total =
                      ModalRoute.of(context)?.settings.arguments as double? ??
                          0.0;
                  return PaymentPage(total: total);
                },
                '/device_info': (context) => const DeviceInfoPage(),
                '/shared': (context) => const SharedPreferencesPage(),
                '/feedback': (context) => const FeedbackPage(),
              },
            );
          },
        );
        // 👆👆 SAMPAI SINI 👆👆
      },
    );
  }
}