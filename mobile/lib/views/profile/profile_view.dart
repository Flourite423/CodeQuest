import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/mock_data.dart';
import '../../widgets/page_state_host.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
              user?.nickname ?? 'Learner',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Level ${user?.level ?? 1}',
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
          '${nextLevelXp - currentXp} XP to next level',
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
        label: 'Study Time',
        value: '${stats.studyTime}m',
        icon: Icons.timer_outlined,
      ),
      _StatItem(
        label: 'Courses',
        value: '${stats.coursesCompleted}',
        icon: Icons.menu_book_outlined,
      ),
      _StatItem(
        label: 'Challenges',
        value: '${stats.challengesWon}',
        icon: Icons.emoji_events_outlined,
      ),
      _StatItem(
        label: 'Streak',
        value: '${stats.currentStreak}d',
        icon: Icons.local_fire_department_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
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

  Widget _buildBadgesPreview(BuildContext context, List<app_models.Badge> badges) {
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
                'Recent Badges',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/profile/rewards'),
              child: const Text('View All'),
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
                        backgroundImage:
                            badge.icon != null ? NetworkImage(badge.icon!) : null,
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
          'Quick Access',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _buildActionTile(
          context,
          title: 'View Stats',
          icon: Icons.insights_outlined,
          routeName: '/profile/stats',
        ),
        _buildActionTile(
          context,
          title: 'Rewards Center',
          icon: Icons.workspace_premium_outlined,
          routeName: '/profile/rewards',
        ),
        _buildActionTile(
          context,
          title: 'Edit Profile',
          icon: Icons.edit_outlined,
          routeName: '/profile/edit',
        ),
        _buildActionTile(
          context,
          title: 'Settings',
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
  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final Rx<app_models.Stats?> stats = Rx<app_models.Stats?>(null);
  final RxList<app_models.Badge> badges = <app_models.Badge>[].obs;

  final MockDataService _mockDataService = MockDataService();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    setLoading(message: 'Loading profile...');
    registerRetry(loadProfileData);

    try {
      final userData = await _mockDataService.fetchUser();
      final statsData = await _mockDataService.fetchStats();
      final badgesData = await _mockDataService.fetchBadges();

      if (userData != null) {
        user.value = userData;
        stats.value = statsData;
        badges.assignAll(badgesData);
        resetState();
      } else {
        setEmpty(message: 'Profile data not available.');
      }
    } catch (e) {
      setError(message: 'Failed to load profile. Please try again.');
    }
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
