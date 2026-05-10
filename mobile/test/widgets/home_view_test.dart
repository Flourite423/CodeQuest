import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:codequest/views/home/home_dashboard_view.dart';
import 'package:codequest/views/home/home_view.dart';

/// A lightweight HomeDashboardController for testing that skips
/// data loading on init to avoid pending timers and network requests.
class _TestHomeDashboardController extends HomeDashboardController {
  @override
  // ignore: must_call_super
  void onInit() {
    // Skip loadDashboardData() to avoid pending timers and network errors.
    // Only register retry so state transitions remain testable.
    registerRetry(loadDashboardData);
  }
}

void main() {
  testWidgets('HomeView renders five tabs', (tester) async {
    // Register test controller that doesn't trigger async data loading
    Get.lazyPut<HomeDashboardController>(() => _TestHomeDashboardController());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return GetMaterialApp(
            home: const HomeView(),
            initialBinding: HomeBinding(),
          );
        },
      ),
    );

    // Pump to let initial builds settle
    await tester.pump();

    // Verify 5 tab labels exist in the BottomNavigationBar
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('课程'), findsOneWidget);
    expect(find.text('挑战'), findsOneWidget);
    expect(find.text('社交'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // Verify IndexedStack exists (it's now lazy-loaded)
    expect(find.byType(IndexedStack), findsOneWidget);
  });
}
