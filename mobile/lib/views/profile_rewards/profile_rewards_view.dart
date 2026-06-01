import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/api_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/filter_sheet.dart';

class ProfileRewardsView extends GetView<ProfileRewardsController> {
  const ProfileRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('奖励中心'),
        actions: [
          Obx(() => IconButton(
            icon: Badge(
              isLabelVisible: controller.hasActiveRewardFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => controller.showRewardFilterSheet(),
          )),
        ],
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          emptyTitle: '暂无奖励',
          emptyDescription: '完成挑战和课程以获取奖励。',
          emptyIcon: Icons.workspace_premium_outlined,
          child: _buildContent(context),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildXpSummaryCard(context),
          SizedBox(height: 24.h),
          _buildBadgesSection(context),
          SizedBox(height: 24.h),
          _buildRewardsLedgerSection(context),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // XP Summary Card
  // ──────────────────────────────────────────────────────────

  Widget _buildXpSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = controller.user.value;
    final currentXp = user?.xp ?? 0;
    final level = user?.level ?? 1;
    final nextLevelXp = controller.calculateNextLevelXp(level);
    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);
    final xpToNext = nextLevelXp - currentXp;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 28.sp,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '等级 $level',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$currentXp XP 总计',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentXp / $nextLevelXp XP',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '距离下一级还需 $xpToNext XP',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Badges Section
  // ──────────────────────────────────────────────────────────

  Widget _buildBadgesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badges = controller.badges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '徽章',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        if (badges.isEmpty)
          _buildEmptyBadges(context)
        else
          _buildBadgesGrid(context, badges),
      ],
    );
  }

  Widget _buildEmptyBadges(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 48.sp,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            '暂无徽章',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '完成挑战以获取你的第一个徽章。',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, List<app_models.Badge> badges) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.0,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(context, badge, colorScheme, textTheme);
      },
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    app_models.Badge badge,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => controller.openBadgePreview(badge),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    badge.icon != null && badge.icon!.startsWith('http')
                        ? NetworkImage(badge.icon!)
                        : null,
                child: badge.icon != null && badge.icon!.startsWith('http')
                    ? null
                    : Icon(
                        Icons.workspace_premium,
                        size: 32.sp,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
              SizedBox(height: 12.h),
              Text(
                badge.name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDateShort(badge.earnedAt),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Rewards Ledger Section
  // ──────────────────────────────────────────────────────────

  Widget _buildRewardsLedgerSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rewards = controller.filteredRewards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '奖励记录',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (controller.hasActiveRewardFilters)
              Text(
                '${rewards.length} 条结果',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (rewards.isEmpty)
          _buildEmptyLedger(
              context, hasFilters: controller.hasActiveRewardFilters)
        else
          _buildRewardsTimeline(context, rewards),
      ],
    );
  }

  Widget _buildEmptyLedger(BuildContext context, {bool hasFilters = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.receipt_long_outlined,
            size: 48.sp,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            hasFilters ? '无匹配奖励' : '暂无奖励',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            hasFilters ? '尝试调整筛选条件。' : '你的奖励历史将显示于此。',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTimeline(
    BuildContext context,
    List<app_models.Reward> rewards,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _buildRewardTile(context, reward, colorScheme, textTheme);
      },
    );
  }

  Widget _buildRewardTile(
    BuildContext context,
    app_models.Reward reward,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final iconData = _rewardIcon(reward.type);
    final iconColor = _rewardIconColor(reward.type, colorScheme);

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                iconData,
                size: 22.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.description,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatDateTime(reward.timestamp),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '+${reward.amount}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _rewardIcon(String type) {
    return switch (type) {
      'chapter' => Icons.menu_book_outlined,
      'exercise' => Icons.assignment_turned_in_outlined,
      'challenge' => Icons.emoji_events_outlined,
      'daily' => Icons.today_outlined,
      'admin_adjustment' => Icons.build_outlined,
      _ => Icons.star_outline,
    };
  }

  Color _rewardIconColor(String type, ColorScheme colorScheme) {
    return switch (type) {
      'chapter' => Colors.blue,
      'exercise' => Colors.green,
      'challenge' => Colors.orange,
      'daily' => Colors.purple,
      'admin_adjustment' => Colors.red,
      _ => colorScheme.primary,
    };
  }

  String _formatDateShort(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} $hour:$minute';
  }
}

// ═══════════════════════════════════════════════════════════
// Badge Preview Bottom Sheet
// ═══════════════════════════════════════════════════════════

class BadgePreviewSheet extends StatelessWidget {
  const BadgePreviewSheet({
    super.key,
    required this.badge,
  });

