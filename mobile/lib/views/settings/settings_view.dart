import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          child: _buildContent(context),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountSection(context),
          SizedBox(height: 24.h),
          _buildLearningSection(context),
          SizedBox(height: 24.h),
          _buildAppSection(context),
          SizedBox(height: 24.h),
          _buildStorageSection(context),
          SizedBox(height: 24.h),
          _buildAboutSection(context),
          SizedBox(height: 32.h),
          _buildLogoutButton(context),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Account'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Obx(() {
                final user = controller.user.value;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage:
                        user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                    child: user?.avatar == null
                        ? Icon(
                            Icons.person,
                            size: 24.sp,
                            color: colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  title: Text(
                    user?.nickname ?? 'Learner',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed('/profile/edit'),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Learning'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.timer_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'Daily Goal',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    '${controller.dailyGoal.value} minutes',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDailyGoalPicker(context),
                );
              }),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.trending_up_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Difficulty Preference',
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: Text(
                  'Beginner',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.offline_bolt_outlined,
                      size: 16.sp,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showOfflineSnackbar(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'App'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'Theme Mode',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    _getThemeLabel(controller.themeMode.value),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePicker(context),
                );
              }),
              const Divider(height: 1, indent: 56),
              Obx(() {
                return SwitchListTile(
                  secondary: Icon(
                    Icons.smart_toy_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'AI Hints',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    'Show AI-powered hints during exercises',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: controller.aiHintsEnabled.value,
                  onChanged: controller.setAiHintsEnabled,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Storage'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.storage_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'Cache Size',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    controller.cacheSize.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: controller.clearCache,
                    child: const Text('Clear'),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'About'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Version',
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonSnackbar(context, 'Help center'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'About',
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonSnackbar(context, 'About page'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton.icon(
          onPressed: controller.showLogoutConfirm,
          icon: Icon(
            Icons.logout,
            size: 20.sp,
            color: colorScheme.error,
          ),
          label: Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.error,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }

  void _showDailyGoalPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Daily Learning Goal',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'How many minutes do you want to learn each day?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              Obx(() {
                final selectedGoal = controller.dailyGoal.value;
                final goals = [15, 30, 60];

                return Row(
                  children: goals.map((goal) {
                    final isSelected = selectedGoal == goal;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ChoiceChip(
                          label: Text('$goal min'),
                          selected: isSelected,
                          onSelected: (_) {
                            controller.setDailyGoal(goal);
                            Get.back();
                          },
                          selectedColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Theme Mode',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final selectedTheme = controller.themeMode.value;
                final themes = [
                  _ThemeOption('system', 'System', Icons.brightness_auto),
                  _ThemeOption('light', 'Light', Icons.brightness_7),
                  _ThemeOption('dark', 'Dark', Icons.brightness_2),
                ];

                return Column(
                  children: themes.map((theme) {
                    final isSelected = selectedTheme == theme.value;
                    return ListTile(
                      leading: Icon(theme.icon),
                      title: Text(theme.label),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        controller.setThemeMode(theme.value);
                        Get.back();
                      },
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfflineSnackbar(BuildContext context) {
    Get.snackbar(
      'Offline',
      'This feature requires an internet connection.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      icon: const Icon(Icons.offline_bolt_outlined),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System';
    }
  }
}

class _ThemeOption {
  const _ThemeOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class SettingsController extends BaseController {
  final MockDataService _mockDataService = MockDataService();
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final RxInt dailyGoal = 30.obs;
  final RxString themeMode = 'system'.obs;
  final RxBool aiHintsEnabled = true.obs;
  final RxString cacheSize = '0 MB'.obs;

  static const String _dailyGoalKey = 'daily_goal_minutes';
  static const String _themeModeKey = 'theme_mode';
  static const String _aiHintsKey = 'ai_hints_enabled';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    setLoading(message: 'Loading settings...');
    registerRetry(loadSettings);

    try {
      final userData = await _mockDataService.fetchUser();
      if (userData != null) {
        user.value = userData;

        // Load persisted settings
        final persistedGoal = _storageService.read<int>(_dailyGoalKey);
        final persistedTheme = _storageService.read<String>(_themeModeKey);
        final persistedAiHints = _storageService.read<bool>(_aiHintsKey);

        dailyGoal.value = persistedGoal ?? userData.dailyGoal;
        themeMode.value = persistedTheme ?? userData.themeMode;
        aiHintsEnabled.value = persistedAiHints ?? true;

        await _calculateCacheSize();
        resetState();
      } else {
        setEmpty(message: 'Settings not available.');
      }
    } catch (e) {
      setError(message: 'Failed to load settings. Please try again.');
    }
  }

  void setDailyGoal(int goal) {
    dailyGoal.value = goal;
    _storageService.write(_dailyGoalKey, goal);
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
    _storageService.write(_themeModeKey, mode);
  }

  void setAiHintsEnabled(bool enabled) {
    aiHintsEnabled.value = enabled;
    _storageService.write(_aiHintsKey, enabled);
  }

  Future<void> _calculateCacheSize() async {
    // Simulate cache calculation
    // In a real app, this would check actual cache directories
    await Future<void>.delayed(const Duration(milliseconds: 200));
    cacheSize.value = '12.5 MB';
  }

  Future<void> clearCache() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data including images and temporary files. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setLoading(message: 'Clearing cache...');
      await Future<void>.delayed(const Duration(milliseconds: 800));
      cacheSize.value = '0 MB';
      resetState();

      Get.snackbar(
        'Success',
        'Cache cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      );
    }
  }

  void showLogoutConfirm() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setLoading(message: 'Signing out...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _storageService.clearAuthSession();
    Get.offAllNamed('/login');
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
