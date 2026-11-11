import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialiseApp();
  }

  Future<void> initialiseApp() async {
    final stopwatch = Stopwatch()..start();

    bool isLoggedIn = false;
    dynamic user;

    try {
      final results = await Future.wait([
        LocalAuthServices.getUserLoggedIn(),
        Future(() => LocalAuthServices.getUserDetails()),
      ]);
      isLoggedIn = results[0] as bool;
      user = results[1];
    } catch (e) {
      log('Initialization error in splash: $e');
    }

    // Ensure a smooth, settle presentation without jarring flashes
    final elapsed = stopwatch.elapsedMilliseconds;
    const minSplashDuration = 1600;
    if (elapsed < minSplashDuration) {
      await Future.delayed(Duration(milliseconds: minSplashDuration - elapsed));
    }

    if (!mounted) return;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else if (user != null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Brand Logo / Icon Badge
                  Container(
                        width: 104,
                        height: 104,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF16231C)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: isDark ? 0.25 : 0.10,
                              ),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.eco_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                );
                              },
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 700.ms, curve: Curves.easeOutCubic)
                      .scale(
                        begin: const Offset(0.82, 0.82),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      )
                      .shimmer(
                        delay: 750.ms,
                        duration: 1600.ms,
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),

                  const SizedBox(height: 28),

                  // Brand Title
                  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TRIBE GREEN',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.25,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 10),

                  // Brand Tagline
                  Text(
                        'Thoughtful Corporate Gifting',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          color: AppColors.secondaryText,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: 350.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.25,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 48),

                  // Sleek Animated Loading Progress Capsule
                  Container(
                    width: 140,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.sage.withValues(
                        alpha: isDark ? 0.4 : 0.7,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 48,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.gold],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .slideX(
                              begin: -0.6,
                              end: 2.2,
                              duration: 1200.ms,
                              curve: Curves.easeInOutCubic,
                            ),
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                  const SizedBox(height: 16),

                  // Subtle status caption
                  Text(
                        'Curating gifts...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: AppColors.secondaryText.withValues(alpha: 0.8),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: 600.ms, duration: 900.ms)
                      .fadeOut(delay: 900.ms, duration: 900.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
