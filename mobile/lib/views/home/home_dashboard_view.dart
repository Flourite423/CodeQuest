import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import 'home_view.dart';
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/list_card.dart';

/// Home Dashboard - 学习者主仪表板
///
/// 包含问候语、连续学习天数、今日成长、每日挑战、继续学习、
/// 每周统计、好友活动和徽章预览等模块。
/// 支持部分数据失败，不影响其他模块展示。
class HomeDashboardView extends GetView<HomeDashboardController> {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          child: _buildContent(context),
        ));
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboardData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          _buildGreetingHeader(context),
          SizedBox(height: 16.h),
          _buildStreakPill(context),
          SizedBox(height: 16.h),
          _buildHeroCard(context),
          SizedBox(height: 16.h),
          _buildDailyChallengeCard(context),
          SizedBox(height: 16.h),
          _buildContinueLearningCard(context),
          SizedBox(height: 16.h),
          _buildWeeklyStatsGrid(context),
          SizedBox(height: 16.h),
          _buildFriendActivityPreview(context),
          SizedBox(height: 16.h),
          _buildBadgePreview(context),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    final nickname = controller.user.value?.nickname ?? '学习者';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting，$nickname',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '今天也要继续学习哦！',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24.r,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: controller.user.value?.avatar != null
              ? NetworkImage(controller.user.value!.avatar!)
              : null,
          child: controller.user.value?.avatar == null
              ? Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimaryContainer,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildStreakPill(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final streak = controller.user.value?.streak ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: colorScheme.onPrimaryContainer,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            '连续学习 $streak 天',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = controller.user.value;
    final stats = controller.stats.value;

    if (user == null) return const SizedBox.shrink();

    final currentXp = user.xp;
    final nextLevelXp = user.level * 500;
    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日成长',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Lv.${user.level}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentXp',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '当前 XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (stats != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.studyTime}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '学习时长(分)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        colorScheme.onPrimary.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                    minHeight: 8.h,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '距离下一级还需 ${nextLevelXp - currentXp} XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dailyChallenge = controller.dailyChallenge.value;

    if (dailyChallenge == null) return const SizedBox.shrink();

    final isExpired = dailyChallenge.isExpired;
    final isAttempted = dailyChallenge.isAttempted;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/daily-challenge'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: colorScheme.onSecondaryContainer,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '每日挑战',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          dailyChallenge.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    dailyChallenge.timeLimit > 0
                        ? '${dailyChallenge.timeLimit ~/ 60} 分钟'
                        : '无时间限制',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? colorScheme.errorContainer
                          : isAttempted
                              ? colorScheme.tertiaryContainer
                              : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      isExpired
                          ? '已过期'
                          : isAttempted
                              ? '已尝试'
                              : '进行中',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isExpired
                            ? colorScheme.onErrorContainer
                            : isAttempted
                                ? colorScheme.onTertiaryContainer
                                : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueLearningCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final continueCourse = controller.continueCourse.value;

    if (continueCourse == null) return const SizedBox.shrink();

    // 找到第一个未完成的章节
    final nextChapter = continueCourse.chapters
        .where((c) => !c.isCompleted && !c.isLocked)
        .firstOrNull;

    if (nextChapter == null) return const SizedBox.shrink();

    // 判断用户是否从未开始过此课程（进度为 0 且没有已完成章节）
    final hasStarted = (continueCourse.progress ?? 0) > 0 ||
        continueCourse.chapters.any((c) => c.isCompleted);
    final headerLabel = hasStarted ? '继续学习' : '开始学习';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          '/chapter/${nextChapter.id}',
          parameters: <String, String>{
            'courseId': continueCourse.id,
          },
        ),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      hasStarted
                          ? Icons.play_circle_outline
                          : Icons.school_outlined,
                      color: colorScheme.onTertiaryContainer,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headerLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          continueCourse.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 18.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        nextChapter.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 18.sp,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
              if (continueCourse.progress != null &&
                  continueCourse.progress! > 0) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: continueCourse.progress,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '课程进度 ${(continueCourse.progress! * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stats = controller.stats.value;

    if (stats == null) return const SizedBox.shrink();

    final statItems = [
      _StatItem(
        icon: Icons.timer,
        label: '学习时长',
        value: '${stats.studyTime}',
        unit: '分钟',
        color: colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.check_circle,
        label: '完成课程',
        value: '${stats.coursesCompleted}',
        unit: '门',
        color: colorScheme.tertiary,
      ),
      _StatItem(
        icon: Icons.emoji_events,
        label: '挑战胜利',
        value: '${stats.challengesWon}',
        unit: '次',
        color: colorScheme.secondary,
      ),
      _StatItem(
        icon: Icons.star,
        label: '总 XP',
        value: '${stats.totalXp}',
        unit: '点',
        color: colorScheme.error,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本周统计',
          style: theme.textTheme.titleMedium?.copyWith(
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
          childAspectRatio: 1.4,
          children:
              statItems.map((item) => _buildStatCard(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, _StatItem item) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              item.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${item.label} (${item.unit})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendActivityPreview(BuildContext context) {
    final theme = Theme.of(context);
    final activities = controller.activities.take(3).toList();

    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '好友动态',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                final homeController = Get.find<HomeController>();
                homeController.changeTab(3);
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...activities.map((activity) => _buildActivityItem(context, activity)),
      ],
    );
  }

  Widget _buildActivityItem(
      BuildContext context, app_models.Activity activity) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData activityIcon;
    Color iconColor;
    switch (activity.type) {
      case 'challenge_completed':
        activityIcon = Icons.emoji_events;
        iconColor = colorScheme.secondary;
      case 'badge_earned':
        activityIcon = Icons.workspace_premium;
        iconColor = colorScheme.tertiary;
      case 'streak_reached':
        activityIcon = Icons.local_fire_department;
        iconColor = colorScheme.error;
      case 'course_completed':
        activityIcon = Icons.school;
        iconColor = colorScheme.primary;
      default:
        activityIcon = Icons.notifications;
        iconColor = colorScheme.onSurfaceVariant;
    }

    final timeAgo = _formatTimeAgo(activity.timestamp);

    return ListCard(
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: activity.user.avatar != null
            ? NetworkImage(activity.user.avatar!)
            : null,
        child: activity.user.avatar == null
            ? (activity.user.nickname.isNotEmpty
                ? Text(activity.user.nickname.substring(0, 1))
                : const Icon(Icons.person))
            : null,
      ),
      title: activity.user.nickname,
      subtitle: activity.description,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(activityIcon, color: iconColor, size: 20.sp),
          SizedBox(height: 2.h),
          Text(
            timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () {
        final homeController = Get.find<HomeController>();
        homeController.changeTab(3);
      },
    );
  }

  Widget _buildBadgePreview(BuildContext context) {
    final theme = Theme.of(context);
    final badges = controller.badges.take(3).toList();

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近徽章',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/profile/rewards'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: badges
              .map((badge) => Expanded(
                    child: _buildBadgeItem(context, badge),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(BuildContext context, app_models.Badge badge) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        onTap: () => Get.toNamed('/profile/rewards'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: badge.icon != null
                    ? ClipOval(
                        child: Image.network(
                          badge.icon!,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.workspace_premium,
                            color: colorScheme.onPrimaryContainer,
                            size: 24.sp,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.workspace_premium,
                        color: colorScheme.onPrimaryContainer,
                        size: 24.sp,
                      ),
              ),
              SizedBox(height: 8.h),
              Text(
                badge.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTimeAgo(badge.earnedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 统计数据项
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}

/// Home Dashboard 控制器
///
/// 管理仪表板数据加载和状态，支持部分数据失败。
class HomeDashboardController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  ProgressService get _progress {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  final Rxn<app_models.User> user = Rxn<app_models.User>();
  final Rxn<app_models.Stats> stats = Rxn<app_models.Stats>();
  final Rxn<app_models.DailyChallenge> dailyChallenge =
      Rxn<app_models.DailyChallenge>();
  final Rxn<app_models.Course> continueCourse = Rxn<app_models.Course>();
  final RxList<app_models.Activity> activities = <app_models.Activity>[].obs;
  final RxList<app_models.Badge> badges = <app_models.Badge>[].obs;

  final RxBool userLoaded = false.obs;
  final RxBool statsLoaded = false.obs;
  final RxBool dailyLoaded = false.obs;
  final RxBool courseLoaded = false.obs;
  final RxBool activitiesLoaded = false.obs;
  final RxBool badgesLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    registerRetry(loadDashboardData);
  }

  /// 加载仪表板所有数据
  ///
  /// 各模块独立加载，部分失败不影响其他模块。
  Future<void> loadDashboardData() async {
    if (!_progress.isOnline.value) {
      _loadOfflineDashboardData();
      return;
    }

    setLoading(message: '加载仪表板中...');

    userLoaded.value = false;
    statsLoaded.value = false;
    dailyLoaded.value = false;
    courseLoaded.value = false;
    activitiesLoaded.value = false;
    badgesLoaded.value = false;

    await Future.wait([
      _loadUser(),
      _loadStats(),
      _loadDailyChallenge(),
      _loadContinueCourse(),
      _loadActivities(),
      _loadBadges(),
    ]);

    final hasAnyData = userLoaded.value ||
        statsLoaded.value ||
        dailyLoaded.value ||
        courseLoaded.value ||
        activitiesLoaded.value ||
        badgesLoaded.value;

    final hasAllData = userLoaded.value &&
        statsLoaded.value &&
        dailyLoaded.value &&
        courseLoaded.value &&
        activitiesLoaded.value &&
        badgesLoaded.value;

    if (!hasAnyData) {
      setError(message: '加载仪表板失败，请重试。');
    } else if (!hasAllData) {
      setPartialData(message: '部分数据加载失败，显示可用内容。');
    } else {
      pageState.value = PageState.initial;
    }
  }

  Future<void> _loadUser() async {
    try {
      final response = await _apiService.get('/learner/profile');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final profile =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final result = app_models.User.fromContracts(
        account: {'id': profile['account_id'] ?? '', 'email': ''},
        profile: profile,
      );
      await _progress.cacheUser(result);
      final snapshot = _progress.getLearningStatsSnapshot();
      user.value = app_models.User(
        id: result.id,
        email: result.email,
        nickname: result.nickname,
        avatar: result.avatar,
        level: result.level,
        xp: result.xp + snapshot.earnedXp,
        streak: snapshot.streakDays > 0 ? snapshot.streakDays : result.streak,
        bio: result.bio,
        dailyGoal: result.dailyGoal,
        themeMode: result.themeMode,
      );
      userLoaded.value = true;
    } catch (e) {
      userLoaded.value = false;
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await _apiService.get('/learner/stats/personal');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final result = app_models.Stats.fromPersonalStatsJson(data);
      final snapshot = _progress.getLearningStatsSnapshot();
      final merged = app_models.Stats(
        studyTime: snapshot.studyMinutes > 0
            ? snapshot.studyMinutes
            : result.studyTime,
        coursesCompleted: snapshot.completedCourses > 0
            ? snapshot.completedCourses
            : result.coursesCompleted,
        challengesWon: snapshot.completedChallenges > 0
            ? snapshot.completedChallenges
            : result.challengesWon,
        currentStreak: snapshot.streakDays > 0
            ? snapshot.streakDays
            : result.currentStreak,
        totalXp: result.totalXp + snapshot.earnedXp,
        mastery: result.mastery,
      );
      stats.value = merged;
      await _progress.cacheStats(merged);
      statsLoaded.value = true;
    } catch (e) {
      statsLoaded.value = false;
    }
  }

  Future<void> _loadDailyChallenge() async {
    try {
      final response = await _apiService.get('/learner/daily-challenges/today');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final challengeRaw = data['daily_challenge'] ?? data['challenge'];
      final recordData = data['learner_record'] as Map<String, dynamic>?;

      // 后端返回 daily_challenge 为 null 表示今日无挑战，这是正常情况
      if (challengeRaw == null) {
        dailyChallenge.value = null;
        await _progress.cacheDailyChallenge(null);
        dailyLoaded.value = true;
        return;
      }

      final challengeData = challengeRaw as Map<String, dynamic>;
      final result = app_models.DailyChallenge.fromContracts(
        challenge: challengeData,
        record: recordData,
      );
      final merged = _progress.applyDailyChallengeProgress(result);
      dailyChallenge.value = merged;
      await _progress.cacheDailyChallenge(merged);

      dailyLoaded.value = true;
    } catch (e) {
      dailyLoaded.value = false;
    }
  }

  Future<void> _loadContinueCourse() async {
    try {
      final listResponse = await _apiService.get('/learner/courses');
      final listPayload = listResponse.data is Map<String, dynamic>
          ? listResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final listData =
          listPayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (listData['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => app_models.Course.fromListItemJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
      final withProgress = _progress.applyCourseProgressList(items);
      await _progress.cacheCourses(withProgress);

      // 找第一个有未完成章节的课程，获取详情
      for (final course in withProgress) {
        try {
          final detailResponse =
              await _apiService.get('/learner/courses/${course.id}');
          final detailPayload = detailResponse.data is Map<String, dynamic>
              ? detailResponse.data as Map<String, dynamic>
              : <String, dynamic>{};
          final courseData = detailPayload['data'] as Map<String, dynamic>? ??
              <String, dynamic>{};
          final detail = app_models.Course.fromDetailJson(courseData);
          final processed = _progress.applyCourseProgress(detail);
          await _progress.cacheCourse(processed);

          if (processed.chapters.any((ch) => !ch.isCompleted && !ch.isLocked)) {
            continueCourse.value = processed;
            courseLoaded.value = true;
            return;
          }
        } catch (_) {
          continue;
        }
      }

      // 如果没有未完成的，显示第一个课程
      final firstCourse = withProgress.firstOrNull;
      if (firstCourse != null) {
        final cached = _progress.getCachedCourse(firstCourse.id);
        continueCourse.value = cached ?? firstCourse;
        courseLoaded.value = true;
      } else {
        courseLoaded.value = false;
      }
    } catch (e) {
      courseLoaded.value = false;
    }
  }

  Future<void> _loadActivities() async {
    try {
      final response = await _apiService.get('/learner/activities');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) =>
              app_models.Activity.fromContract(Map<String, dynamic>.from(item)))
          .toList();
      activities.assignAll(items);
      activitiesLoaded.value = true;
    } catch (e) {
      activitiesLoaded.value = false;
    }
  }

  Future<void> _loadBadges() async {
    try {
      final response = await _apiService.get('/learner/rewards');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (data['badges'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => app_models.Badge.fromAwardJson(
                Map<String, dynamic>.from(item),
                name: (item['name'] ?? '').toString(),
                description: (item['description'] ?? '').toString(),
                icon: item['icon_url'] as String?,
              ))
          .toList();
      badges.assignAll(items);
      badgesLoaded.value = true;
    } catch (e) {
      badgesLoaded.value = false;
    }
  }

  void _loadOfflineDashboardData() {
    user.value = _progress.getCachedUser();
    stats.value = _progress.getCachedStats();
    final cachedDaily = _progress.getCachedDailyChallenge();
    if (cachedDaily != null) {
      dailyChallenge.value = _progress.applyDailyChallengeProgress(cachedDaily);
    }
    // 从缓存课程中找第一个有未完成章节的课程
    final cachedCourses =
        _progress.applyCourseProgressList(_progress.getCachedCourses());
    continueCourse.value = cachedCourses.firstWhereOrNull(
      (c) => c.chapters.any((ch) => !ch.isCompleted && !ch.isLocked),
    );
    // 如果没有未完成的，显示第一个课程
    if (continueCourse.value == null && cachedCourses.isNotEmpty) {
      continueCourse.value = cachedCourses.first;
    }
    userLoaded.value = user.value != null;
    statsLoaded.value = stats.value != null;
    dailyLoaded.value = dailyChallenge.value != null;
    courseLoaded.value = continueCourse.value != null;
    activitiesLoaded.value = activities.isNotEmpty;
    badgesLoaded.value = badges.isNotEmpty;

    if (userLoaded.value ||
        statsLoaded.value ||
        dailyLoaded.value ||
        courseLoaded.value) {
      setPartialData(message: '当前为离线模式，已显示本地学习统计与缓存内容。');
    } else {
      setOffline(message: '当前没有可用网络，且本地暂无可展示的仪表板缓存。');
    }
  }
}

class HomeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeDashboardController>(() => HomeDashboardController());
  }
}
