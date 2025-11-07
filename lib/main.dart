import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart'; // <-- Pastikan Sizer ada

// Blocs & Services
import 'bloc/cart_cubit.dart';
import 'bloc/product_cubit.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

// Theme
import 'pages/theme_page.dart';
import 'pages/theme_provider.dart';

// Router
import 'app_router.dart'; // <-- Import router baru kita

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  // Kita tidak perlu cek login di sini, GoRouter yang akan handle

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
        // Bungkus dengan Sizer di level TERTINGGI
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              title: 'Belanja.in',
              debugShowCheckedModeBanner: false,

              // Tema
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,

              // Gunakan routerConfig dari GoRouter
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}