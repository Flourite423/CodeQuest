import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/mock_data.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';

enum ChallengeDetailState {
  overview,
  inProgress,
  completed,
}

class ChallengeController extends BaseController {
  final RxString challengeId = ''.obs;
  final Rxn<Challenge> challenge = Rxn<Challenge>();
  final RxList<ChallengeTask> tasks = <ChallengeTask>[].obs;
  final RxInt earnedStars = 0.obs;
  final Rx<ChallengeDetailState> detailState = ChallengeDetailState.overview.obs;
  final RxBool isSubmitting = false.obs;

  final Rxn<DateTime> completionTimestamp = Rxn<DateTime>();
  final Rxn<DateTime> rewardSettlementTimestamp = Rxn<DateTime>();
  final RxBool isRewardSettled = false.obs;
  final RxBool isSettlingReward = false.obs;

  MockDataService get _mockData => Get.find<MockDataService>();

  ProgressService get _progress {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    challengeId.value = Get.parameters['id'] ?? '';
    if (challengeId.value.isNotEmpty) {
      loadChallenge();
    } else {
      setError(message: '无效的挑战ID。');
    }
  }

  Future<void> loadChallenge() async {
    if (!_progress.isOnline.value) {
      final cachedChallenges = _progress.getCachedChallenges();
      final cachedItem = cachedChallenges.firstWhereOrNull(
        (item) => item.id == challengeId.value,
      );
      if (cachedItem != null) {
        final processed = _progress.applyChallengeProgress(cachedItem);
        challenge.value = processed;
        tasks.assignAll(processed.tasks);
        earnedStars.value = processed.stars;
        completionTimestamp.value = _progress.getChallengeCompletedAt(challengeId.value);
        rewardSettlementTimestamp.value =
            _progress.getChallengeRewardSettledAt(challengeId.value);
        isRewardSettled.value = _progress.isChallengeRewardSettled(challengeId.value);
        detailState.value = processed.isCompleted
            ? ChallengeDetailState.completed
            : ChallengeDetailState.overview;
        setPartialData(message: '当前为离线模式，已加载本地挑战数据。');
        return;
      }
    }

    setLoading(message: '加载挑战中...');
    registerRetry(loadChallenge);

    try {
      // Fetch challenges and find the matching one
      final allChallenges = await _mockData.fetchChallenges();
      final found = allChallenges.firstWhereOrNull(
        (c) => c.id == challengeId.value,
      );

      if (found == null) {
        setEmpty(message: '未找到挑战。');
        return;
      }

      await _progress.cacheChallenges(allChallenges);
      final processedChallenge = _progress.applyChallengeProgress(found);
      challenge.value = processedChallenge;
      tasks.assignAll(processedChallenge.tasks);
      earnedStars.value = processedChallenge.stars;
      completionTimestamp.value = _progress.getChallengeCompletedAt(challengeId.value);
      rewardSettlementTimestamp.value =
          _progress.getChallengeRewardSettledAt(challengeId.value);
      isRewardSettled.value = _progress.isChallengeRewardSettled(challengeId.value);
      detailState.value = processedChallenge.isCompleted
          ? ChallengeDetailState.completed
          : ChallengeDetailState.overview;

      resetState();
    } catch (e) {
      setError(message: '加载挑战失败，请重试。');
    }
  }

  void startChallenge() {
    detailState.value = ChallengeDetailState.inProgress;
  }

