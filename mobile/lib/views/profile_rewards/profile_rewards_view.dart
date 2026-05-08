import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/mock_data.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/filter_sheet.dart';

class ProfileRewardsView extends GetView<ProfileRewardsController> {
  const ProfileRewardsView({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Center'),
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
          emptyTitle: 'No Rewards Yet',
          emptyDescription: 'Complete challenges and courses to earn rewards.',
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
                        'Level $level',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$currentXp XP total',
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
                  '$xpToNext XP to next level',
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
          'Badges',
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
            'No Badges Yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Complete challenges to earn your first badge.',
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
                    badge.icon != null ? NetworkImage(badge.icon!) : null,
                child: badge.icon == null
                    ? Icon(
                        Icons.workspace_premium,
                        size: 32.sp,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
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
                'Rewards Ledger',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (controller.hasActiveRewardFilters)
              Text(
                '${rewards.length} results',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (rewards.isEmpty)
          _buildEmptyLedger(context, hasFilters: controller.hasActiveRewardFilters)
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
            hasFilters ? 'No matching rewards' : 'No Rewards Yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            hasFilters
                ? 'Try adjusting your filters.'
                : 'Your reward history will appear here.',
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
                    badge.icon != null ? NetworkImage(badge.icon!) : null,
                child: badge.icon == null
                    ? Icon(
                        Icons.workspace_premium,
                        size: 56.sp,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
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
                      'Earned on ${_formatDateLong(badge.earnedAt)}',
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
                      'Share',
                      'Sharing ${badge.name}...',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Achievement'),
                ),
              ),
              SizedBox(height: 8.h),
              // Close button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════
// Controller
// ═══════════════════════════════════════════════════════════

class ProfileRewardsController extends BaseController {
  final Rx<app_models.User?> user = Rx<app_models.User?>(null);
  final RxList<app_models.Badge> badges = <app_models.Badge>[].obs;
  final RxList<app_models.Reward> rewards = <app_models.Reward>[].obs;

  final MockDataService _mockDataService = MockDataService();

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
            return r.type == 'chapter' || r.type == 'exercise' || r.type == 'daily';
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
      title: 'Filter Rewards',
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
        title: 'Type',
        options: const [
          FilterOption(value: 'xp', label: 'XP'),
          FilterOption(value: 'badge', label: 'Badge'),
          FilterOption(value: 'achievement', label: 'Achievement'),
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
        title: 'Time Range',
        options: const [
          FilterOption(value: 'today', label: 'Today'),
          FilterOption(value: 'this_week', label: 'This Week'),
          FilterOption(value: 'this_month', label: 'This Month'),
          FilterOption(value: 'all_time', label: 'All Time'),
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
    setLoading(message: 'Loading rewards...');
    registerRetry(loadRewardsData);

    try {
      final userData = await _mockDataService.fetchUser();
      final badgesData = await _mockDataService.fetchBadges();
      final rewardsData = await _mockDataService.fetchRewards();

      user.value = userData;
      badges.assignAll(badgesData);
      rewards.assignAll(rewardsData);

      if (badgesData.isEmpty && rewardsData.isEmpty) {
        setEmpty(message: 'No rewards or badges yet. Start learning!');
      } else {
        resetState();
      }
    } catch (e) {
      setError(message: 'Failed to load rewards. Please try again.');
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
