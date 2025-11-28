import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/app/theme/app_theme.dart';

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
  final _duration = const Duration(milliseconds: 2500);

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
      context.go('/welcome');
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
                        "assets/images/logo.png",
                        height: 30.h,
                        width: 30.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.storefront,
                          size: 30.h,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
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
                              fontSize: 30,
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
                            fontSize: 30,
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
                padding: EdgeInsets.only(bottom: 5.h),
                child: FadeTransition(
                  opacity: _bottomFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BouncingCubeIndicator(),
                      SizedBox(height: 2.h),
                      Text(
                        "created by Kelompok 3",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
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

class _BouncingCubeIndicator extends StatefulWidget {
  const _BouncingCubeIndicator();

  @override
  State<_BouncingCubeIndicator> createState() => _BouncingCubeIndicatorState();
}

class _BouncingCubeIndicatorState extends State<_BouncingCubeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubeSize = 2.0.w;

    return SizedBox(
      width: 15.w,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_bounceAnimation.value, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: cubeSize / 2,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
                ),
                Container(
                  width: cubeSize,
                  height: cubeSize,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                CircleAvatar(
                  radius: cubeSize / 2,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