  final app_models.Badge badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              // Badge icon
              CircleAvatar(
                radius: 56.r,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    badge.icon != null && badge.icon!.startsWith('http')
                        ? NetworkImage(badge.icon!)
                        : null,
                child: badge.icon != null && badge.icon!.startsWith('http')
                    ? null
                    : Icon(
                        Icons.workspace_premium,
                        size: 56.sp,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
              SizedBox(height: 20.h),
              // Badge name
              Text(
                badge.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              // Description
              Text(
                badge.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Earned date
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '获得于 ${_formatDateLong(badge.earnedAt)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Share button (placeholder)
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: () {
                    // Share functionality placeholder
                    Get.snackbar(
                      '分享',
                      '分享 ${badge.name}...',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('分享成就'),
                ),
              ),
              SizedBox(height: 8.h),
              // Close button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateLong(DateTime date) {
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月',
    ];
    return '${date.year}年${months[date.month - 1]}${date.day}日';
  }
}

// ═══════════════════════════════════════════════════════════
// Controller
// ═══════════════════════════════════════════════════════════

class ProfileRewardsController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final RxList<app_models.Badge> badges = <app_models.Badge>[].obs;
  final RxList<app_models.Reward> rewards = <app_models.Reward>[].obs;

  // ── Filter state ──────────────────────────────────
  final RxString rewardTypeFilter = ''.obs;
  final RxString timeRangeFilter = ''.obs;

  bool get hasActiveRewardFilters =>
      rewardTypeFilter.value.isNotEmpty || timeRangeFilter.value.isNotEmpty;

  // ── Computed list ─────────────────────────────────

  List<app_models.Reward> get filteredRewards {
    var result = rewards.toList();

    // Apply reward type filter
    if (rewardTypeFilter.value.isNotEmpty) {
      result = result.where((r) {
        switch (rewardTypeFilter.value) {
          case 'xp':
            return r.type == 'chapter' ||
                r.type == 'exercise' ||
                r.type == 'daily';
          case 'badge':
            return r.type == 'challenge';
          case 'achievement':
            return r.type == 'admin_adjustment';
          default:
            return true;
        }
      }).toList();
    }

    // Apply time range filter
    if (timeRangeFilter.value.isNotEmpty) {
      final now = DateTime.now();
      result = result.where((r) {
        switch (timeRangeFilter.value) {
          case 'today':
            return r.timestamp.year == now.year &&
                r.timestamp.month == now.month &&
                r.timestamp.day == now.day;
          case 'this_week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return r.timestamp.isAfter(weekStart);
          case 'this_month':
            return r.timestamp.year == now.year &&
                r.timestamp.month == now.month;
          case 'all_time':
            return true;
          default:
            return true;
        }
      }).toList();
    }

    return result;
  }

  // ── Lifecycle ─────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadRewardsData();
  }

  // ── Filters ───────────────────────────────────────

  void showRewardFilterSheet() {
    final List<FilterSection> sections = _buildFilterSections();
    FilterSheet.show(
      title: '筛选奖励',
      sections: sections,
      onApply: () {
        // Filter values are already applied via section onChanged callbacks.
      },
      onReset: resetRewardFilters,
    );
  }

  List<FilterSection> _buildFilterSections() {
    return [
      FilterSection(
        title: '类型',
        options: const [
          FilterOption(value: 'xp', label: '经验'),
          FilterOption(value: 'badge', label: '徽章'),
          FilterOption(value: 'achievement', label: '成就'),
        ],
        selectedValues: rewardTypeFilter.value.isNotEmpty
            ? {rewardTypeFilter.value}
            : <String>{},
        onChanged: (values) {
          rewardTypeFilter.value = values.isEmpty ? '' : values.first;
        },
        allowMultiple: false,
      ),
      FilterSection(
        title: '时间范围',
        options: const [
          FilterOption(value: 'today', label: '今天'),
          FilterOption(value: 'this_week', label: '本周'),
          FilterOption(value: 'this_month', label: '本月'),
          FilterOption(value: 'all_time', label: '全部'),
        ],
        selectedValues: timeRangeFilter.value.isNotEmpty
            ? {timeRangeFilter.value}
            : <String>{},
        onChanged: (values) {
          timeRangeFilter.value = values.isEmpty ? '' : values.first;
        },
        allowMultiple: false,
      ),
    ];
  }

  void resetRewardFilters() {
    rewardTypeFilter.value = '';
    timeRangeFilter.value = '';
  }

  // ── Data loading ──────────────────────────────────

  Future<void> loadRewardsData() async {
    setLoading(message: '加载奖励中...');
    registerRetry(loadRewardsData);

    try {
      // Fetch profile (for XP card) and rewards in parallel
      final results = await Future.wait([
        _apiService.get('/learner/profile'),
        _apiService.get('/learner/rewards'),
      ]);

      final profileResponse = results[0];
      final rewardsResponse = results[1];

      // Parse profile data
      final profilePayload = profileResponse.data is Map<String, dynamic>
          ? profileResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final profile =
          profilePayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Build user from profile (account not needed for XP card display)
      user.value = app_models.User.fromContracts(
        account: {'id': profile['account_id'] ?? '', 'email': ''},
        profile: profile,
      );

      // Parse rewards data
      final rewardsPayload = rewardsResponse.data is Map<String, dynamic>
          ? rewardsResponse.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          rewardsPayload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Parse badges from rewards data
      final badgeItems = (data['badges'] as List<dynamic>? ?? <dynamic>[])
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

      // Parse xp ledger from rewards data
      final rewardItems = (data['xp_ledger'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) =>
              app_models.Reward.fromLedgerJson(Map<String, dynamic>.from(item)))
          .toList();
      rewards.assignAll(rewardItems);

      if (badgeItems.isEmpty && rewardItems.isEmpty) {
        setEmpty(message: '暂无奖励或徽章。开始学习吧！');
      } else {
        resetState();
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else if (e.response?.statusCode == 403) {
        setError(message: '当前账号暂无查看奖励的权限。');
      } else {
        debugPrint('加载奖励数据失败: $e');
        setError(message: '加载奖励数据失败，请重试。');
      }
    } catch (e) {
      debugPrint('加载奖励数据失败: $e');
      setError(message: '加载奖励数据失败，请重试。');
    }
  }

  int calculateNextLevelXp(int level) {
    return level * 1000;
  }

  void openBadgePreview(app_models.Badge badge) {
    Get.bottomSheet(
      BadgePreviewSheet(badge: badge),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class ProfileRewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRewardsController>(() => ProfileRewardsController());
  }
}
