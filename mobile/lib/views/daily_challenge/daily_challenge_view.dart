import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';

enum DailyChallengeStatus {
  notAttempted,
  attempted,
  expired,
}

class DailyChallengeController extends BaseController {
  final Rxn<DailyChallenge> dailyChallenge = Rxn<DailyChallenge>();
  final Rx<DailyChallengeStatus> status = DailyChallengeStatus.notAttempted.obs;
  final RxString countdownText = ''.obs;
  final RxBool isSubmitting = false.obs;

  Timer? _countdownTimer;
  DateTime? _nextResetTime;

  MockDataService get _mockData => Get.find<MockDataService>();
  StorageService get _storage => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    loadDailyChallenge();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDailyChallenge() async {
    setLoading(message: 'Loading daily challenge...');
    registerRetry(loadDailyChallenge);

    try {
      final challenge = await _mockData.fetchDailyChallenge();
      if (challenge == null) {
        setEmpty(message: 'No daily challenge available today.');
        return;
      }

      dailyChallenge.value = challenge;

      // Load persisted attempt status
      final lastAttemptDate = _storage.read<String>('daily_challenge_last_attempt');
      final today = _formatDate(DateTime.now());

      if (lastAttemptDate == today) {
        status.value = DailyChallengeStatus.attempted;
      } else if (challenge.isExpired) {
        status.value = DailyChallengeStatus.expired;
      } else {
        status.value = DailyChallengeStatus.notAttempted;
      }

      // Calculate next reset time (next midnight local time)
      final now = DateTime.now();
      _nextResetTime = DateTime(now.year, now.month, now.day + 1);
      _startCountdown();

      resetState();
    } catch (e) {
      setError(message: 'Failed to load daily challenge. Please try again.');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_nextResetTime == null) return;

    final now = DateTime.now();
    final diff = _nextResetTime!.difference(now);

    if (diff.isNegative) {
      countdownText.value = '00:00:00';
      // Auto-reload when countdown reaches zero
      loadDailyChallenge();
      return;
    }

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    countdownText.value = '$hours:$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> startDailyChallenge() async {
    if (status.value != DailyChallengeStatus.notAttempted) return;
    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      // Simulate challenge attempt
      await Future.delayed(const Duration(seconds: 2));

      // Mark as attempted
      final today = _formatDate(DateTime.now());
      await _storage.write('daily_challenge_last_attempt', today);
      status.value = DailyChallengeStatus.attempted;

      Get.snackbar(
        'Daily Challenge Complete!',
        'Great job completing today\'s challenge!',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.green[50],
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit daily challenge. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String getStatusText() {
    return switch (status.value) {
      DailyChallengeStatus.notAttempted => 'Not Attempted',
      DailyChallengeStatus.attempted => 'Completed Today',
      DailyChallengeStatus.expired => 'Expired',
    };
  }

  Color getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status.value) {
      DailyChallengeStatus.notAttempted => colorScheme.primary,
      DailyChallengeStatus.attempted => Colors.green[600]!,
      DailyChallengeStatus.expired => colorScheme.error,
    };
  }

  String getTimeLimitText() {
    final challenge = dailyChallenge.value;
    if (challenge == null) return '';

    final minutes = challenge.timeLimit ~/ 60;
    final seconds = challenge.timeLimit % 60;

    if (seconds > 0) {
      return '$minutes min ${seconds}s';
    }
    return '$minutes min';
  }

  String getNextAttemptText() {
    if (_nextResetTime == null) return '';
    return 'Next challenge available in: ${countdownText.value}';
  }
}

class DailyChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyChallengeController>(() => DailyChallengeController());
  }
}

class DailyChallengeView extends GetView<DailyChallengeController> {
  const DailyChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Challenge', style: theme.textTheme.titleLarge),
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
        if (controller.pageState.value != PageState.initial) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final challenge = controller.dailyChallenge.value;
    if (challenge == null) {
      return const Center(child: Text('No daily challenge available.'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCountdownCard(context),
          SizedBox(height: 24.h),
          _buildChallengeCard(context, challenge),
          SizedBox(height: 24.h),
          _buildStatusCard(context),
          SizedBox(height: 24.h),
          _buildRulesCard(context),
          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildCountdownCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final status = controller.status.value;
      final isExpired = status == DailyChallengeStatus.expired;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isExpired
              ? colorScheme.errorContainer.withValues(alpha: 0.3)
              : colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpired
                ? colorScheme.error.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 24.sp,
                  color: isExpired ? colorScheme.error : colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  isExpired ? 'Challenge Expired' : 'Time Remaining',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpired ? colorScheme.error : colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(() {
              return Text(
                controller.countdownText.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isExpired ? colorScheme.error : colorScheme.onSurface,
                ),
              );
            }),
            SizedBox(height: 8.h),
            Text(
              'Resets at midnight',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChallengeCard(BuildContext context, DailyChallenge challenge) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.today_outlined,
                  size: 28.sp,
                  color: Colors.amber[700],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      challenge.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          _buildInfoRow(
            context,
            icon: Icons.timer,
            label: 'Time Limit',
            value: controller.getTimeLimitText(),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            icon: Icons.repeat,
            label: 'Frequency',
            value: 'Once per day',
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            icon: Icons.emoji_events,
            label: 'Reward',
            value: 'XP + Streak Bonus',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20.sp, color: colorScheme.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final status = controller.status.value;
      final statusColor = controller.getStatusColor(context);
      final statusText = controller.getStatusText();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  switch (status) {
                    DailyChallengeStatus.notAttempted => Icons.circle_outlined,
                    DailyChallengeStatus.attempted => Icons.check_circle,
                    DailyChallengeStatus.expired => Icons.cancel_outlined,
                  },
                  size: 24.sp,
                  color: statusColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  statusText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (status == DailyChallengeStatus.attempted) ...[
              SizedBox(height: 8.h),
              Text(
                controller.getNextAttemptText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (status == DailyChallengeStatus.expired) ...[
              SizedBox(height: 8.h),
              Text(
                'This challenge has expired. Come back tomorrow!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildRulesCard(BuildContext context) {
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
              Icon(Icons.info_outline, size: 20.sp, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Rules',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRuleItem(context, '1. You can attempt the daily challenge once per day.'),
          _buildRuleItem(context, '2. The challenge resets at midnight every day.'),
          _buildRuleItem(context, '3. Complete within the time limit for bonus rewards.'),
          _buildRuleItem(context, '4. Daily challenges help maintain your learning streak.'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final status = controller.status.value;

      switch (status) {
        case DailyChallengeStatus.notAttempted:
          return CTABar(
            primaryLabel: controller.isSubmitting.value
                ? 'Starting...'
                : 'Start Daily Challenge',
            onPrimary: controller.isSubmitting.value
                ? () {}
                : controller.startDailyChallenge,
          );
        case DailyChallengeStatus.attempted:
          return CTABar(
            primaryLabel: 'Already Completed',
            onPrimary: () {
              Get.snackbar(
                'Already Completed',
                'You have already completed today\'s challenge. Come back tomorrow!',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          );
        case DailyChallengeStatus.expired:
          return CTABar(
            primaryLabel: 'Challenge Expired',
            onPrimary: () {
              Get.snackbar(
                'Challenge Expired',
                'This challenge has expired. Wait for the next one!',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          );
      }
    });
  }
}