  Future<void> completeChallenge() async {
    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      // Simulate submission delay
      await Future.delayed(const Duration(seconds: 1));

      // Calculate stars based on task completion
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final totalTasks = tasks.length;

      int stars;
      if (totalTasks == 0) {
        stars = 0;
      } else {
        final ratio = completedTasks / totalTasks;
        if (ratio >= 1.0) {
          stars = 3;
        } else if (ratio >= 0.6) {
          stars = 2;
        } else if (ratio >= 0.3) {
          stars = 1;
        } else {
          stars = 0;
        }
      }

      earnedStars.value = stars;
      detailState.value = ChallengeDetailState.completed;

      final now = DateTime.now();
      completionTimestamp.value = now;
      await _progress.saveChallengeCompletion(
        challengeId: challengeId.value,
        stars: stars,
        rewardXp: challenge.value?.reward ?? 0,
        completedAt: now,
      );

      final cs = Theme.of(Get.context!).colorScheme;
      Get.snackbar(
        '挑战完成！',
        '你获得了 $stars ${stars == 1 ? '颗星' : '颗星'} 和 ${challenge.value?.reward ?? 0} 经验值！',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: cs.primaryContainer,
        colorText: cs.onPrimaryContainer,
      );
    } catch (e) {
      setError(message: '提交挑战失败，请重试。');
    } finally {
      isSubmitting.value = false;
    }
  }

  void toggleTask(int index) {
    if (index < 0 || index >= tasks.length) return;
    if (detailState.value != ChallengeDetailState.inProgress) return;

    final task = tasks[index];
    tasks[index] = ChallengeTask(
      id: task.id,
      title: task.title,
      isCompleted: !task.isCompleted,
    );
  }

  Future<void> settleReward() async {
    if (isSettlingReward.value) return;
    if (isRewardSettled.value) return;

    isSettlingReward.value = true;

    try {
      // Simulate settlement delay
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      rewardSettlementTimestamp.value = now;
      isRewardSettled.value = true;
      await _progress.markChallengeRewardSettled(challengeId.value);

      final cs = Theme.of(Get.context!).colorScheme;
      Get.snackbar(
        '奖励已领取！',
        '${challenge.value?.title ?? '此挑战'} 的奖励已结算。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: cs.primaryContainer,
        colorText: cs.onPrimaryContainer,
      );
    } catch (e) {
      setError(message: '结算奖励失败，请重试。');
    } finally {
      isSettlingReward.value = false;
    }
  }

  String getStarRuleDescription() {
    return '完成所有任务可获得 3 颗星。\n'
        '完成 60% 或更多可获得 2 颗星。\n'
        '完成 30% 或更多可获得 1 颗星。';
  }
}

class ChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengeController>(() => ChallengeController());
  }
}

