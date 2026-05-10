import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/api_service.dart';
import '../../widgets/page_state_host.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
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
    final user = controller.user.value;
    final stats = controller.stats.value;
    final badges = controller.badges;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, user),
          SizedBox(height: 24.h),
          if (stats != null) _buildStatsGrid(context, stats),
          SizedBox(height: 24.h),
          if (badges.isNotEmpty) _buildBadgesPreview(context, badges),
          if (badges.isNotEmpty) SizedBox(height: 24.h),
          _buildNavigationSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, app_models.User? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  user?.avatar != null ? NetworkImage(user!.avatar!) : null,
              child: user?.avatar == null
                  ? Icon(
                      Icons.person,
                      size: 50.sp,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            SizedBox(height: 16.h),
            Text(
              user?.nickname ?? '学习者',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '等级 ${user?.level ?? 1}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            _buildXpProgress(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildXpProgress(BuildContext context, app_models.User? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentXp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final nextLevelXp = _calculateNextLevelXp(level);
    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$currentXp XP',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: Text(
                '$nextLevelXp XP',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '距离下一级还需 ${nextLevelXp - currentXp} XP',
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  int _calculateNextLevelXp(int level) {
    return level * 1000;
  }

  Widget _buildStatsGrid(BuildContext context, app_models.Stats stats) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final statItems = [
      _StatItem(
        label: '学习时长',
        value: '${stats.studyTime}m',
        icon: Icons.timer_outlined,
      ),
      _StatItem(
        label: '课程',
        value: '${stats.coursesCompleted}',
        icon: Icons.menu_book_outlined,
      ),
      _StatItem(
        label: '挑战',
        value: '${stats.challengesWon}',
        icon: Icons.emoji_events_outlined,
      ),
      _StatItem(
        label: '连续天数',
        value: '${stats.currentStreak}d',
        icon: Icons.local_fire_department_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '统计数据',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.58,
          children: statItems.map((item) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 24.sp,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.value,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.label,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgesPreview(
      BuildContext context, List<app_models.Badge> badges) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recentBadges = badges.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '最近徽章',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/profile/rewards'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: recentBadges.map((badge) {
            return Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: badge.icon != null
                            ? NetworkImage(badge.icon!)
                            : null,
                        child: badge.icon == null
                            ? Icon(
                                Icons.workspace_premium,
                                size: 24.sp,
                                color: colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        badge.name,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷入口',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _buildActionTile(
          context,
          title: '查看统计',
          icon: Icons.insights_outlined,
          routeName: '/profile/stats',
        ),
        _buildActionTile(
          context,
          title: '奖励中心',
          icon: Icons.workspace_premium_outlined,
          routeName: '/profile/rewards',
        ),
        _buildActionTile(
          context,
          title: '编辑资料',
          icon: Icons.edit_outlined,
          routeName: '/profile/edit',
        ),
        _buildActionTile(
          context,
          title: '设置',
          icon: Icons.settings_outlined,
          routeName: '/settings',
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(routeName),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class ProfileController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final Rx<app_models.Stats?> stats = Rx<app_models.Stats?>(null);
  final RxList<app_models.Badge> badges = <app_models.Badge>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    setLoading(message: '加载个人资料中...');
    registerRetry(loadProfileData);

    try {
      // Fetch account (/me) and profile (/learner/profile) in parallel
      final results = await Future.wait([
        _apiService.get('/me'),
        _apiService.get('/learner/profile'),
        _apiService.get('/learner/stats/personal'),
        _apiService.get('/learner/rewards'),
      ]);

      final meResponse = results[0];
      final profileResponse = results[1];
      final statsResponse = results[2];
      final rewardsResponse = results[3];

      // Parse account data
      final mePayload = meResponse.data is Map<String, dynamic>
          ? meResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final account = mePayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Parse profile data
      final profilePayload = profileResponse.data is Map<String, dynamic>
          ? profileResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final profile = profilePayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Parse stats data
      final statsPayload = statsResponse.data is Map<String, dynamic>
          ? statsResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final statsData = statsPayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Parse rewards data for badges
      final rewardsPayload = rewardsResponse.data is Map<String, dynamic>
          ? rewardsResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final rewardsData = rewardsPayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Combine account + profile into User
      user.value = app_models.User.fromContracts(
        account: account,
        profile: profile,
      );

      // Parse stats
      stats.value = app_models.Stats.fromPersonalStatsJson(statsData);

      // Parse badges from rewards data
      final badgeItems = (rewardsData['badges'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);
            return app_models.Badge.fromAwardJson(
              json,
              name: '徽章',
              description: '',
              icon: null,
            );
          })
          .toList();
      badges.assignAll(badgeItems);

      resetState();
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录后查看个人资料。');
      } else if (e.response?.statusCode == 403) {
        setError(message: '当前账号暂无访问权限。');
      } else if (e.response?.statusCode == 500) {
        setError(message: '个人资料服务暂时不可用，请稍后重试。');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '加载个人资料超时，请重试。');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: '网络连接异常，请检查后重试。');
      } else {
        setError(message: '加载个人资料失败，请重试。');
      }
    } catch (e) {
      setError(message: '加载个人资料失败，请重试。');
    }
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
