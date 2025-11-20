import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/address_cubit.dart';
import 'services/address_service.dart';
import 'services/auth_service.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/payment_page.dart';
import 'pages/receipt_page.dart';
import 'pages/profile_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/change_password_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/device_info_page.dart';
import 'pages/feedback_page.dart';
import 'pages/address_list_page.dart';
import 'pages/map_page.dart';
import 'pages/shared_preferences_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = await AuthService.isLoggedIn();
      final String location = state.matchedLocation;

      // Jika di splash, jangan redirect
      if (location == '/splash') {
        return null;
      }

      // Jika belum login & bukan di login/register, redirect ke login
      if (!loggedIn && location != '/login' && location != '/register') {
        return '/login';
      }

      // Jika sudah login & masuk ke login/register, redirect ke dashboard
      if (loggedIn && (location == '/login' || location == '/register')) {
        return '/dashboard';
      }

      // Selain itu, jangan redirect
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final email = state.extra as String? ?? 'user@mail.com';
          return DashboardPage(email: email);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => BlocProvider(
          create: (context) => AddressCubit(AddressService())..fetchAll(),
          child: const AddressListPage(),
        ),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final String productId = state.pathParameters['id'] ?? '0';
          return DetailPage(productId: productId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final total = state.extra as double? ?? 0.0;
          return PaymentPage(total: total);
        },
      ),
      GoRoute(
        path: '/purchase-receipt/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          final receiptData = state.extra as Map<String, dynamic>?;
          return PurchaseReceiptPage(
            orderId: orderId,
            receiptData: receiptData,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final data =
              state.extra as Map<String, String>? ?? {'name': '', 'email': ''};
          return EditProfilePage(name: data['name']!, email: data['email']!);
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(
        path: '/device-info',
        builder: (context, state) => const DeviceInfoPage(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapPickerPage()),
      GoRoute(
        path: '/shared-preferences',
        builder: (context, state) => const SharedPreferencesPage(),
      ),
    ],
  );
}
