import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
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

  ApiService get _apiService => Get.find<ApiService>();

  ProgressService get _progress {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

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
    if (!_progress.isOnline.value) {
      final cachedChallenge = _progress.getCachedDailyChallenge();
      if (cachedChallenge != null) {
        final merged = _progress.applyDailyChallengeProgress(cachedChallenge);
        dailyChallenge.value = merged;
        status.value = merged.isAttempted
            ? DailyChallengeStatus.attempted
            : merged.isExpired
                ? DailyChallengeStatus.expired
                : DailyChallengeStatus.notAttempted;
        final now = DateTime.now();
        _nextResetTime = DateTime(now.year, now.month, now.day + 1);
        _startCountdown();
        setPartialData(message: '当前为离线模式，已加载本地每日挑战记录。');
        return;
      }
    }

    setLoading(message: '加载每日挑战中...');
    registerRetry(loadDailyChallenge);

    try {
      final response = await _apiService.get('/learner/daily-challenges/today');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (data.isEmpty) {
        setEmpty(message: '今日暂无每日挑战。');
        return;
      }

      final challengeData =
          data['daily_challenge'] as JsonMap? ?? <String, dynamic>{};
      final recordData = data['learner_record'] as JsonMap?;

      final challenge = DailyChallenge.fromContracts(
        challenge: challengeData,
        record: recordData,
      );

      final merged = _progress.applyDailyChallengeProgress(challenge);
      dailyChallenge.value = merged;
      await _progress.cacheDailyChallenge(merged);

      if (merged.isAttempted) {
        status.value = DailyChallengeStatus.attempted;
      } else if (merged.isExpired) {
        status.value = DailyChallengeStatus.expired;
      } else {
        status.value = DailyChallengeStatus.notAttempted;
      }

      // Calculate next reset time (next midnight local time)
      final now = DateTime.now();
      _nextResetTime = DateTime(now.year, now.month, now.day + 1);
      _startCountdown();

      resetState();
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else if (e.response?.statusCode == 403) {
        setError(message: '当前账号暂无每日挑战访问权限。');
      } else if (e.response?.statusCode == 404) {
        setEmpty(message: '今日暂无每日挑战。');
      } else if (e.response?.statusCode == 500) {
        setError(message: '每日挑战服务暂时不可用，请稍后重试。');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '加载每日挑战超时，请重试。');
      } else {
        debugPrint('加载每日挑战失败: $e');
        setError(message: '加载每日挑战失败，请重试。');
      }
    } catch (e) {
      debugPrint('加载每日挑战失败: $e');
      setError(message: '加载每日挑战失败，请重试。');
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

  Future<void> startDailyChallenge() async {
    if (status.value != DailyChallengeStatus.notAttempted) return;
    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      final challengeId = dailyChallenge.value?.id ?? '';
      if (challengeId.isEmpty) return;

      await _apiService.post(
        '/learner/daily-challenges/$challengeId/submit',
        data: <String, dynamic>{
          'score': 100,
          'elapsed_seconds': 0,
        },
      );

      await _progress.saveDailyChallengeCompletion(
        challengeId: challengeId,
      );
      status.value = DailyChallengeStatus.attempted;

      final cs = Theme.of(Get.context!).colorScheme;
      Get.snackbar(
        '每日挑战完成',
        '今日挑战记录已保存，连续学习天数已更新。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: cs.primaryContainer,
        colorText: cs.onPrimaryContainer,
      );
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // 今日已提交过，刷新状态
        status.value = DailyChallengeStatus.attempted;
        final cs = Theme.of(Get.context!).colorScheme;
        Get.snackbar(
          '已完成',
          '今日挑战已经完成。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: cs.primaryContainer,
          colorText: cs.onPrimaryContainer,
        );
      } else if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else if (e.response?.statusCode == 403) {
        Get.snackbar(
          '错误',
          '当前账号暂无每日挑战提交权限。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
          colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
        );
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        Get.snackbar(
          '错误',
          '提交超时，请重试。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
          colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
        );
      } else if (e.type == dio.DioExceptionType.connectionError) {
        Get.snackbar(
          '错误',
          '网络连接异常，请检查后重试。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
          colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
        );
      } else {
        Get.snackbar(
          '错误',
          '提交每日挑战失败，请重试。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
          colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
        );
      }
    } catch (e) {
      final cs = Theme.of(Get.context!).colorScheme;
      Get.snackbar(
        '错误',
        '提交每日挑战失败，请重试。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: cs.errorContainer,
        colorText: cs.onErrorContainer,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String getStatusText() {
    return switch (status.value) {
      DailyChallengeStatus.notAttempted => '未尝试',
      DailyChallengeStatus.attempted => '今日已完成',
      DailyChallengeStatus.expired => '已过期',
    };
  }

  Color getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status.value) {
      DailyChallengeStatus.notAttempted => colorScheme.primary,
      DailyChallengeStatus.attempted => colorScheme.primary,
      DailyChallengeStatus.expired => colorScheme.error,
    };
  }

  String getTimeLimitText() {
    final challenge = dailyChallenge.value;
    if (challenge == null) return '';

    if (challenge.timeLimit <= 0) {
      return '无时间限制';
    }

    final minutes = challenge.timeLimit ~/ 60;
    final seconds = challenge.timeLimit % 60;

    if (seconds > 0) {
      return '$minutes 分 $seconds 秒';
    }
    return '$minutes 分钟';
  }

  String getNextAttemptText() {
    if (_nextResetTime == null) return '';
    return '下一次挑战刷新时间：${countdownText.value}';
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
        title: Text('每日挑战', style: theme.textTheme.titleLarge),
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
      return const Center(child: Text('暂无每日挑战。'));
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
                  isExpired ? '挑战已过期' : '剩余时间',
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
              '午夜重置',
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
                  color: colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.today_outlined,
                  size: 28.sp,
                  color: colorScheme.onSecondaryContainer,
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
            label: '时间限制',
            value: controller.getTimeLimitText(),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            icon: Icons.repeat,
            label: '频率',
            value: '每日一次',
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            icon: Icons.emoji_events,
            label: '奖励',
            value: 'XP + 连续天数奖励',
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
                '此挑战已过期。明天再来吧！',
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
                '规则',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRuleItem(context, '1. 每日挑战每天可尝试一次。'),
          _buildRuleItem(context, '2. 挑战每天午夜重置。'),
          _buildRuleItem(context, '3. 在时间限制内完成可获得额外奖励。'),
          _buildRuleItem(context, '4. 每日挑战有助于保持你的学习连续天数。'),
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
            primaryLabel: controller.isSubmitting.value ? '开始中...' : '开始每日挑战',
            onPrimary: controller.isSubmitting.value
                ? () {}
                : controller.startDailyChallenge,
          );
        case DailyChallengeStatus.attempted:
          return CTABar(
            primaryLabel: '已完成',
            onPrimary: () {
              Get.snackbar(
                '已完成',
                '你已完成今日挑战。明天再来吧！',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          );
        case DailyChallengeStatus.expired:
          return CTABar(
            primaryLabel: '挑战已过期',
            onPrimary: () {
              Get.snackbar(
                '挑战已过期',
                '此挑战已过期。等待下一个挑战！',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          );
      }
    });
  }
}
