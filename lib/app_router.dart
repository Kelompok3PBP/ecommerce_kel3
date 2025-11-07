import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service
import 'services/auth_service.dart';

// Pages
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/payment_page.dart';
import 'pages/profile_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/change_password_page.dart';
import 'pages/settings_page.dart';
import 'pages/device_info_page.dart';
import 'pages/feedback_page.dart';
import 'pages/shared_preferences_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Nyalakan untuk debug routing

    // ===================================================================
    // LOGIKA REDIRECT (PENGALIHAN) OTOMATIS
    // ===================================================================
    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = await AuthService.isLoggedIn();
      final String location = state.matchedLocation;

      // 1. Jika di halaman splash, biarkan saja
      if (location == '/splash') {
        return null;
      }

      // 2. Jika tidak login DAN tidak sedang di halaman login/register
      //    maka paksa ke halaman login.
      if (!loggedIn && location != '/login' && location != '/register') {
        return '/login';
      }

      // 3. Jika sudah login DAN mencoba akses halaman login/register
      //    maka paksa ke dashboard.
      if (loggedIn && (location == '/login' || location == '/register')) {
        final email = await AuthService.getLoggedInEmail();
        return '/dashboard';
      }

      // 4. Jika semua kondisi aman, lanjutkan ke tujuan
      return null;
    },

    // ===================================================================
    // DAFTAR SEMUA RUTE APLIKASI
    // ===================================================================
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          // Ambil email dari 'extra' saat navigasi
          final email = state.extra as String? ?? 'user@mail.com';
          return DashboardPage(email: email);
        },
      ),

      // Rute Detail Produk dengan Parameter ID
      GoRoute(
        path: '/detail/:id', // <-- ':id' adalah parameter
        builder: (context, state) {
          // Ambil 'id' dari parameter URL
          final String productId = state.pathParameters['id'] ?? '0';
          return DetailPage(productId: productId);
        },
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),

      GoRoute(
        path: '/payment',
        builder: (context, state) {
          // Ambil total belanja dari 'extra'
          final total = state.extra as double? ?? 0.0;
          return PaymentPage(total: total);
        },
      ),

      // Rute Halaman Profil & Setting
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          // Ambil data map dari 'extra'
          final data = state.extra as Map<String, String>? ??
              {'name': '', 'email': ''};
          return EditProfilePage(
            name: data['name']!,
            email: data['email']!,
          );
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
      GoRoute(
        path: '/device-info',
        builder: (context, state) => const DeviceInfoPage(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      GoRoute(
        path: '/shared-prefs',
        builder: (context, state) => const SharedPreferencesPage(),
      ),
    ],
  );
}