import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../utils/browser_detector.dart' as bd;
import 'package:flutter/foundation.dart' show kIsWeb;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(<double>[
                0.213 + 0.787 * 1.12,
                0.715 - 0.715 * 1.12,
                0.072 - 0.072 * 1.12,
                0,
                0,
                0.213 - 0.213 * 1.12,
                0.715 + 0.285 * 1.12,
                0.072 - 0.072 * 1.12,
                0,
                0,
                0.213 - 0.213 * 1.12,
                0.715 - 0.715 * 1.12,
                0.072 + 0.928 * 1.12,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.12)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.18),
                    ],
                    stops: const [0.6, 1.0],
                    center: const Alignment(0, -0.1),
                    radius: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 18.w.clamp(80, 140),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Selamat Datang di Belanja.in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp.clamp(18, 36),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        "Temukan produk hebat, pengiriman cepat, dan pembayaran aman.\nMasuk untuk melanjutkan atau buat akun baru untuk mulai berbelanja.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp.clamp(10, 18),
                          color: Colors.white.withOpacity(0.95),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    Container(
                      width: 70.w.clamp(250, 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.go('/register'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            child: Center(
                              child: Text(
                                "Buat Akun ",
                                style: TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                  fontSize: 12.sp.clamp(12, 20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    Container(
                      width: 70.w.clamp(250, 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.go('/login'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp.clamp(12, 20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),

                    Container(
                      width: 70.w.clamp(250, 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue.shade400.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.blue.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            final apkUrl = 'https://example.com/app-latest.apk';
                            if (kIsWeb && bd.isMobileBrowser()) {
                              bd.triggerDownload(
                                apkUrl,
                                filename: 'app-latest.apk',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mengunduh APK...'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Unduhan APK hanya tersedia pada browser mobile (Chrome/Android).',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.4.h),
                            child: Center(
                              child: Text(
                                '📱 Unduh APK',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 11.sp.clamp(10, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
