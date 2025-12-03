import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- IMPORTS ---
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

// --- FIX 1: Gunakan alias 'as' untuk menghindari konflik nama class ---
import 'package:ecommerce/features/settings/presentation/pages/feedback_page.dart'
    as feedback_ui;

import 'package:ecommerce/features/address/presentation/pages/address_list_page.dart';
import 'package:ecommerce/features/address/presentation/pages/map_page.dart';
import 'package:ecommerce/features/shipping/presentation/pages/shipping_selection_page.dart';
import 'package:ecommerce/features/shipping/presentation/cubits/shipping_cubit.dart';
import 'package:ecommerce/features/shipping/data/shipping_service.dart';
import 'package:ecommerce/features/shipping/data/repositories/shipping_repository_impl.dart';
import 'package:ecommerce/features/shipping/domain/usecases/get_shipping_options_usecase.dart';
import 'package:ecommerce/features/settings/presentation/pages/shared_preferences_page.dart';
import 'package:ecommerce/features/order/presentation/pages/order_history_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // --- LOGIKA REDIRECT ---
    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = await AuthService.isLoggedIn();
      final String location = state.matchedLocation;

      // Halaman Public (Tidak perlu cek login)
      if (location == '/splash' || location == '/welcome') return null;

      // Jika belum login, blokir akses ke halaman privat
      if (!loggedIn &&
          location != '/login' &&
          location != '/register' &&
          !location.startsWith('/purchase-receipt') &&
          !location.startsWith('/payment')) {
        return '/login';
      }

      // Jika sudah login tapi buka login/register, arahkan ke dashboard
      if (loggedIn && (location == '/login' || location == '/register')) {
        return '/dashboard';
      }

      return null;
    },

    // --- DAFTAR RUTE ---
    routes: <RouteBase>[
      // Splash & Auth
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final email = state.extra as String? ?? 'user@mail.com';
          return DashboardPage(email: email);
        },
      ),

      // Profile & Address
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

      // Product & Cart
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final String productId = state.pathParameters['id'] ?? '0';
          return DetailPage(productId: productId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),

      // Order & Payment
      GoRoute(
        path: '/shipping-selection',
        builder: (context, state) {
          final extra = state.extra;
          final shippingService = ShippingService();
          final repository = ShippingRepositoryImpl(shippingService);
          final useCase = GetShippingOptionsUseCase(repository);
          final cubit = ShippingCubit(useCase);
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AddressCubit(AddressService())..fetchAll(),
              ),
              BlocProvider.value(value: cubit),
            ],
            child: ShippingSelectionPage(extra: extra),
          );
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          dynamic extra = state.extra;
          // Convert to proper type if needed
          if (extra is Map) {
            return PaymentPage(extra: Map<String, dynamic>.from(extra));
          }
          return PaymentPage(extra: extra);
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

      // --- SETTINGS GROUP ---
      GoRoute(
        path: '/settings',
        // Pastikan class di settings_page.dart bernama SettingsPage
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(
        path: '/device-info',
        builder: (context, state) => const DeviceInfoPage(),
      ),

      GoRoute(
        path: '/feedback',
        // --- FIX 2: Panggil menggunakan prefix ---
        builder: (context, state) => const feedback_ui.FeedbackPage(),
      ),
      GoRoute(
        path: '/shared-preferences',
        builder: (context, state) => const SharedPreferencesPage(),
      ),

      // Map
      GoRoute(path: '/map', builder: (context, state) => const MapPickerPage()),
    ],
  );
}
