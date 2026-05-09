import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' as app_models;
import '../../services/mock_data.dart';
import '../../widgets/page_state_host.dart';

enum TimeRange { week, month, all }

class ProfileStatsView extends GetView<ProfileStatsController> {
  const ProfileStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习统计'),
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          emptyTitle: '暂无统计',
          emptyDescription: '开始学习后即可查看统计数据。',
          emptyIcon: Icons.insights_outlined,
          child: _buildContent(context),
        );
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final stats = controller.stats.value;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(context),
          SizedBox(height: 24.h),
          _buildCoreMetrics(context, stats),
          SizedBox(height: 24.h),
          _buildLearningTrend(context),
          SizedBox(height: 24.h),
          _buildMasterySection(context, stats),
          SizedBox(height: 24.h),
          _buildRankingComparison(context),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Obx(() {
          return Row(
            children: TimeRange.values.map((range) {
              final isSelected = controller.selectedTimeRange.value == range;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.onTimeRangeChanged(range),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _timeRangeLabel(range),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  String _timeRangeLabel(TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return '本周';
      case TimeRange.month:
        return '本月';
      case TimeRange.all:
        return '全部';
    }
  }

  Widget _buildCoreMetrics(BuildContext context, app_models.Stats stats) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final metrics = [
      _MetricItem(
        label: '学习时长',
        value: '${stats.studyTime}m',
        icon: Icons.timer_outlined,
        color: colorScheme.primary,
      ),
      _MetricItem(
        label: '课程',
        value: '${stats.coursesCompleted}',
        icon: Icons.menu_book_outlined,
        color: colorScheme.tertiary,
      ),
      _MetricItem(
        label: '胜利',
        value: '${stats.challengesWon}',
        icon: Icons.emoji_events_outlined,
        color: colorScheme.secondary,
      ),
      _MetricItem(
        label: '经验',
        value: '${stats.totalXp}',
        icon: Icons.star_outline,
        color: const Color(0xFFFFA000),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '核心指标',
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
            childAspectRatio: 1.5,
            children: metrics.map((item) {
              return _MetricCard(item: item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTrend(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习趋势',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160.h,
                    child: Obx(() {
                      final data = controller.trendData;
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            '暂无趋势数据',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return _SimpleBarChart(data: data);
                    }),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '每日学习分钟数',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterySection(BuildContext context, app_models.Stats stats) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final mastery = stats.mastery ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '知识掌握度',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: _ProgressRing(
                      progress: mastery,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(mastery * 100).toInt()}%',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '总体掌握度',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          mastery >= 0.8
                              ? '太棒了！你对材料掌握得很好。'
                              : mastery >= 0.5
                                  ? '进展不错。继续练习以提高。'
                                  : '刚开始。坚持是关键。',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingComparison(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '排名对比',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Obx(() {
                final leaderboard = controller.leaderboardData;
                if (leaderboard.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        '暂无排名数据',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: leaderboard.take(5).map((entry) {
                    final isCurrentUser = entry.rank == 1;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: entry.rank <= 3
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.rank}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: entry.rank <= 3
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.nickname,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  'Level ${entry.level ?? 1}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.xp} XP',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.icon,
                  size: 20.sp,
                  color: item.color,
                ),
                SizedBox(width: 8.w),
                Text(
                  item.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              item.value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({required this.data});

  final List<int> data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxValue = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final heightFactor = maxValue == 0 ? 0.0 : value / maxValue;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: (heightFactor * 100).h,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'D${index + 1}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(100.w, 100.w),
      painter: _ProgressRingPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        backgroundColor: backgroundColor,
        strokeWidth: 10.w,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159265359 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProfileStatsController extends BaseController {
  final Rx<TimeRange> selectedTimeRange = TimeRange.week.obs;
  final Rx<app_models.Stats?> stats = Rx<app_models.Stats?>(null);
  final RxList<app_models.LeaderboardEntry> leaderboardData =
      <app_models.LeaderboardEntry>[].obs;
  final RxList<int> trendData = <int>[].obs;

  final MockDataService _mockDataService = Get.find<MockDataService>();

  @override
  void onInit() {
    super.onInit();
    loadStatsData();
  }

  Future<void> loadStatsData() async {
    setLoading(message: '加载统计中...');
    registerRetry(loadStatsData);

    try {
      final statsResult = await _mockDataService.fetchStats();
      final leaderboard = await _mockDataService.fetchLeaderboard();

      if (statsResult != null) {
        stats.value = statsResult;
        leaderboardData.assignAll(leaderboard);
        _generateTrendData();
        resetState();
      } else {
        setEmpty(message: '暂无统计数据。');
      }
    } catch (e) {
      setError(message: '加载统计数据失败，请重试。');
    }
  }

  void onTimeRangeChanged(TimeRange range) {
    if (selectedTimeRange.value == range) return;
    selectedTimeRange.value = range;
    _generateTrendData();
  }

  void _generateTrendData() {
    final baseStats = stats.value;
    if (baseStats == null) {
      trendData.clear();
      return;
    }

    final multiplier = switch (selectedTimeRange.value) {
      TimeRange.week => 1.0,
      TimeRange.month => 2.5,
      TimeRange.all => 4.0,
    };

    final baseValue = (baseStats.studyTime / 7).round();
    trendData.assignAll(
      List<int>.generate(7, (index) {
        final variation = (index % 3 - 1) * 10;
        return ((baseValue + variation) * multiplier).round().clamp(0, 999);
      }),
    );
  }
}

class ProfileStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileStatsController>(() => ProfileStatsController());
  }
}
