import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
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

  static const String _storageCompletionTimes = 'challenge_completion_times';
  static const String _storageRewardSettledTimes = 'challenge_reward_settled_times';

  final Rxn<DateTime> completionTimestamp = Rxn<DateTime>();
  final Rxn<DateTime> rewardSettlementTimestamp = Rxn<DateTime>();
  final RxBool isRewardSettled = false.obs;
  final RxBool isSettlingReward = false.obs;

  MockDataService get _mockData => Get.find<MockDataService>();
  StorageService get _storage => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    challengeId.value = Get.parameters['id'] ?? '';
    if (challengeId.value.isNotEmpty) {
      loadChallenge();
    } else {
      setError(message: 'Invalid challenge ID.');
    }
  }

  Future<void> loadChallenge() async {
    setLoading(message: 'Loading challenge...');
    registerRetry(loadChallenge);

    try {
      // Fetch challenges and find the matching one
      final allChallenges = await _mockData.fetchChallenges();
      final found = allChallenges.firstWhereOrNull(
        (c) => c.id == challengeId.value,
      );

      if (found == null) {
        setEmpty(message: 'Challenge not found.');
        return;
      }

      challenge.value = found;
      tasks.assignAll(found.tasks);

      // Load persisted state
      final starsData = _storage.read<Map<String, dynamic>>('challenge_stars');
      if (starsData != null && starsData.containsKey(challengeId.value)) {
        earnedStars.value = (starsData[challengeId.value] as num).toInt();
      } else {
        earnedStars.value = found.stars;
      }

      // Read persisted completion timestamp
      final completionTimes = _storage.read<Map<String, dynamic>>(_storageCompletionTimes);
      if (completionTimes != null && completionTimes.containsKey(challengeId.value)) {
        final ts = DateTime.tryParse(completionTimes[challengeId.value] as String? ?? '');
        if (ts != null) completionTimestamp.value = ts;
      }

      // Read persisted reward settlement timestamp
      final settledTimes = _storage.read<Map<String, dynamic>>(_storageRewardSettledTimes);
      if (settledTimes != null && settledTimes.containsKey(challengeId.value)) {
        final ts = DateTime.tryParse(settledTimes[challengeId.value] as String? ?? '');
        if (ts != null) {
          rewardSettlementTimestamp.value = ts;
          isRewardSettled.value = true;
        }
      }

      // Determine state
      if (found.isCompleted) {
        detailState.value = ChallengeDetailState.completed;
      } else {
        detailState.value = ChallengeDetailState.overview;
      }

      resetState();
    } catch (e) {
      setError(message: 'Failed to load challenge. Please try again.');
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

      // Persist stars
      final starsData = _storage.read<Map<String, dynamic>>('challenge_stars') ?? {};
      starsData[challengeId.value] = stars;
      await _storage.write('challenge_stars', starsData);

      // Persist completion timestamp
      final now = DateTime.now();
      completionTimestamp.value = now;
      final completionTimes = _storage.read<Map<String, dynamic>>(_storageCompletionTimes) ?? {};
      completionTimes[challengeId.value] = now.toIso8601String();
      await _storage.write(_storageCompletionTimes, completionTimes);

      // Persist completion status
      final completedData = _storage.read<List<dynamic>>('completed_challenges') ?? [];
      if (!completedData.contains(challengeId.value)) {
        completedData.add(challengeId.value);
        await _storage.write('completed_challenges', completedData);
      }

      Get.snackbar(
        'Challenge Complete!',
        'You earned $stars ${stars == 1 ? 'star' : 'stars'} and ${challenge.value?.reward ?? 0} XP!',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.green[50],
        colorText: Colors.green[800],
      );
    } catch (e) {
      setError(message: 'Failed to submit challenge. Please try again.');
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

      final settledTimes = _storage.read<Map<String, dynamic>>(_storageRewardSettledTimes) ?? {};
      settledTimes[challengeId.value] = now.toIso8601String();
      await _storage.write(_storageRewardSettledTimes, settledTimes);

      Get.snackbar(
        'Reward Claimed!',
        'Your reward for ${challenge.value?.title ?? 'this challenge'} has been settled.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.green[50],
        colorText: Colors.green[800],
      );
    } catch (e) {
      setError(message: 'Failed to settle reward. Please try again.');
    } finally {
      isSettlingReward.value = false;
    }
  }

  String getStarRuleDescription() {
    return 'Complete all tasks to earn 3 stars.\n'
        'Complete 60% or more to earn 2 stars.\n'
        'Complete 30% or more to earn 1 star.';
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
        title: Text('Challenge', style: theme.textTheme.titleLarge),
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
      return const Center(child: Text('Challenge not found.'));
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
            color: Colors.amber[600],
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
              _buildDifficultyChip(context, 'Intermediate'),
              SizedBox(width: 8.w),
              Chip(
                label: Text(
                  '${challenge.reward} XP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.amber[50],
                side: BorderSide(color: Colors.amber[200]!),
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
            'Tasks',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Complete these tasks to finish the challenge',
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
                  'No tasks defined for this challenge.',
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
            ? Colors.green[50]
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green[200]!
              : colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: task.isCompleted
                ? Colors.green[100]
                : colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: task.isCompleted
                ? Icon(Icons.check, size: 18.sp, color: Colors.green[700])
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
                ? Icon(Icons.check_circle, color: Colors.green[600], size: 24.sp)
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
              Icon(Icons.stars, size: 20.sp, color: Colors.amber[600]),
              SizedBox(width: 8.w),
              Text(
                'Star Rules',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStarRuleItem(context, stars: 3, label: 'Complete all tasks'),
          _buildStarRuleItem(context, stars: 2, label: 'Complete 60% or more'),
          _buildStarRuleItem(context, stars: 1, label: 'Complete 30% or more'),
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
                color: i < stars ? Colors.amber[600] : Colors.grey[300],
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

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, size: 20.sp, color: Colors.amber[700]),
              SizedBox(width: 8.w),
              Text(
                'Reward Preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRewardItem(
            context,
            icon: Icons.stars,
            label: 'Experience Points',
            value: '${challenge.reward} XP',
          ),
          _buildRewardItem(
            context,
            icon: Icons.emoji_events,
            label: 'Challenge Completion',
            value: 'Badge + Stars',
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
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.amber[600]),
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
              color: Colors.amber[800],
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
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 48.sp,
                  color: Colors.green[600],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Challenge Completed!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: 32.sp,
                      color: i < stars ? Colors.amber[600] : Colors.grey[300],
                    );
                  }),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$stars ${stars == 1 ? 'Star' : 'Stars'} Earned',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '+${challenge?.reward ?? 0} XP',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (completionTime != null) ...[
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16.sp, color: Colors.green[600]),
                      SizedBox(width: 6.w),
                      Text(
                        'Completed: ${_formatTimestamp(completionTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
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
                      Icon(Icons.card_giftcard, size: 16.sp, color: Colors.green[600]),
                      SizedBox(width: 6.w),
                      Text(
                        'Reward settled: ${_formatTimestamp(settlementTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
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
            Icon(Icons.emoji_events, size: 24.sp, color: Colors.amber[600]),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Achievements',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'See all your badges and completed challenges',
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
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final state = controller.detailState.value;

      switch (state) {
        case ChallengeDetailState.overview:
          return CTABar(
            primaryLabel: 'Start Challenge',
            onPrimary: controller.startChallenge,
          );
        case ChallengeDetailState.inProgress:
          return CTABar(
            primaryLabel: controller.isSubmitting.value
                ? 'Submitting...'
                : 'Complete Challenge',
            onPrimary: controller.isSubmitting.value
                ? () {}
                : controller.completeChallenge,
          );
        case ChallengeDetailState.completed:
          if (controller.isRewardSettled.value) {
            return CTABar(
              primaryLabel: 'Back to Map',
              onPrimary: () => Get.back(),
            );
          }
          return CTABar(
            primaryLabel: controller.isSettlingReward.value
                ? 'Claiming...'
                : 'Claim Reward',
            onPrimary: controller.isSettlingReward.value
                ? () {}
                : controller.settleReward,
            secondaryLabel: 'Back to Map',
            onSecondary: () => Get.back(),
          );
      }
    });
  }
}