class ChallengeDetailView extends GetView<ChallengeController> {
  const ChallengeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('挑战', style: theme.textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          child: _buildContent(context),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.pageState.value != PageState.initial) return const SizedBox.shrink();
        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final challenge = controller.challenge.value;
    if (challenge == null) {
      return const Center(child: Text('未找到挑战。'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChallengeHeader(context, challenge),
          SizedBox(height: 24.h),
          _buildTaskList(context),
          SizedBox(height: 24.h),
          _buildStarRules(context),
          SizedBox(height: 24.h),
          _buildRewardPreview(context, challenge),
          if (controller.detailState.value == ChallengeDetailState.completed) ...[
            SizedBox(height: 24.h),
            _buildCompletionResult(context),
          ],
          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 64.sp,
            color: colorScheme.secondary,
          ),
          SizedBox(height: 16.h),
          Text(
            challenge.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            challenge.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDifficultyChip(context, '中级'),
              SizedBox(width: 8.w),
                Chip(
                  label: Text(
                    '${challenge.reward} XP',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  side: BorderSide(color: colorScheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Chip(
      label: Text(
        difficulty,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final tasks = controller.tasks;
      final state = controller.detailState.value;
      final isInteractive = state == ChallengeDetailState.inProgress;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '任务',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '完成这些任务以完成挑战',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          if (tasks.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  '该挑战暂无任务。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return _buildTaskItem(
                context,
                index: index,
                task: task,
                isInteractive: isInteractive,
              );
            }),
        ],
      );
    });
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required int index,
    required ChallengeTask task,
    required bool isInteractive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
      color: task.isCompleted
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: task.isCompleted
            ? colorScheme.primary.withValues(alpha: 0.3)
            : colorScheme.outline.withValues(alpha: 0.1),
      ),
      ),
      child: ListTile(
        leading: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
          color: task.isCompleted
              ? colorScheme.primaryContainer
              : colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: task.isCompleted
                ? Icon(Icons.check, size: 18.sp, color: colorScheme.primary)
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
        trailing: isInteractive
            ? Checkbox(
                value: task.isCompleted,
                onChanged: (_) => controller.toggleTask(index),
              )
            : task.isCompleted
                ? Icon(Icons.check_circle, color: colorScheme.primary, size: 24.sp)
                : Icon(Icons.circle_outlined, color: colorScheme.outline, size: 24.sp),
        onTap: isInteractive ? () => controller.toggleTask(index) : null,
      ),
    );
  }

  Widget _buildStarRules(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, size: 20.sp, color: colorScheme.secondary),
              SizedBox(width: 8.w),
              Text(
                '星级规则',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStarRuleItem(context, stars: 3, label: '完成所有任务'),
          _buildStarRuleItem(context, stars: 2, label: '完成 60% 或更多'),
          _buildStarRuleItem(context, stars: 1, label: '完成 30% 或更多'),
        ],
      ),
    );
  }

  Widget _buildStarRuleItem(
    BuildContext context, {
    required int stars,
    required String label,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Icon(
                i < stars ? Icons.star : Icons.star_border,
                size: 16.sp,
                color: i < stars ? cs.secondary : cs.outline.withValues(alpha: 0.3),
              );
            }),
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPreview(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, size: 20.sp, color: cs.secondary),
              SizedBox(width: 8.w),
              Text(
                '奖励预览',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRewardItem(
            context,
            icon: Icons.stars,
            label: '经验值',
            value: '${challenge.reward} XP',
          ),
          _buildRewardItem(
            context,
            icon: Icons.emoji_events,
            label: '挑战完成',
            value: '徽章 + 星级',
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: cs.secondary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionResult(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final stars = controller.earnedStars.value;
      final challenge = controller.challenge.value;
      final completionTime = controller.completionTimestamp.value;
      final isSettled = controller.isRewardSettled.value;
      final settlementTime = controller.rewardSettlementTimestamp.value;

      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 48.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 12.h),
                Text(
                  '挑战完成！',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: 32.sp,
                      color: i < stars ? theme.colorScheme.secondary : theme.colorScheme.outline.withValues(alpha: 0.3),
                    );
                  }),
                ),
                SizedBox(height: 8.h),
                Text(
                  '获得 $stars ${stars == 1 ? '颗星' : '颗星'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '+${challenge?.reward ?? 0} XP',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (completionTime != null) ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16.sp, color: theme.colorScheme.primary),
                      SizedBox(width: 6.w),
                      Text(
                        '完成时间：${_formatTimestamp(completionTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isSettled && settlementTime != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, size: 16.sp, color: theme.colorScheme.primary),
                      SizedBox(width: 6.w),
                      Text(
                        '奖励已结算：${_formatTimestamp(settlementTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _buildAchievementEntry(context),
        ],
      );
    });
  }

  Widget _buildAchievementEntry(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => Get.toNamed('/profile'),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, size: 24.sp, color: colorScheme.secondary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '查看成就',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '查看所有徽章和已完成的挑战',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final state = controller.detailState.value;

      switch (state) {
        case ChallengeDetailState.overview:
          return CTABar(
            primaryLabel: '开始挑战',
            onPrimary: controller.startChallenge,
          );
        case ChallengeDetailState.inProgress:
          return CTABar(
            primaryLabel: controller.isSubmitting.value
                ? '提交中...'
                : '完成挑战',
            onPrimary: controller.isSubmitting.value
                ? () {}
                : controller.completeChallenge,
          );
        case ChallengeDetailState.completed:
          if (controller.isRewardSettled.value) {
            return CTABar(
              primaryLabel: '返回地图',
              onPrimary: () => Get.back(),
            );
          }
          return CTABar(
            primaryLabel: controller.isSettlingReward.value
                ? '领取中...'
                : '领取奖励',
            onPrimary: controller.isSettlingReward.value
                ? () {}
                : controller.settleReward,
            secondaryLabel: '返回地图',
            onSecondary: () => Get.back(),
          );
      }
    });
  }
}
