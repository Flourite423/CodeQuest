import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../services/progress_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
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
          _buildNotificationSection(context),
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
        _buildSectionHeader(context, '账户'),
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
                    user?.nickname ?? '学习者',
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
        _buildSectionHeader(context, '学习'),
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
                    '每日目标',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    '${controller.dailyGoal.value} 分钟',
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
                  '难度偏好',
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: Text(
                  '初级',
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
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.restart_alt,
                  color: colorScheme.error,
                ),
                title: Text(
                  '清除学习进度',
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: Text(
                  '清除章节、课程、挑战、每日挑战和学习统计记录',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: controller.clearLearningProgress,
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
        _buildSectionHeader(context, '应用'),
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
                    '主题模式',
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
                    'AI 提示',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    '在练习中显示 AI 驱动的提示',
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
        _buildSectionHeader(context, '存储'),
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
                    '缓存大小',
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
                    child: const Text('清除'),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '通知'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    '通知权限',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    controller.notificationPermissionText.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: controller.requestNotificationPermission,
                    child: const Text('申请'),
                  ),
                );
              }),
              const Divider(height: 1, indent: 56),
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.vpn_key_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'FCM Token',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    controller.notificationTokenPreview.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: controller.refreshNotificationToken,
                    child: const Text('刷新'),
                  ),
                );
              }),
              const Divider(height: 1, indent: 56),
              Obx(() {
                return ListTile(
                  leading: Icon(
                    Icons.campaign_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    '发送测试通知',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    controller.notificationSummary.value,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: controller.sendTestNotification,
                    child: const Text('发送'),
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
        _buildSectionHeader(context, '关于'),
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
                  '版本',
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
                  '帮助与支持',
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonSnackbar(context, '帮助中心'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  '关于',
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonSnackbar(context, '关于页面'),
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
            '退出登录',
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
                '每日学习目标',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '每天想学习多少分钟？',
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
                           label: Text('$goal 分钟'),
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
                '主题模式',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final selectedTheme = controller.themeMode.value;
                final themes = [
                  _ThemeOption('system', '系统', Icons.brightness_auto),
                  _ThemeOption('light', '浅色', Icons.brightness_7),
                  _ThemeOption('dark', '深色', Icons.brightness_2),
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
      '离线',
      '此功能需要网络连接。',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      icon: const Icon(Icons.offline_bolt_outlined),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    Get.snackbar(
      '即将推出',
      '$feature 将在未来更新中提供。',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'light':
        return '浅色';
      case 'dark':
        return '深色';
      case 'system':
      default:
        return '系统';
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
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  ProgressService get _progressService {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final RxInt dailyGoal = 30.obs;
  final RxString themeMode = 'system'.obs;
  final RxBool aiHintsEnabled = true.obs;
  final RxString cacheSize = '0 MB'.obs;
  final RxString notificationPermissionText = '未申请'.obs;
  final RxString notificationTokenPreview = '尚未获取 Token'.obs;
  final RxString notificationSummary = '可发送一条本地测试通知进行验证'.obs;

  static const String _dailyGoalKey = 'daily_goal_minutes';
  static const String _themeModeKey = 'theme_mode';
  static const String _aiHintsKey = 'ai_hints_enabled';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    setLoading(message: '加载设置中...');
    registerRetry(loadSettings);

    try {
      final response = await _apiService.get('/learner/profile');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final profile = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final userData = app_models.User.fromContracts(
        account: {'id': profile['account_id'] ?? '', 'email': ''},
        profile: profile,
      );
      user.value = userData;

      // Load persisted settings
      final persistedGoal = _storageService.read<int>(_dailyGoalKey);
      final persistedTheme = _storageService.read<String>(_themeModeKey);
      final persistedAiHints = _storageService.read<bool>(_aiHintsKey);

      dailyGoal.value = persistedGoal ?? userData.dailyGoal;
      themeMode.value = persistedTheme ?? userData.themeMode;
      aiHintsEnabled.value = persistedAiHints ?? true;

      await _calculateCacheSize();
      await _syncNotificationState();
      resetState();
    } catch (e) {
      setError(message: '加载设置失败，请重试。');
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

  Future<void> _syncNotificationState() async {
    notificationPermissionText.value =
        _notificationService.permissionStatusText.value;

    final token = _notificationService.fcmToken.value ??
        await _notificationService.refreshToken();
    notificationTokenPreview.value = _formatToken(token);
    notificationSummary.value = _notificationService.lastMessageSummary.value;
  }

  Future<void> requestNotificationPermission() async {
    await _notificationService.requestPermission();
    await _syncNotificationState();

    Get.snackbar(
      '通知权限',
      notificationPermissionText.value,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  Future<void> refreshNotificationToken() async {
    final token = await _notificationService.refreshToken();
    notificationTokenPreview.value = _formatToken(token);
    notificationSummary.value = _notificationService.lastMessageSummary.value;

    Get.snackbar(
      'FCM Token',
      token == null ? '当前未获取到 Token' : 'Token 已刷新',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  Future<void> sendTestNotification() async {
    await _notificationService.sendTestNotification();
    await _syncNotificationState();

    Get.snackbar(
      '测试通知',
      '已触发测试通知，请留意系统通知栏。',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  String _formatToken(String? token) {
    if (token == null || token.isEmpty) {
      return '尚未获取 Token';
    }

    if (token.length <= 24) {
      return token;
    }

    return '${token.substring(0, 12)}...${token.substring(token.length - 12)}';
  }

  Future<void> clearCache() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('清除缓存'),
        content: const Text(
          '这将清除所有缓存数据，包括图片和临时文件。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setLoading(message: '清除缓存中...');
      await Future<void>.delayed(const Duration(milliseconds: 800));
      cacheSize.value = '0 MB';
      resetState();

      Get.snackbar(
        '成功',
        '缓存清除成功',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      );
    }
  }

  Future<void> clearLearningProgress() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('清除学习进度'),
        content: const Text('此操作会清除本地学习进度、挑战记录和统计数据，且无法撤销。是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              '清除',
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setLoading(message: '正在清除学习进度...');
    await _progressService.clearLearningProgress();
    await _calculateCacheSize();
    resetState();

    Get.snackbar(
      '学习进度已清除',
      '本地学习记录已重置。重新进入课程后会显示初始状态。',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
    );
  }

  void showLogoutConfirm() {
    Get.dialog(
      AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: Text(
              '退出登录',
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setLoading(message: '正在退出登录...');
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
