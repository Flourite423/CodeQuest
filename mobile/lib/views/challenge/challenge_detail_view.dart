import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';
import '../../widgets/syntax_highlighter.dart';

enum ChallengeDetailState {
  overview,
  inProgress,
  completed,
}


class ChallengeController extends BaseController {
  final RxString challengeId = ''.obs;
  final Rxn<Challenge> challenge = Rxn<Challenge>();
  final RxList<ChallengeTask> tasks = <ChallengeTask>[].obs;
  final Rxn<Exercise> currentExercise = Rxn<Exercise>();
  final RxBool isLoadingExercise = false.obs;
  final RxInt earnedStars = 0.obs;
  final Rx<ChallengeDetailState> detailState =
      ChallengeDetailState.overview.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentTaskIndex = 0.obs;

  // Code editor state
  final TextEditingController codeController = TextEditingController();
  final RxString selectedChoiceKey = ''.obs;
  final RxBool showCodeEditor = false.obs;

  final Rxn<DateTime> completionTimestamp = Rxn<DateTime>();
  final Rxn<DateTime> rewardSettlementTimestamp = Rxn<DateTime>();
  final RxBool isRewardSettled = false.obs;
  final RxBool isSettlingReward = false.obs;

  // Track per-task stage results for final attempt submission
  final RxMap<String, Map<String, dynamic>> stageResults = <String, Map<String, dynamic>>{}.obs;

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
    challengeId.value = Get.parameters['id'] ?? '';
    if (challengeId.value.isNotEmpty) {
      loadChallenge();
    } else {
      setError(message: '无效的挑战ID。');
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  bool get isCurrentTaskCoding => currentExercise.value?.type == 'coding';
  bool get isCurrentTaskSingleChoice => currentExercise.value?.type == 'single_choice';

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
        completionTimestamp.value =
            _progress.getChallengeCompletedAt(challengeId.value);
        rewardSettlementTimestamp.value =
            _progress.getChallengeRewardSettledAt(challengeId.value);
        isRewardSettled.value =
            _progress.isChallengeRewardSettled(challengeId.value);
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
      final response =
          await _apiService.get('/learner/challenges/${challengeId.value}');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (data.isEmpty) {
        setEmpty(message: '未找到挑战。');
        return;
      }

      final found = Challenge.fromMapItemJson(data);
      await _progress.cacheChallenges([found]);
      final processedChallenge = _progress.applyChallengeProgress(found);
      challenge.value = processedChallenge;
      tasks.assignAll(processedChallenge.tasks);
      earnedStars.value = processedChallenge.stars;
      completionTimestamp.value =
          _progress.getChallengeCompletedAt(challengeId.value);
      rewardSettlementTimestamp.value =
          _progress.getChallengeRewardSettledAt(challengeId.value);
      isRewardSettled.value =
          _progress.isChallengeRewardSettled(challengeId.value);
      detailState.value = processedChallenge.isCompleted
          ? ChallengeDetailState.completed
          : ChallengeDetailState.overview;

      resetState();
    } catch (e) {
      debugPrint('Failed to load challenge: $e');
      setError(message: '加载挑战失败，请重试。');
    }
  }

  Future<void> _loadExercise(String exerciseId) async {
    isLoadingExercise.value = true;
    try {
      final response =
          await _apiService.get('/learner/exercises/$exerciseId');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      currentExercise.value = Exercise.fromDetailJson(data);

      if (currentExercise.value!.type == 'coding') {
        codeController.text = currentExercise.value!.codeTemplate ?? '';
        showCodeEditor.value = true;
      } else {
        showCodeEditor.value = false;
      }
      selectedChoiceKey.value = '';
    } catch (e) {
      debugPrint('Failed to load exercise: $e');
      currentExercise.value = null;
    } finally {
      isLoadingExercise.value = false;
    }
  }

  void startChallenge() {
    detailState.value = ChallengeDetailState.inProgress;
    currentTaskIndex.value = 0;
    if (tasks.isNotEmpty) {
      _loadExercise(tasks[0].id);
    }
  }

  void selectTask(int index) {
    if (detailState.value != ChallengeDetailState.inProgress) return;
    currentTaskIndex.value = index;
    if (index >= 0 && index < tasks.length) {
      _loadExercise(tasks[index].id);
    }
  }

  void selectChoice(String key) {
    selectedChoiceKey.value = key;
  }

  Future<void> submitCurrentTask() async {
    final exercise = currentExercise.value;
    if (exercise == null) return;

    if (exercise.type == 'single_choice' && selectedChoiceKey.value.isEmpty) {
      Get.snackbar(
        '请选择答案',
        '请先选择一个选项再提交。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Submit via real API
      String sourceCode;
      bool passed;
      int score;

      if (exercise.type == 'coding') {
        sourceCode = codeController.text;
        final response = await _apiService.post('/learner/submissions', data: {
          'exercise_id': exercise.id,
          'source_code': sourceCode,
        });
        final result = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final submissionData = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        passed = (submissionData['judge_status'] ?? '') == 'passed';
        score = (submissionData['score'] as num?)?.toInt() ?? 0;
      } else {
        // Single choice: check against selected option
        sourceCode = selectedChoiceKey.value;
        final correctOption = exercise.options.isNotEmpty
            ? exercise.options.first.key
            : '';
        passed = selectedChoiceKey.value == correctOption;
        score = passed ? 100 : 0;
      }

      // Record stage result
      stageResults[tasks[currentTaskIndex.value].id] = {
        'stage_id': tasks[currentTaskIndex.value].id,
        'passed': passed,
        'score': score,
        'source_code': sourceCode,
      };

      // Mark current task as completed
      tasks[currentTaskIndex.value] = ChallengeTask(
        id: tasks[currentTaskIndex.value].id,
        title: tasks[currentTaskIndex.value].title,
        isCompleted: true,
      );

      // Move to next task or complete challenge
      if (currentTaskIndex.value < tasks.length - 1) {
        currentTaskIndex.value++;
        _loadExercise(tasks[currentTaskIndex.value].id);
        Get.snackbar(
          '任务完成！',
          passed ? '进入下一个任务。' : '进入下一个任务。（未完全通过）',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await completeChallenge();
      }
    } catch (e) {
      debugPrint('Failed to submit task: $e');
      Get.snackbar(
        '提交失败',
        '提交任务失败，请重试。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> completeChallenge() async {
    isSubmitting.value = true;

    try {
      // Submit challenge attempt via real API
      final stageResultsList = stageResults.values.toList();
      final response = await _apiService.post(
        '/learner/challenges/${challengeId.value}/attempts',
        data: {
          'stage_results': stageResultsList,
        },
      );

      final result = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final attemptData = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final stars = (attemptData['best_star'] as num?)?.toInt() ?? 0;

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
        '你获得了 $stars 颗星 和 ${challenge.value?.reward ?? 0} 经验值！',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: cs.primaryContainer,
        colorText: cs.onPrimaryContainer,
      );
    } catch (e) {
      debugPrint('Failed to complete challenge: $e');
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
        if (controller.pageState.value != PageState.initial) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final challenge = controller.challenge.value;
    if (challenge == null) {
      return const Center(child: Text('未找到挑战。'));
    }

    return Obx(() {
      final state = controller.detailState.value;
      final isInProgress = state == ChallengeDetailState.inProgress;

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChallengeHeader(context, challenge),
            SizedBox(height: 24.h),
            if (isInProgress) ...[
              // Show task selector and current task content
              _buildTaskSelector(context),
              SizedBox(height: 16.h),
              _buildCurrentTaskContent(context),
              SizedBox(height: 100.h), // Space for bottom bar
            ] else ...[
              // Show task list (overview or completed)
              _buildTaskList(context),
            ],
            SizedBox(height: 24.h),
            _buildStarRules(context),
            SizedBox(height: 24.h),
            _buildRewardPreview(context, challenge),
            if (state == ChallengeDetailState.completed) ...[
              SizedBox(height: 24.h),
              _buildCompletionResult(context),
            ],
            SizedBox(height: 100.h), // Space for bottom bar
          ],
        ),
      );
    });
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: colorScheme.secondary),
                ),
                child: Text(
                  '${challenge.reward} XP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

    // 使用自定义标签替代 Chip，避免被识别为可交互元素
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        difficulty,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : isActive
                ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive
              ? colorScheme.primary
              : task.isCompleted
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: task.isCompleted
                ? colorScheme.primaryContainer
                : isActive
                    ? colorScheme.primary
                    : colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: task.isCompleted
                ? Icon(Icons.check, size: 18.sp, color: colorScheme.primary)
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isActive ? colorScheme.onPrimary : colorScheme.primary,
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
            fontWeight: isActive ? FontWeight.w600 : null,
          ),
        ),
        trailing: isInteractive
            ? (task.isCompleted
                ? Icon(Icons.check_circle, color: colorScheme.primary, size: 24.sp)
                : isActive
                    ? Icon(Icons.play_circle_filled, color: colorScheme.primary, size: 24.sp)
                    : Icon(Icons.circle_outlined, color: colorScheme.outline, size: 24.sp))
            : task.isCompleted
                ? Icon(Icons.check_circle, color: colorScheme.primary, size: 24.sp)
                : Icon(Icons.circle_outlined, color: colorScheme.outline, size: 24.sp),
        onTap: isInteractive && !task.isCompleted ? () => controller.selectTask(index) : null,
      ),
    );
  }

  /// Task selector for in-progress state
  Widget _buildTaskSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '任务进度',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() => Column(
          children: List.generate(controller.tasks.length, (index) {
            final task = controller.tasks[index];
            final isActive = index == controller.currentTaskIndex.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildTaskItem(
                context,
                index: index,
                task: task,
                isInteractive: true,
                isActive: isActive,
              ),
            );
          }),
        )),
      ],
    );
  }

  /// Current task content (code editor or choice selector)
  Widget _buildCurrentTaskContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final exercise = controller.currentExercise.value;
      if (exercise == null) {
        if (controller.isLoadingExercise.value) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ));
        }
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      exercise.type == 'coding' ? Icons.code : Icons.quiz,
                      size: 20.sp,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      exercise.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  exercise.type == 'coding' ? '编程题' : '单选题',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Prompt
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '题目说明',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    exercise.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Code editor or choice selector
          if (exercise.type == 'coding') ...[
            _buildCodeEditor(context),
          ] else if (exercise.type == 'single_choice') ...[
            _buildChoiceSelector(context, exercise),
          ],
        ],
      );
    });
  }

  /// Code editor widget
  Widget _buildCodeEditor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作区',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                    ),
                    child: Text(
                      'HTML / CSS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextField(
                    controller: controller.codeController,
                    minLines: 10,
                    maxLines: 15,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: '在此编写你的解决方案...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                  ),
                  // Syntax highlighting preview below editor
                  if (controller.codeController.text.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '语法高亮预览',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SyntaxHighlighter(
                            code: controller.codeController.text,
                            language: 'html',
                            showLineNumbers: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Choice selector widget
  Widget _buildChoiceSelector(BuildContext context, Exercise exercise) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择答案',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            ...List.generate(exercise.options.length, (index) {
              final option = exercise.options[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildChoiceOptionTile(context, option.key, option.text),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceOptionTile(BuildContext context, String key, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isSelected = controller.selectedChoiceKey.value == key;

      return InkWell(
        onTap: () => controller.selectChoice(key),
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surface,
                ),
                child: Text(
                  key,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      );
    });
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
                color: i < stars
                    ? cs.secondary
                    : cs.outline.withValues(alpha: 0.3),
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
              border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3)),
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
                      color: i < stars
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
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
                      Icon(Icons.check_circle_outline,
                          size: 16.sp, color: theme.colorScheme.primary),
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
                      Icon(Icons.card_giftcard,
                          size: 16.sp, color: theme.colorScheme.primary),
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
            primaryLabel: controller.isSubmitting.value ? '提交中...' : '提交当前任务',
            onPrimary: controller.isSubmitting.value
                ? () {}
                : controller.submitCurrentTask,
          );
        case ChallengeDetailState.completed:
          if (controller.isRewardSettled.value) {
            return CTABar(
              primaryLabel: '返回地图',
              onPrimary: () => Get.back(),
            );
          }
          return CTABar(
            primaryLabel: controller.isSettlingReward.value ? '领取中...' : '领取奖励',
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
