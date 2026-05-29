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
import '../../widgets/syntax_highlighter.dart';
import '../../widgets/syntax_highlighter.dart';

enum ChallengeDetailState {
  overview,
  inProgress,
  completed,
}

/// Mock challenge task data for demo purposes
class MockChallengeTaskData {
  final String id;
  final String title;
  final String exerciseTitle;
  final String exerciseType; // 'coding' or 'single_choice'
  final String prompt;
  final String? starterCode;
  final List<String>? options;
  final String? correctAnswer;

  const MockChallengeTaskData({
    required this.id,
    required this.title,
    required this.exerciseTitle,
    required this.exerciseType,
    required this.prompt,
    this.starterCode,
    this.options,
    this.correctAnswer,
  });
}

/// Mock challenge tasks mapping
final Map<String, List<MockChallengeTaskData>> _mockChallengeTasks = {
  // HTML新手挑战
  'mock-challenge-001': [
    MockChallengeTaskData(
      id: 'mock-challenge-001-stage-1',
      title: '阶段 1：创建基本HTML页面',
      exerciseTitle: '创建基本HTML页面',
      exerciseType: 'coding',
      prompt: '请创建一个包含标题和段落的基本HTML页面。\n\n要求：\n1. 使用 `<h1>` 标签创建标题"我的主页"\n2. 使用 `<p>` 标签创建一段自我介绍',
      starterCode: '<!DOCTYPE html>\n<html>\n<head>\n    <title>我的主页</title>\n</head>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-001-stage-2',
      title: '阶段 2：HTML文档结构知识',
      exerciseTitle: 'HTML文档结构',
      exerciseType: 'single_choice',
      prompt: '以下哪个标签用于定义HTML文档的根元素？',
      options: ['<html>', '<body>', '<head>', '<div>'],
      correctAnswer: 'A',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-001-stage-3',
      title: '阶段 3：创建标题层级',
      exerciseTitle: '创建标题层级',
      exerciseType: 'coding',
      prompt: '请创建一个包含多级标题的HTML页面。\n\n要求：\n1. 使用 `<h1>` 创建主标题"我的网站"\n2. 使用 `<h2>` 创建副标题"关于我"\n3. 使用 `<h3>` 创建三级标题"我的爱好"',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>',
    ),
  ],
  // HTML进阶挑战
  'mock-challenge-002': [
    MockChallengeTaskData(
      id: 'mock-challenge-002-stage-1',
      title: '阶段 1：创建无序列表',
      exerciseTitle: '创建列表',
      exerciseType: 'coding',
      prompt: '请创建一个HTML无序列表。\n\n要求：\n1. 使用 `<ul>` 标签创建无序列表\n2. 包含至少3个 `<li>` 列表项\n3. 列表内容为：HTML、CSS、JavaScript',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-002-stage-2',
      title: '阶段 2：创建链接',
      exerciseTitle: '创建链接',
      exerciseType: 'coding',
      prompt: '请创建一个HTML超链接。\n\n要求：\n1. 使用 `<a>` 标签创建链接\n2. 链接地址为 `https://example.com`\n3. 链接文字为"访问示例网站"\n4. 设置 `target="_blank"` 在新窗口打开',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-002-stage-3',
      title: '阶段 3：插入图片',
      exerciseTitle: '插入图片',
      exerciseType: 'coding',
      prompt: '请创建一个HTML图片标签。\n\n要求：\n1. 使用 `<img>` 标签插入图片\n2. 设置 `src` 为 `https://via.placeholder.com/150`\n3. 设置 `alt` 为"示例图片"\n4. 设置 `width` 为 150',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <!-- 在这里编写你的代码 -->\n    \n</body>\n</html>',
    ),
  ],
  // CSS基础挑战
  'mock-challenge-003': [
    MockChallengeTaskData(
      id: 'mock-challenge-003-stage-1',
      title: '阶段 1：使用类选择器',
      exerciseTitle: '使用类选择器',
      exerciseType: 'coding',
      prompt: '请使用CSS类选择器将class为"highlight"的元素背景色设置为黄色。',
      starterCode: '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        /* 在这里添加CSS */\n        \n    </style>\n</head>\n<body>\n    <p class="highlight">这段文字应该有黄色背景</p>\n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-003-stage-2',
      title: '阶段 2：选择器优先级知识',
      exerciseTitle: '选择器优先级',
      exerciseType: 'single_choice',
      prompt: '在CSS中，以下哪个选择器的优先级最高？',
      options: ['ID选择器 (#id)', '类选择器 (.class)', '元素选择器 (div)', '通配符选择器 (*)'],
      correctAnswer: 'A',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-003-stage-3',
      title: '阶段 3：设置盒模型',
      exerciseTitle: '设置盒模型',
      exerciseType: 'coding',
      prompt: '请设置一个盒子的样式。\n\n要求：\n1. 宽度 200px\n2. 高度 100px\n3. 边框 2px solid black\n4. 内边距 10px\n5. 背景色 lightblue',
      starterCode: '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        .box {\n            /* 在这里添加样式 */\n            \n        }\n    </style>\n</head>\n<body>\n    <div class="box">这是一个盒子</div>\n</body>\n</html>',
    ),
  ],
  // CSS布局挑战
  'mock-challenge-004': [
    MockChallengeTaskData(
      id: 'mock-challenge-004-stage-1',
      title: '阶段 1：创建Flexbox布局',
      exerciseTitle: 'Flexbox布局',
      exerciseType: 'coding',
      prompt: '请使用Flexbox创建一个水平导航栏。\n\n要求：\n1. 使用 `display: flex` 创建flex容器\n2. 包含3个导航项：首页、关于、联系\n3. 导航项之间有间距',
      starterCode: '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        .navbar {\n            /* 在这里添加Flexbox样式 */\n            \n        }\n        .nav-item {\n            padding: 10px;\n        }\n    </style>\n</head>\n<body>\n    <nav class="navbar">\n        <div class="nav-item">首页</div>\n        <div class="nav-item">关于</div>\n        <div class="nav-item">联系</div>\n    </nav>\n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-004-stage-2',
      title: '阶段 2：Flexbox属性知识',
      exerciseTitle: 'Flexbox属性',
      exerciseType: 'single_choice',
      prompt: '在Flexbox布局中，哪个属性用于设置主轴方向？',
      options: ['flex-direction', 'justify-content', 'align-items', 'flex-wrap'],
      correctAnswer: 'A',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-004-stage-3',
      title: '阶段 3：创建Grid布局',
      exerciseTitle: 'Grid布局',
      exerciseType: 'coding',
      prompt: '请使用CSS Grid创建一个2x2的网格布局。\n\n要求：\n1. 使用 `display: grid` 创建grid容器\n2. 设置 `grid-template-columns` 为两列\n3. 包含4个网格项',
      starterCode: '<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        .grid-container {\n            /* 在这里添加Grid样式 */\n            \n        }\n        .grid-item {\n            padding: 20px;\n            background-color: lightblue;\n            border: 1px solid #ccc;\n        }\n    </style>\n</head>\n<body>\n    <div class="grid-container">\n        <div class="grid-item">1</div>\n        <div class="grid-item">2</div>\n        <div class="grid-item">3</div>\n        <div class="grid-item">4</div>\n    </div>\n</body>\n</html>',
    ),
  ],
  // JavaScript基础挑战
  'mock-challenge-005': [
    MockChallengeTaskData(
      id: 'mock-challenge-005-stage-1',
      title: '阶段 1：创建变量和函数',
      exerciseTitle: '变量和函数',
      exerciseType: 'coding',
      prompt: '请创建一个JavaScript函数。\n\n要求：\n1. 创建一个变量 `name`，值为 "World"\n2. 创建一个函数 `greet`，返回 "Hello, " + name\n3. 调用函数并输出结果',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <script>\n        // 在这里编写你的代码\n        \n    </script>\n</body>\n</html>',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-005-stage-2',
      title: '阶段 2：数据类型知识',
      exerciseTitle: '数据类型',
      exerciseType: 'single_choice',
      prompt: '在JavaScript中，以下哪个不是基本数据类型？',
      options: ['string', 'number', 'object', 'boolean'],
      correctAnswer: 'C',
    ),
    MockChallengeTaskData(
      id: 'mock-challenge-005-stage-3',
      title: '阶段 3：创建条件语句',
      exerciseTitle: '条件语句',
      exerciseType: 'coding',
      prompt: '请创建一个条件语句。\n\n要求：\n1. 创建一个变量 `score`，值为 85\n2. 使用 if-else 语句判断分数\n3. 如果分数 >= 60，输出 "及格"\n4. 否则输出 "不及格"',
      starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    <script>\n        // 在这里编写你的代码\n        \n    </script>\n</body>\n</html>',
    ),
  ],
};

