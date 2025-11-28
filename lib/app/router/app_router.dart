import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/address/presentation/cubits/address_cubit.dart';
import 'package:ecommerce/features/address/data/address_service.dart';
import 'package:ecommerce/features/auth/data/auth_service.dart';
import 'package:ecommerce/features/auth/presentation/pages/splash_page.dart';
import 'package:ecommerce/features/auth/presentation/pages/login_page.dart';
import 'package:ecommerce/features/auth/presentation/pages/welcome_page.dart';
import 'package:ecommerce/features/auth/presentation/pages/register_page.dart';
import 'package:ecommerce/features/product/presentation/pages/dashboard_page.dart';
import 'package:ecommerce/features/product/presentation/pages/detail_page.dart';
import 'package:ecommerce/features/cart/presentation/pages/cart_page.dart';
import 'package:ecommerce/features/order/presentation/pages/payment_page.dart';
import 'package:ecommerce/features/order/presentation/pages/receipt_page.dart';
import 'package:ecommerce/features/profile/presentation/pages/profile_page.dart';
import 'package:ecommerce/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:ecommerce/features/profile/presentation/pages/change_password_page.dart';
import 'package:ecommerce/features/settings/presentation/pages/settings_page.dart';
import 'package:ecommerce/features/settings/presentation/pages/about_page.dart';
import 'package:ecommerce/features/settings/presentation/pages/device_info_page.dart';
import 'package:ecommerce/features/settings/presentation/pages/feedback_page.dart';
import 'package:ecommerce/features/address/presentation/pages/address_list_page.dart';
import 'package:ecommerce/features/address/presentation/pages/map_page.dart';
import 'package:ecommerce/features/settings/presentation/pages/shared_preferences_page.dart';
import 'package:ecommerce/features/order/presentation/pages/order_history_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = await AuthService.isLoggedIn();
      final String location = state.matchedLocation;

      // Splash → biarkan
      if (location == '/splash') return null;

      // Welcome → biarkan (tidak butuh login)
      if (location == '/welcome') return null;

      // Jika belum login → hanya blok page private
      if (!loggedIn &&
          location != '/login' &&
          location != '/register' &&
          !location.startsWith('/purchase-receipt') &&
          !location.startsWith('/payment')) {
        return '/login';
      }

      // Jika sudah login tapi buka login/register → lempar ke dashboard
      if (loggedIn && (location == '/login' || location == '/register')) {
        return '/dashboard';
      }

      return null;
    },

    routes: <RouteBase>[
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      // NEW: Welcome Screen
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

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
        path: '/order-history',
        builder: (context, state) => const OrderHistoryPage(),
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
