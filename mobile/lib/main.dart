import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/app_binding.dart';
import 'routes/app_pages.dart';
import 'services/progress_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed, app continues in mock mode: $e');
  }
  
  // Initialize GetStorage with error handling for headless environments
  // Use a shorter timeout to avoid blocking the UI
  try {
    await GetStorage.init().timeout(
      const Duration(seconds: 2),
      onTimeout: () => false,
    );
  } catch (e) {
    // In headless/test environments, GetStorage may fail to get documents directory
    // This is expected and the app will still function using in-memory storage
    debugPrint('GetStorage init failed (expected in headless mode): $e');
  }
  
  // Ensure runApp is called immediately to avoid showing default Flutter loading screen
  runApp(const CodeQuestApp());
}

class CodeQuestApp extends StatelessWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'CodeQuest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialBinding: AppBinding(),
          initialRoute: AppPages.initialRoute,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          builder: (context, appChild) {
            return _OfflineAwareShell(
              child: appChild ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

class _OfflineAwareShell extends StatelessWidget {
  const _OfflineAwareShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progressService = Get.find<ProgressService>();

    return Obx(() {
      return Stack(
        children: [
          child,
          if (!progressService.isOnline.value)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '当前为离线模式，学习记录会先保存到本地。',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
