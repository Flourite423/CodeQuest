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
                        child: const Text('跳过'),
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
                            ? '开始使用'
                            : '下一步',
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

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            Icon(
              page.icon,
              size: 100.sp,
              color: theme.primaryColor,
            ),
            SizedBox(height: 32.h),
            Text(
              page.title,
              style: theme.textTheme.headlineSmall?.copyWith(
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
            SizedBox(height: 40.h),
          ],
        ),
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
      title: '学无止境',
      description: '探索丰富多样的课程和挑战，不断拓展你的知识和技能。',
    ),
    OnboardingPageData(
      icon: Icons.emoji_events,
      title: '赢取奖励',
      description: '完成挑战、赚取积分，在进步的过程中解锁各种成就。',
    ),
    OnboardingPageData(
      icon: Icons.people,
      title: '好友互动',
      description: '与好友在排行榜上一较高下，分享你的学习历程。',
    ),
    OnboardingPageData(
      icon: Icons.trending_up,
      title: '追踪进度',
      description: '查看学习统计、浏览已获得奖励，见证自己的成长。',
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
