import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSecurityAndAuth();
  }

  Future<void> _checkSecurityAndAuth() async {
    bool isJailbroken = false;
    try {
      isJailbroken = await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      isJailbroken = false;
    }

    if (isJailbroken && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Security Warning'),
          content: const Text('Your device appears to be rooted or jailbroken. For your security, please proceed with caution.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkAuth();
              },
              child: const Text('I Understand, Proceed'),
            ),
          ],
        ),
      );
    } else {
      _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    final authState = ref.read(authProvider);
    final isLoggedIn = authState.value ?? false;

    if (mounted) {
      if (!hasSeenOnboarding) {
        context.go(AppRouter.onboarding);
      } else if (isLoggedIn) {
        context.go(AppRouter.home);
      } else {
        context.go(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mock logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.hive_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'RentHive',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
