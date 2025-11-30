import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/product/presentation/cubits/product_cubit.dart';
import 'package:ecommerce/features/settings/presentation/cubits/language_cubit.dart';
import 'package:ecommerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:ecommerce/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:ecommerce/features/settings/presentation/cubits/notification_cubit.dart';
import 'package:ecommerce/features/order/presentation/cubits/order_cubit.dart';
import 'package:ecommerce/core/network/api_service.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';

import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:ecommerce/app/theme/theme_provider.dart';
import 'package:ecommerce/app/router/app_router.dart';

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
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider(create: (_) => ProfileCubit()),
          BlocProvider(create: (_) => NotificationCubit()),
          BlocProvider(create: (_) => OrderCubit()),
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
        return BlocListener<LanguageCubit, LanguageState>(
          listener: (context, state) {},
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp.router(
                title: 'Belanja.in',
                debugShowCheckedModeBanner: false,

                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