class ChallengeController extends BaseController {
  final RxString challengeId = ''.obs;
  final Rxn<Challenge> challenge = Rxn<Challenge>();
  final RxList<ChallengeTask> tasks = <ChallengeTask>[].obs;
  final RxList<MockChallengeTaskData> mockTasks = <MockChallengeTaskData>[].obs;
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

  MockChallengeTaskData? get currentMockTask {
    if (currentTaskIndex.value >= 0 && currentTaskIndex.value < mockTasks.length) {
      return mockTasks[currentTaskIndex.value];
    }
    return null;
  }

  bool get isCurrentTaskCoding => currentMockTask?.exerciseType == 'coding';
  bool get isCurrentTaskSingleChoice => currentMockTask?.exerciseType == 'single_choice';

  Future<void> loadChallenge() async {
    if (!_progress.isOnline.value) {
      final cachedChallenges = _progress.getCachedChallenges();
      final cachedItem = cachedChallenges.firstWhereOrNull(
        (item) => item.id == challengeId.value,
      );
      if (cachedItem != null) {
        final processed = _progress.applyChallengeProgress(cachedItem);
        challenge.value = processed;
        _loadMockTasks(processed);
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
      _loadMockTasks(processedChallenge);
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
    } on dio.DioException catch (e) {
      // Mock challenge data fallback
      debugPrint('Failed to load challenge: $e, using mock data');
      final mockChallenge = Challenge(
        id: challengeId.value,
        title: challengeId.value == 'mock-challenge-001'
            ? 'HTML 新手挑战'
            : challengeId.value == 'mock-challenge-002'
                ? 'HTML 进阶挑战'
                : 'CSS 基础挑战',
        description: challengeId.value == 'mock-challenge-001'
            ? '测试你的 HTML 基础知识'
            : challengeId.value == 'mock-challenge-002'
                ? '挑战更复杂的 HTML 结构'
                : '测试你的 CSS 基础知识',
        tasks: [],
        stars: 0,
        reward: challengeId.value == 'mock-challenge-001'
            ? 50
            : challengeId.value == 'mock-challenge-002'
                ? 100
                : 75,
        isCompleted: false,
      );
      challenge.value = mockChallenge;
      _loadMockTasks(mockChallenge);
      detailState.value = ChallengeDetailState.overview;
      resetState();
    } catch (e) {
      // Mock challenge data fallback
      debugPrint('Failed to load challenge: $e, using mock data');
      final mockChallenge = Challenge(
        id: challengeId.value,
        title: challengeId.value == 'mock-challenge-001'
            ? 'HTML 新手挑战'
            : challengeId.value == 'mock-challenge-002'
                ? 'HTML 进阶挑战'
                : 'CSS 基础挑战',
        description: challengeId.value == 'mock-challenge-001'
            ? '测试你的 HTML 基础知识'
            : challengeId.value == 'mock-challenge-002'
                ? '挑战更复杂的 HTML 结构'
                : '测试你的 CSS 基础知识',
        tasks: [],
        stars: 0,
        reward: challengeId.value == 'mock-challenge-001'
            ? 50
            : challengeId.value == 'mock-challenge-002'
                ? 100
                : 75,
        isCompleted: false,
      );
      challenge.value = mockChallenge;
      _loadMockTasks(mockChallenge);
      detailState.value = ChallengeDetailState.overview;
      resetState();
    }
  }

  void _loadMockTasks(Challenge challenge) {
    final mockData = _mockChallengeTasks[challengeId.value];
    if (mockData != null) {
      mockTasks.assignAll(mockData);
      tasks.assignAll(mockData.map((m) => ChallengeTask(
        id: m.id,
        title: m.title,
        isCompleted: false,
      )).toList());
    } else {
      // Fallback for unknown challenges
      mockTasks.assignAll([
        MockChallengeTaskData(
          id: '${challenge.id}-stage-1',
          title: '阶段 1：完成练习',
          exerciseTitle: '基础练习',
          exerciseType: 'coding',
          prompt: '请完成这个练习。',
          starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    \n</body>\n</html>',
        ),
        MockChallengeTaskData(
          id: '${challenge.id}-stage-2',
          title: '阶段 2：知识测验',
          exerciseTitle: '知识测验',
          exerciseType: 'single_choice',
          prompt: 'HTML中哪个标签用于创建段落？',
          options: ['<p>', '<div>', '<span>', '<br>'],
          correctAnswer: 'A',
        ),
        MockChallengeTaskData(
          id: '${challenge.id}-stage-3',
          title: '阶段 3：进阶练习',
          exerciseTitle: '进阶练习',
          exerciseType: 'coding',
          prompt: '请完成这个进阶练习。',
          starterCode: '<!DOCTYPE html>\n<html>\n<body>\n    \n</body>\n</html>',
        ),
      ]);
      tasks.assignAll(mockTasks.map((m) => ChallengeTask(
        id: m.id,
        title: m.title,
        isCompleted: false,
      )).toList());
    }
  }

  void startChallenge() {
    detailState.value = ChallengeDetailState.inProgress;
    currentTaskIndex.value = 0;
    _loadCurrentTaskCode();
  }

  void _loadCurrentTaskCode() {
    final task = currentMockTask;
    if (task == null) return;

    if (task.exerciseType == 'coding') {
      codeController.text = task.starterCode ?? '';
      showCodeEditor.value = true;
    } else {
      showCodeEditor.value = false;
    }
    selectedChoiceKey.value = '';
  }

  void selectTask(int index) {
    if (detailState.value != ChallengeDetailState.inProgress) return;
    currentTaskIndex.value = index;
    _loadCurrentTaskCode();
  }

  void selectChoice(String key) {
    selectedChoiceKey.value = key;
  }

  /// Submit current task (mock implementation)
  void submitCurrentTask() {
    final task = currentMockTask;
    if (task == null) return;

    if (task.exerciseType == 'single_choice' && selectedChoiceKey.value.isEmpty) {
      Get.snackbar(
        '请选择答案',
        '请先选择一个选项再提交。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Mark current task as completed
    tasks[currentTaskIndex.value] = ChallengeTask(
      id: task.id,
      title: task.title,
      isCompleted: true,
    );

    // Move to next task or complete challenge
    if (currentTaskIndex.value < mockTasks.length - 1) {
      currentTaskIndex.value++;
      _loadCurrentTaskCode();
      Get.snackbar(
        '任务完成！',
        '进入下一个任务。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      // All tasks completed
      completeChallenge();
    }
  }

  Future<void> completeChallenge() async {
    isSubmitting.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final completedCount = tasks.where((t) => t.isCompleted).length;
      final totalCount = tasks.length;
      final passRatio = completedCount / totalCount;

      final stars = passRatio >= 1.0 ? 3 : (passRatio >= 0.6 ? 2 : (passRatio >= 0.3 ? 1 : 0));
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
          children: List.generate(controller.mockTasks.length, (index) {
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
      final task = controller.currentMockTask;
      if (task == null) return const SizedBox.shrink();

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
                      task.exerciseType == 'coding' ? Icons.code : Icons.quiz,
                      size: 20.sp,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      task.exerciseTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  task.exerciseType == 'coding' ? '编程题' : '单选题',
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
                    task.prompt,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Code editor or choice selector
          if (task.exerciseType == 'coding') ...[
            _buildCodeEditor(context),
          ] else if (task.exerciseType == 'single_choice') ...[
            _buildChoiceSelector(context, task),
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
  Widget _buildChoiceSelector(BuildContext context, MockChallengeTaskData task) {
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
            ...List.generate(task.options?.length ?? 0, (index) {
              final optionKey = String.fromCharCode(65 + index); // A, B, C, D
              final optionText = task.options![index];
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildChoiceOptionTile(context, optionKey, optionText),
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
