import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/storage_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Delay navigation to avoid blocking the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  void _navigateToNext() async {
    debugPrint('SplashView: Starting navigation...');

    // Wait for 2 seconds splash animation
    await Future.delayed(const Duration(seconds: 2));

    debugPrint('SplashView: Splash animation completed');

    // Ensure StorageService is initialized
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }

    final storage = Get.find<StorageService>();

    try {
      final hasKey = storage.hasKey('first_launch');
      final isFirstLaunch = !hasKey;
      final authToken = storage.readAuthToken();

      debugPrint(
          'SplashView: hasKey=$hasKey, isFirstLaunch=$isFirstLaunch, authToken=${authToken != null ? 'exists' : 'null'}');

      if (isFirstLaunch) {
        debugPrint('SplashView: Navigating to onboarding');
        Get.offAllNamed('/onboarding');
      } else if (authToken != null && authToken.isNotEmpty) {
        debugPrint('SplashView: Navigating to home');
        Get.offAllNamed('/home');
      } else {
        debugPrint('SplashView: Navigating to login');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      debugPrint('SplashView: Error reading storage: $e');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 24.h),
            Text(
              '编程探索',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // SplashView no longer needs a controller
  }
}
