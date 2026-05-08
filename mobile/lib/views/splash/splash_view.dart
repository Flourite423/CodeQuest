import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/storage_service.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

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
              'Learning App',
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

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _firstLaunchKey = 'first_launch';

  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for 2 seconds splash animation
    await Future.delayed(const Duration(seconds: 2));

    final isFirstLaunch = !_storage.hasKey(_firstLaunchKey);
    final authToken = _storage.readAuthToken();

    if (isFirstLaunch) {
      // First time launch -> Onboarding
      Get.offAllNamed('/onboarding');
    } else if (authToken != null && authToken.isNotEmpty) {
      // Already logged in -> Home
      Get.offAllNamed('/home');
    } else {
      // Not logged in -> Login
      Get.offAllNamed('/login');
    }
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
