import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/storage_service.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Obx(() => controller.currentPage.value < controller.pages.length - 1
                    ? TextButton(
                        onPressed: controller.skip,
                        child: const Text('Skip'),
                      )
                    : const SizedBox.shrink()),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    page: controller.pages[index],
                  );
                },
              ),
            ),

            // Page indicators and CTA
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: controller.currentPage.value == index ? 24.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 32.h),

                  // Next / Get Started button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton(
                      onPressed: controller.nextPage,
                      child: Text(
                        controller.currentPage.value == controller.pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120.sp,
            color: theme.primaryColor,
          ),
          SizedBox(height: 40.h),
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const String _firstLaunchKey = 'first_launch';

  final PageController pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      icon: Icons.school,
      title: 'Learn Anything',
      description: 'Access a wide variety of courses and challenges to expand your knowledge and skills.',
    ),
    OnboardingPageData(
      icon: Icons.emoji_events,
      title: 'Earn Rewards',
      description: 'Complete challenges, earn points, and unlock achievements as you progress.',
    ),
    OnboardingPageData(
      icon: Icons.people,
      title: 'Connect with Friends',
      description: 'Compete with friends on the leaderboard and share your learning journey.',
    ),
    OnboardingPageData(
      icon: Icons.trending_up,
      title: 'Track Progress',
      description: 'Monitor your stats, view your rewards, and see how far you\'ve come.',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void skip() {
    _finishOnboarding();
  }

  void _finishOnboarding() async {
    // Mark first launch as completed
    await _storage.write(_firstLaunchKey, true);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
