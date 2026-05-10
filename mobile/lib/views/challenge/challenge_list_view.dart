import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';

enum ChallengeNodeStatus {
  locked,
  accessible,
  inProgress,
  completed,
}

class ChallengeListController extends BaseController {
  final RxList<Challenge> challenges = <Challenge>[].obs;
  final RxMap<String, int> challengeStars = <String, int>{}.obs;

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
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    if (!_progress.isOnline.value) {
      final cachedItems = _progress.getCachedChallenges();
      if (cachedItems.isNotEmpty) {
        final merged = _progress.applyChallengeProgressList(cachedItems);
        challenges.assignAll(merged);
        challengeStars.assignAll({
          for (final item in merged) item.id: item.stars,
        });
        setPartialData(message: '当前为离线模式，已显示本地挑战记录。');
        return;
      }
    }

    setLoading(message: '加载挑战中...');
    registerRetry(loadChallenges);

    try {
      final response = await _apiService.get('/learner/challenges');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => Challenge.fromMapItemJson(Map<String, dynamic>.from(item)))
          .toList();

      await _progress.cacheChallenges(items);
      final merged = _progress.applyChallengeProgressList(items);
      challenges.assignAll(merged);
      challengeStars.assignAll({
        for (final item in merged) item.id: item.stars,
      });

      if (items.isEmpty) {
        setEmpty(message: '暂无可用挑战。');
      } else {
        resetState();
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录后查看挑战。');
      } else if (e.response?.statusCode == 403) {
        setError(message: '当前账号暂无挑战访问权限。');
      } else if (e.response?.statusCode == 500) {
        setError(message: '挑战服务暂时不可用，请稍后重试。');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        setError(message: '加载挑战超时，请重试。');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        setError(message: '网络连接异常，请检查后重试。');
      } else {
        setError(message: '加载挑战失败，请重试。');
      }
    } catch (e) {
      setError(message: '加载挑战失败，请重试。');
    }
  }

  ChallengeNodeStatus getNodeStatus(int index) {
    if (index >= challenges.length) return ChallengeNodeStatus.locked;

    final challenge = challenges[index];
    if (challenge.isCompleted) return ChallengeNodeStatus.completed;

    if (index == 0) return ChallengeNodeStatus.accessible;

    final prevChallenge = challenges[index - 1];
    if (prevChallenge.isCompleted) return ChallengeNodeStatus.accessible;

    // If previous is not completed, check if any earlier challenge is in progress
    final anyInProgress = challenges.sublist(0, index).any((c) => !c.isCompleted);
    if (!anyInProgress) return ChallengeNodeStatus.accessible;

    return ChallengeNodeStatus.locked;
  }

  int getNodeStars(int index) {
    if (index >= challenges.length) return 0;
    final challenge = challenges[index];
    return challengeStars[challenge.id] ?? challenge.stars;
  }

  void onNodeTap(int index) {
    final status = getNodeStatus(index);
    if (status == ChallengeNodeStatus.locked) {
      Get.snackbar(
        '已锁定',
        '请先完成前面的挑战。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final challenge = challenges[index];
    Get.toNamed('/challenge/${challenge.id}');
  }

  void navigateToDailyChallenge() {
    Get.toNamed('/daily-challenge');
  }
}

class ChallengeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengeListController>(() => ChallengeListController());
  }
}

class ChallengeListView extends GetView<ChallengeListController> {
  const ChallengeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('挑战', style: theme.textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: controller.navigateToDailyChallenge,
            icon: Icon(Icons.today_outlined, size: 20.sp),
            label: Text(
              '每日',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          onRetry: controller.retry,
          child: _buildChallengeMap(context),
        );
      }),
    );
  }

  Widget _buildChallengeMap(BuildContext context) {
    return Obx(() {
      final challenges = controller.challenges;
      if (challenges.isEmpty) {
        return const Center(child: Text('暂无可用挑战。'));
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 24.h),
            _buildProgressSummary(context),
            SizedBox(height: 32.h),
            _buildNodeMap(context),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '挑战地图',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '完成挑战以获取星星和XP',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final total = controller.challenges.length;
      final completed = controller.challenges.where((c) => c.isCompleted).length;
      final totalStars = controller.challenges.fold<int>(
        0,
        (sum, c) => sum + controller.getNodeStars(controller.challenges.indexOf(c)),
      );
      final maxStars = total * 3;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                value: '$completed/$total',
                label: '已完成',
              ),
            ),
            Container(width: 1.w, height: 40.h, color: theme.dividerColor),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Icons.star_outline,
                value: '$totalStars/$maxStars',
                label: '星星',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: theme.colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNodeMap(BuildContext context) {
    return Obx(() {
      final challenges = controller.challenges;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          final status = controller.getNodeStatus(index);
          final stars = controller.getNodeStars(index);
          final isLast = index == challenges.length - 1;

          return _buildNodeItem(
            context,
            index: index,
            challenge: challenge,
            status: status,
            stars: stars,
            showConnector: !isLast,
          );
        },
      );
    });
  }

  Widget _buildNodeItem(
    BuildContext context, {
    required int index,
    required Challenge challenge,
    required ChallengeNodeStatus status,
    required int stars,
    required bool showConnector,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (nodeColor, nodeIcon, nodeBgColor) = switch (status) {
      ChallengeNodeStatus.locked => (
          colorScheme.outline,
          Icons.lock_outline,
          colorScheme.surfaceContainerHighest,
        ),
      ChallengeNodeStatus.accessible => (
          colorScheme.primary,
          Icons.play_arrow_outlined,
          colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
      ChallengeNodeStatus.inProgress => (
          colorScheme.tertiary,
          Icons.hourglass_empty,
          colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        ),
      ChallengeNodeStatus.completed => (
          colorScheme.primary,
          Icons.check,
          colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
    };

    return InkWell(
      onTap: () => controller.onNodeTap(index),
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node column with connector
          Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: nodeBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == ChallengeNodeStatus.locked
                        ? colorScheme.outline.withValues(alpha: 0.3)
                        : nodeColor,
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Icon(
                    nodeIcon,
                    color: nodeColor,
                    size: 24.sp,
                  ),
                ),
              ),
              if (showConnector)
                Container(
                  width: 2.w,
                  height: 40.h,
                  color: status == ChallengeNodeStatus.completed
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.2),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Challenge info card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: showConnector ? 0 : 0),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: status == ChallengeNodeStatus.locked
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: status == ChallengeNodeStatus.accessible
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStarRating(context, stars),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    challenge.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: status == ChallengeNodeStatus.locked
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 16.sp,
                        color: colorScheme.secondary,
                      ),
                      Text(
                        '${challenge.reward} XP',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (status == ChallengeNodeStatus.completed) ...[
                        Icon(
                          Icons.check_circle,
                          size: 16.sp,
                          color: colorScheme.primary,
                        ),
                        Text(
                          '已完成',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
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

  Widget _buildStarRating(BuildContext context, int stars) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 2.w,
      children: List.generate(3, (i) {
        return Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 16.sp,
          color: i < stars ? colorScheme.secondary : colorScheme.outline.withValues(alpha: 0.3),
        );
      }),
    );
  }
}
