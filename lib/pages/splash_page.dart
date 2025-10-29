import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_page.dart'; // pastikan path ini sesuai dengan struktur project kamu

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Controller utama untuk sequence
  late AnimationController _masterController;

  // Controller untuk animasi berulang (kedip)
  late AnimationController _cursorBlinkController;

  late Animation<double> _logoScaleAnimation;
  late Animation<int> _typingAnimation;
  late Animation<double> _bottomFadeAnimation;

  final String _appName = "belanja in";
  final _duration = const Duration(milliseconds: 2200); // Durasi total animasi

  @override
  void initState() {
    super.initState();

    // --- Inisialisasi Controller ---
    _masterController = AnimationController(vsync: this, duration: _duration);
    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // --- Inisialisasi Animasi ---

    // Animasi Logo (0.0s -> 0.8s)
    _logoScaleAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack), // Efek pop
    );

    // Animasi Mengetik (0.8s -> 1.6s)
    _typingAnimation = IntTween(begin: 0, end: _appName.length).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.8, curve: Curves.linear), // Ketik 1 per 1
      ),
    );

    // Animasi Teks Bawah (1.8s -> 2.2s)
    _bottomFadeAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn), // Fade in
    );

    // Mulai animasi utama
    _masterController.forward();

    // Navigasi setelah 3.5 detik
    Timer(const Duration(milliseconds: 3500), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user');

    if (!mounted) return;

    if (email != null && email.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: email);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _cursorBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ✅✅✅ INI YANG DISESUAIKAN ✅✅✅
      // Background disamakan dengan scaffoldBackgroundColor di tema
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. Konten Tengah (Logo & Teks) ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔸 Logo Aplikasi (dengan animasi scale)
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        "assets/logo.png",
                        height: 240,
                        width: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.storefront,
                          size: 240,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🔸 Nama Aplikasi (Animasi Mengetik)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Teks yang diketik
                      AnimatedBuilder(
                        animation: _typingAnimation,
                        builder: (context, child) {
                          String text = _appName.substring(
                            0,
                            _typingAnimation.value,
                          );
                          return Text(
                            text,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor, // Font maroon
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          );
                        },
                      ),
                      // Kursor yang berkedip
                      FadeTransition(
                        opacity: _cursorBlinkController,
                        child: Text(
                          "|", // Kursor
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 2. Konten Bawah (Loading & Creator) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FadeTransition(
                  opacity: _bottomFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔸 Loading 3 Titik
                      const _ModernLoadingIndicator(),
                      const SizedBox(height: 16),

                      // 🔸 Teks Creator
                      Text(
                        "created by Kelompok 3",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor, // Font abu-abu
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget loading modern 3 titik yang beranimasi
class _ModernLoadingIndicator extends StatefulWidget {
  const _ModernLoadingIndicator();

  @override
  State<_ModernLoadingIndicator> createState() =>
      _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<_ModernLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animations = List.generate(3, (index) {
      final intervalStart = index * 0.2;
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            intervalStart,
            intervalStart + 0.4,
            curve: Curves.easeInOutCubic,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: _animations[index],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CircleAvatar(
              radius: 6,
              // Titik loading warna maroon agar kontras
              backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ),
        );
      }),
    );
  }
}
