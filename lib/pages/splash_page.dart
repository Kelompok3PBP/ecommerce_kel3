import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'theme_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _cursorBlinkController;
  late Animation<double> _logoScaleAnimation;
  late Animation<int> _typingAnimation;
  late Animation<double> _bottomFadeAnimation;

  final String _appName = "belanja in";
  final _duration = const Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(vsync: this, duration: _duration);
    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _logoScaleAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    _typingAnimation = IntTween(begin: 0, end: _appName.length).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.8, curve: Curves.linear),
      ),
    );
    _bottomFadeAnimation = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );
    _masterController.forward();
    Timer(const Duration(milliseconds: 3500), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user');

    if (!mounted) return;

    if (email != null && email.isNotEmpty) {
      context.go('/dashboard', extra: email);
    } else {
      context.go('/login');
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        "assets/logo.png",
                        height: 30.h, // <-- Layout Sizer OK
                        width: 30.h,  // <-- Layout Sizer OK
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.storefront,
                          size: 30.h, // <-- Layout Sizer OK
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h), // <-- Layout Sizer OK
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              color: AppTheme.primaryColor,
                              fontSize: 30, // <-- GANTI DARI 28.sp
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          );
                        },
                      ),
                      FadeTransition(
                        opacity: _cursorBlinkController,
                        child: Text(
                          "|",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontSize: 30, // <-- GANTI DARI 28.sp
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5.h), // <-- Layout Sizer OK
                child: FadeTransition(
                  opacity: _bottomFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _ModernLoadingIndicator(),
                      SizedBox(height: 2.h), // <-- Layout Sizer OK
                      Text(
                        "created by Kelompok 3",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12, // <-- GANTI DARI 10.sp
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
            padding: EdgeInsets.symmetric(horizontal: 1.w), // <-- Layout Sizer OK
            child: CircleAvatar(
              radius: 1.5.w, // <-- Layout Sizer OK (kecil, tidak masalah)
              backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ),
        );
      }),
    );
  }
}