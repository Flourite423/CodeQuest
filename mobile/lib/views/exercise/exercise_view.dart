import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';
import '../../widgets/syntax_highlighter.dart';
import '../../widgets/code_preview_webview.dart';
import 'widgets/ai_help_sheet.dart';
import 'widgets/submission_result_sheet.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.exerciseTitle)),
      ),
      body: Obx(
        () => PageStateHost(
          state: controller.pageState.value,
          message: controller.stateMessage.value,
          onRetry: controller.retry,
          emptyTitle: '练习不可用',
          emptyDescription: '该练习暂无学习内容。',
          child: _ExerciseWorkspace(controller: controller),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.exercise.value == null) {
          return const SizedBox.shrink();
        }

        return CTABar(
          secondaryLabel: 'AI 帮助',
          onSecondary: controller.isRequestingAiHelp.value
              ? null
              : controller.openAiHelpSheet,
          primaryLabel: controller.isSubmitting.value ? '提交中...' : '提交',
          onPrimary: controller.isSubmitting.value ? () {} : controller.submit,
        );
      }),
    );
  }
}

class _ExerciseWorkspace extends StatelessWidget {
  const _ExerciseWorkspace({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exercise = controller.exercise.value;
      if (exercise == null) {
        return const SizedBox.shrink();
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
        children: [
          _ExerciseMetaCard(controller: controller, exercise: exercise),
          SizedBox(height: 16.h),
          _ExercisePromptCard(prompt: exercise.description),
          SizedBox(height: 16.h),
          if (controller.isSingleChoice) ...[
            _SingleChoiceSection(controller: controller),
            SizedBox(height: 16.h),
          ],
          if (controller.isCoding) ...[
            _CodingWorkspaceSection(controller: controller),
            SizedBox(height: 16.h),
          ],
          _VisibleTestCasesSection(controller: controller),
        ],
      );
    });
  }
}

class _ExerciseMetaCard extends StatelessWidget {
  const _ExerciseMetaCard({required this.controller, required this.exercise});

  final ExerciseController controller;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MetaChip(
                icon: controller.isCoding ? Icons.code : Icons.radio_button_checked,
                label: controller.isCoding ? '编程题' : '单选题',
              ),
              _MetaChip(
                icon: Icons.cloud_done_outlined,
                label: controller.lastSavedLabel,
              ),
            ],
          ),
          if (controller.draftRestored.value) ...[
            SizedBox(height: 12.h),
            Text(
              '已恢复你上次保存的草稿。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExercisePromptCard extends StatelessWidget {
  const _ExercisePromptCard({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
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
            _SimpleMarkdownBody(markdown: prompt),
          ],
        ),
      ),
    );
  }
}

class _SingleChoiceSection extends StatelessWidget {
  const _SingleChoiceSection({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedKey = controller.selectedChoiceKey.value;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
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
            ...controller.choiceOptions.map(
              (option) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ChoiceOptionTile(
                  option: option,
                  isSelected: option.key == selectedKey,
                  onTap: () => controller.selectChoice(option.key),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceOptionTile extends StatelessWidget {
  const _ChoiceOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ExerciseChoiceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
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
                option.key,
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
                option.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodingWorkspaceSection extends StatelessWidget {
  const _CodingWorkspaceSection({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
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
                Obx(
                  () => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ExerciseWorkspaceTab.values.map((tab) {
                      final selected = controller.activeTab.value == tab;
                      return ChoiceChip(
                        label: Text(tab.label),
                        selected: selected,
                        onSelected: (_) => controller.switchTab(tab),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  switch (controller.activeTab.value) {
                    case ExerciseWorkspaceTab.code:
                      return _CodeEditorPanel(controller: controller);
                    case ExerciseWorkspaceTab.preview:
                      return _PreviewPanel(code: controller.currentCode);
                    case ExerciseWorkspaceTab.run:
                      return _RunPanel(controller: controller);
                    case ExerciseWorkspaceTab.highlight:
                      return SyntaxHighlighter(
                        code: controller.currentCode,
                        language: 'html',
                        showLineNumbers: true,
                      );
                  }
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeEditorPanel extends StatelessWidget {
  const _CodeEditorPanel({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
            minLines: 14,
            maxLines: 22,
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
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '实时预览',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '以下是你代码的实时渲染效果：',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        if (code.trim().isEmpty)
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                '请输入代码以查看预览',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          CodePreviewWebView(htmlCode: code),
      ],
    );
  }
}

class _RunPanel extends StatelessWidget {
  const _RunPanel({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '运行检查',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: controller.runPreview,
                icon: const Icon(Icons.play_arrow),
                label: const Text('运行'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            controller.runSummary.value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _VisibleTestCasesSection extends StatelessWidget {
  const _VisibleTestCasesSection({required this.controller});

  final ExerciseController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = controller.exercise.value;
    final testCases = exercise?.testCases ?? const <ExerciseTestCase>[];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '公开测试用例',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '这里只展示 learner 可见的公开信息，不会暴露隐藏断言或答案。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),
            ...testCases.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _TestCaseTile(testCase: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCaseTile extends StatelessWidget {
  const _TestCaseTile({required this.testCase});

  final ExerciseTestCase testCase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  testCase.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${testCase.weight} 分',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '类型：${testCase.type}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (testCase.inputPayload != null && testCase.inputPayload!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '公开输入：${testCase.inputPayload}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: colorScheme.onSurfaceVariant),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleMarkdownBody extends StatelessWidget {
  const _SimpleMarkdownBody({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final theme = Theme.of(context);
    final widgets = <Widget>[];
    var inCodeBlock = false;
    final codeBuffer = <String>[];

    void flushCodeBlock() {
      if (codeBuffer.isEmpty) {
        return;
      }

      widgets.add(
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 12.h),
          child: CodeBlock(
            code: codeBuffer.join('\n'),
            language: 'html',
          ),
        ),
      );
      codeBuffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          flushCodeBlock();
        }
        inCodeBlock = !inCodeBlock;
        continue;
      }

      if (inCodeBlock) {
        codeBuffer.add(rawLine);
        continue;
      }

      if (line.isEmpty) {
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              line.substring(3),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              line.substring(2),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h, right: 8.w),
                  child: Icon(Icons.circle, size: 6.sp),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            line,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      );
    }

    if (codeBuffer.isNotEmpty) {
      flushCodeBlock();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

enum ExerciseWorkspaceTab { code, preview, run, highlight }

extension ExerciseWorkspaceTabLabel on ExerciseWorkspaceTab {
  String get label {
    switch (this) {
      case ExerciseWorkspaceTab.code:
        return '代码';
      case ExerciseWorkspaceTab.preview:
        return '预览';
      case ExerciseWorkspaceTab.run:
        return '运行';
      case ExerciseWorkspaceTab.highlight:
        return '高亮';
    }
  }
}

class ExerciseController extends BaseController {
  ExerciseController();

  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxString exerciseId = ''.obs;
  final Rx<Exercise?> exercise = Rx<Exercise?>(null);
  final RxList<ExerciseChoiceOption> choiceOptions = <ExerciseChoiceOption>[].obs;
  final RxString selectedChoiceKey = ''.obs;
  final Rx<ExerciseWorkspaceTab> activeTab = ExerciseWorkspaceTab.code.obs;
  final Rxn<SubmissionResult> latestSubmission = Rxn<SubmissionResult>();
  final RxBool isSubmitting = false.obs;
  final RxBool isRequestingAiHelp = false.obs;
  final RxBool draftRestored = false.obs;
  final RxString runSummary = '点击"运行"后可先做一次本地预检查。'.obs;
  final Rxn<DateTime> lastSavedAt = Rxn<DateTime>();

  final TextEditingController codeController = TextEditingController();

  Timer? _draftDebounce;
  bool _isHydratingDraft = false;

  bool get isCoding => exercise.value?.type == 'coding';
  bool get isSingleChoice => exercise.value?.type == 'single_choice';

  String get exerciseTitle => exercise.value?.title ?? '练习';

  String get currentCode => codeController.text;

  String get lastSavedLabel {
    final savedAt = lastSavedAt.value;
    if (savedAt == null) {
      return '草稿未保存';
    }

    final hour = savedAt.hour.toString().padLeft(2, '0');
    final minute = savedAt.minute.toString().padLeft(2, '0');
    return '已保存 $hour:$minute';
  }

  String get _draftStorageKey => 'exercise_draft_${exerciseId.value}';

  @override
  void onInit() {
    super.onInit();
    exerciseId.value = Get.parameters['id'] ?? '';
    codeController.addListener(_onCodeChanged);

    if (exerciseId.value.isEmpty) {
      setError(message: '练习ID缺失。');
      return;
    }

    loadExercise();
  }

  @override
  void onClose() {
    _draftDebounce?.cancel();
    codeController.removeListener(_onCodeChanged);
    codeController.dispose();
    super.onClose();
  }

  Future<void> loadExercise() async {
    setLoading(message: '加载练习中...');
    registerRetry(loadExercise);

    try {
      final response = await _apiService.get('/learner/exercises/${exerciseId.value}');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (data.isEmpty) {
        setEmpty(message: '练习数据不可用。');
        return;
      }

      final item = Exercise.fromDetailJson(data);
      exercise.value = item;
      choiceOptions.assignAll(_buildChoiceOptions(item));
      await _restoreDraft(item);

      if (item.type == 'coding' && item.testCases.isEmpty) {
        setEmpty(message: '暂无可用的测试用例。');
        return;
      }

      if (item.type == 'single_choice' && item.options.isEmpty) {
        setEmpty(message: '暂无可用的选项。');
        return;
      }

      resetState();
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else {
        _loadMockExercise();
      }
    } catch (_) {
      _loadMockExercise();
    }
  }

  void _loadMockExercise() {
    final normalizedId = exerciseId.value.toLowerCase();
    final isSingleChoiceMock = normalizedId.contains('single') ||
        normalizedId.contains('choice') ||
        exerciseId.value == 'mock-exercise-002';

    if (isSingleChoiceMock) {
      _loadMockSingleChoiceExercise();
      return;
    }

    _loadMockCodingExercise();
  }

  void _loadMockCodingExercise() {
    final mockExercise = Exercise(
      id: exerciseId.value.isNotEmpty ? exerciseId.value : 'mock-exercise-001',
      type: 'coding',
      title: 'CSS 类选择器练习',
      description: '请使用 CSS 类选择器将 class 为 "highlight" 的元素背景色设置为黄色。\n\n要求：\n1. 使用类选择器（.highlight）\n2. 设置背景色为黄色（background-color: yellow）\n3. 保持其他样式不变',
      codeTemplate: '.highlight {\n    /* 请在此编写你的 CSS 代码 */\n}',
      testCases: const [
        ExerciseTestCase(
          id: 'tc-001',
          type: 'visible',
          name: '示例 1：基本类选择器',
          weight: 50,
          inputPayload: {
            'selector': '.highlight',
            'property': 'background-color',
            'value': 'yellow',
          },
        ),
        ExerciseTestCase(
          id: 'tc-002',
          type: 'visible',
          name: '示例 2：多元素选择',
          weight: 50,
          inputPayload: {
            'selector': '.highlight',
            'elements': ['div', 'span', 'p'],
          },
        ),
      ],
    );

    exercise.value = mockExercise;
    choiceOptions.assignAll(_buildChoiceOptions(mockExercise));
    selectedChoiceKey.value = '';
    codeController.text = mockExercise.codeTemplate ?? '';
    draftRestored.value = false;
    resetState();
  }

  void _loadMockSingleChoiceExercise() {
    final mockExercise = Exercise(
      id: exerciseId.value.isNotEmpty ? exerciseId.value : 'mock-exercise-002',
      type: 'single_choice',
      title: 'HTML 基础概念',
      description: '以下哪个标签用于定义 HTML 文档的根元素？',
      options: const [
        ExerciseChoiceOption(key: 'A', text: '<html>'),
        ExerciseChoiceOption(key: 'B', text: '<body>'),
        ExerciseChoiceOption(key: 'C', text: '<head>'),
        ExerciseChoiceOption(key: 'D', text: '<div>'),
      ],
    );

    exercise.value = mockExercise;
    choiceOptions.assignAll(_buildChoiceOptions(mockExercise));
    selectedChoiceKey.value = '';
    codeController.clear();
    draftRestored.value = false;
    resetState();
  }

  Future<void> _mockSubmitResult() async {
    final isCorrect = isSingleChoice
        ? selectedChoiceKey.value == 'A'
        : currentCode.contains('.highlight') && currentCode.contains('yellow');
    final result = SubmissionResult(
      score: isCorrect ? 100 : 0,
      passedCases: isCorrect ? 2 : 0,
      totalCases: 2,
      feedback: isCorrect
          ? '状态：passed。Mock 评测已通过，当前答案满足兜底规则。'
          : '状态：failed。单选题正确答案为 A；编程题需同时包含 .highlight 和 yellow。',
      aiHelp: _buildLearnerSafeAiHelp(passed: isCorrect),
    );

    latestSubmission.value = result;
    await _openSubmissionResultSheet(result);
  }

  List<ExerciseChoiceOption> _buildChoiceOptions(Exercise item) {
    if (item.type != 'single_choice') {
      return const <ExerciseChoiceOption>[];
    }

    return item.options;
  }

  Future<void> _restoreDraft(Exercise item) async {
    draftRestored.value = false;
    _isHydratingDraft = true;

    final draft = _storageService.read<Map<dynamic, dynamic>>(_draftStorageKey);
    final draftMap = draft?.map((key, value) => MapEntry(key.toString(), value));
    final savedAtRaw = draftMap?['savedAt']?.toString();
    if (savedAtRaw != null) {
      lastSavedAt.value = DateTime.tryParse(savedAtRaw);
    }

    if (item.type == 'coding') {
      final storedCode = draftMap?['code']?.toString();
      codeController.text = storedCode?.isNotEmpty == true
          ? storedCode!
          : (item.codeTemplate ?? '');
      draftRestored.value = storedCode?.isNotEmpty == true;
    } else {
      final storedChoice = draftMap?['selectedChoice']?.toString() ?? '';
      selectedChoiceKey.value = storedChoice;
      draftRestored.value = storedChoice.isNotEmpty;
    }

    _isHydratingDraft = false;
  }

  void _onCodeChanged() {
    if (!isCoding || _isHydratingDraft) {
      return;
    }

    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 500), saveDraft);
  }

  void switchTab(ExerciseWorkspaceTab tab) {
    activeTab.value = tab;
  }

  Future<void> selectChoice(String key) async {
    selectedChoiceKey.value = key;
    await saveDraft();
  }

  void runPreview() {
    final visibleCount = exercise.value?.testCases.length ?? 0;
    final codeLength = currentCode.trim().length;
    runSummary.value = codeLength == 0
        ? '预检查未通过：请先补充代码，再运行公开用例预检查。'
        : '本地预检查已完成：已准备 $visibleCount 条公开用例，代码长度 $codeLength 字符。';
  }

  Future<void> saveDraft() async {
    try {
      final payload = <String, dynamic>{
        'savedAt': DateTime.now().toIso8601String(),
      };

      if (isCoding) {
        payload['code'] = currentCode;
      }
      if (isSingleChoice) {
        payload['selectedChoice'] = selectedChoiceKey.value;
      }

      await _storageService.write(_draftStorageKey, payload);
      lastSavedAt.value = DateTime.tryParse(payload['savedAt'] as String);
    } catch (_) {
      // Keep learner flow uninterrupted even if local persistence fails.
    }
  }

  Future<void> submit() async {
    if (isCoding && currentCode.trim().isEmpty) {
      Get.snackbar(
        '无法提交',
        '请输入代码后再提交。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (isSingleChoice && selectedChoiceKey.value.isEmpty) {
      Get.snackbar(
        '无法提交',
        '请先选择一个选项。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;
    await saveDraft();

    try {
      final body = <String, dynamic>{
        'exercise_id': exerciseId.value,
        'source_code': isCoding ? currentCode : selectedChoiceKey.value,
      };

      final response = await _apiService.post('/learner/submissions', data: body);
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final result = SubmissionResult.fromContracts(submission: data);
      latestSubmission.value = result;
      await _openSubmissionResultSheet(result);
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await setAuthExpired(message: '登录状态已失效，请重新登录。');
      } else {
        await _mockSubmitResult();
      }
    } catch (_) {
      await _mockSubmitResult();
    } finally {
      isSubmitting.value = false;
    }
  }

  AIHelp _buildLearnerSafeAiHelp({required bool passed}) {
    if (passed) {
      return const AIHelp(
        requestType: 'hint',
        status: 'succeeded',
        content: '你已经通过公开用例了。继续前，快速复查命名是否清晰、结构是否语义化。',
      );
    }

    if (isSingleChoice) {
      return const AIHelp(
        requestType: 'hint',
        status: 'succeeded',
        content: '回到题干，先找"面向 learner 的正确做法"这一类描述，再排除会泄露答案或破坏结构的选项。',
      );
    }

    return const AIHelp(
      requestType: 'error_explanation',
      status: 'succeeded',
      content: '先别重写全部代码。先检查最外层结构是否存在，再确认公开用例里提到的选择器是否真的出现在代码中。',
    );
  }

  /// Generate context-aware fallback hints when AI service is unavailable.
  /// Produces safe, directional hints that never reveal answers.
  AIHelp _generateFallbackHint(String hintLevel) {
    final submission = latestSubmission.value;
    final passed = submission != null &&
        submission.passedCases == submission.totalCases;
    final failedCount = submission != null
        ? submission.totalCases - submission.passedCases
        : 0;
    final testCases = exercise.value?.testCases ?? const <ExerciseTestCase>[];
    final userCode = codeController.text.trim();
    final exerciseType = exercise.value?.type ?? '';

    // Analyze user code for specific patterns
    final codeAnalysis = _analyzeUserCode(userCode, exerciseType);

    String content;

    switch (hintLevel) {
      case 'error_location':
        content = _buildErrorLocationHint(
          passed: passed,
          failedCount: failedCount,
          testCases: testCases,
          codeAnalysis: codeAnalysis,
          userCode: userCode,
        );
        break;
      case 'correction_hint':
        content = _buildCorrectionHint(
          passed: passed,
          isSingleChoice: isSingleChoice,
          codeAnalysis: codeAnalysis,
          userCode: userCode,
        );
        break;
      case 'operation_suggestion':
      default:
        content = _buildOperationSuggestion(
          passed: passed,
          isSingleChoice: isSingleChoice,
          failedCount: failedCount,
          codeAnalysis: codeAnalysis,
          userCode: userCode,
        );
        break;
    }

    return AIHelp(
      requestType: hintLevel,
      status: 'succeeded',
      content: content,
    );
  }

  /// Analyze user code to detect common patterns and issues
  Map<String, dynamic> _analyzeUserCode(String code, String exerciseType) {
    final analysis = <String, dynamic>{
      'isEmpty': code.isEmpty,
      'isSingleChoice': exerciseType == 'single_choice',
      'hasSelector': false,
      'hasProperty': false,
      'hasValue': false,
      'selectorType': 'none', // class, id, tag, attribute, pseudo
      'commonMistakes': <String>[],
      'codeLength': code.length,
      'hasComments': code.contains('//') || code.contains('/*'),
      'hasSemicolon': code.contains(';'),
      'hasBraces': code.contains('{') && code.contains('}'),
    };

    if (code.isEmpty) return analysis;

    // Check for CSS selectors
    if (code.contains('.')) {
      analysis['hasSelector'] = true;
      analysis['selectorType'] = 'class';
    } else if (code.contains('#')) {
      analysis['hasSelector'] = true;
      analysis['selectorType'] = 'id';
    } else if (code.contains('[') && code.contains(']')) {
      analysis['hasSelector'] = true;
      analysis['selectorType'] = 'attribute';
    } else if (code.contains(':')) {
      analysis['hasSelector'] = true;
      analysis['selectorType'] = 'pseudo';
    }

    // Check for CSS properties
    final cssProperties = [
      'background-color', 'color', 'margin', 'padding',
      'border', 'display', 'flex', 'grid', 'width', 'height',
      'font-size', 'text-align', 'position', 'top', 'left',
    ];
    for (final prop in cssProperties) {
      if (code.contains(prop)) {
        analysis['hasProperty'] = true;
        break;
      }
    }

    // Check for CSS values
    if (code.contains('px') || code.contains('rem') || code.contains('em') ||
        code.contains('#') || code.contains('rgb') || code.contains('yellow') ||
        code.contains('red') || code.contains('blue') || code.contains('green')) {
      analysis['hasValue'] = true;
    }

    // Detect common mistakes
    if (!analysis['hasSelector'] && !analysis['isSingleChoice']) {
      analysis['commonMistakes'].add('missing_selector');
    }
    if (!analysis['hasProperty'] && !analysis['isSingleChoice']) {
      analysis['commonMistakes'].add('missing_property');
    }
    if (!analysis['hasValue'] && analysis['hasProperty']) {
      analysis['commonMistakes'].add('missing_value');
    }
    if (!analysis['hasBraces'] && !analysis['isSingleChoice'] && code.isNotEmpty) {
      analysis['commonMistakes'].add('missing_braces');
    }
    if (!analysis['hasSemicolon'] && analysis['hasProperty'] && !analysis['isSingleChoice']) {
      analysis['commonMistakes'].add('missing_semicolon');
    }

    return analysis;
  }

  String _buildErrorLocationHint({
    required bool passed,
    required int failedCount,
    required List<ExerciseTestCase> testCases,
    required Map<String, dynamic> codeAnalysis,
    required String userCode,
  }) {
    if (passed) {
      return '✅ 所有公开用例已通过！\n\n'
          '如果仍有隐藏用例失败，可能是：\n'
          '• 边界条件处理（如空值、特殊字符）\n'
          '• 命名规范（语义化类名、BEM命名）\n'
          '• 浏览器兼容性（前缀、属性支持）\n'
          '• 响应式适配（不同屏幕尺寸）';
    }

    if (codeAnalysis['isSingleChoice']) {
      return '🔍 请重新审题\n\n'
          '重点关注：\n'
          '• 题干中的"必须"、"不能"、"应该"等关键词\n'
          '• 选项中的细节差异（属性值、顺序、大小写）\n'
          '• 干扰项通常在某个细节上不符合要求\n\n'
          '排除法：先排除明显错误的选项';
    }

    if (codeAnalysis['isEmpty']) {
      return '📝 代码编辑区为空\n\n'
          '请先编写代码，然后点击"提交"按钮。\n'
          '系统会自动检测并给出针对性提示。';
    }

    final buffer = StringBuffer();
    buffer.writeln('🔍 错误定位分析');
    buffer.writeln('');

    if (codeAnalysis['commonMistakes'].contains('missing_selector')) {
      buffer.writeln('❌ 缺少CSS选择器');
      buffer.writeln('   → 请添加类选择器(.class)、ID选择器(#id)或标签选择器');
      buffer.writeln('');
    }

    if (codeAnalysis['commonMistakes'].contains('missing_property')) {
      buffer.writeln('❌ 缺少CSS属性');
      buffer.writeln('   → 请添加background-color、color、margin等属性');
      buffer.writeln('');
    }

    if (codeAnalysis['commonMistakes'].contains('missing_value')) {
      buffer.writeln('❌ 缺少属性值');
      buffer.writeln('   → 请为CSS属性设置具体值（如 yellow、#fff、10px）');
      buffer.writeln('');
    }

    if (codeAnalysis['commonMistakes'].contains('missing_braces')) {
      buffer.writeln('❌ 缺少花括号 {}');
      buffer.writeln('   → CSS选择器需要用花括号包裹属性声明');
      buffer.writeln('');
    }

    if (codeAnalysis['commonMistakes'].contains('missing_semicolon')) {
      buffer.writeln('⚠️ 缺少分号');
      buffer.writeln('   → CSS属性值后面需要添加分号 ;');
      buffer.writeln('');
    }

    if (codeAnalysis['commonMistakes'].isEmpty && failedCount > 0) {
      buffer.writeln('检测到 $failedCount 个测试用例未通过。');
      buffer.writeln('');
      buffer.writeln('可能的问题：');
      buffer.writeln('• 选择器与目标元素不匹配');
      buffer.writeln('• 属性名拼写错误');
      buffer.writeln('• 属性值不正确');
      buffer.writeln('');
    }

    if (testCases.isNotEmpty) {
      buffer.writeln('📋 测试用例要求：');
      for (final tc in testCases.take(3)) {
        buffer.writeln('• ${tc.name}');
      }
      if (testCases.length > 3) {
        buffer.writeln('• ...等共 ${testCases.length} 个用例');
      }
    }

    return buffer.toString();
  }

  String _buildCorrectionHint({
    required bool passed,
    required bool isSingleChoice,
    required Map<String, dynamic> codeAnalysis,
    required String userCode,
  }) {
    if (passed) {
      return '✅ 代码已通过公开用例！\n\n'
          '可进一步优化：\n'
          '• 命名语义化（使用有意义的类名）\n'
          '• 代码复用（提取公共样式）\n'
          '• 响应式适配（媒体查询）\n'
          '• 浏览器兼容性（前缀处理）';
    }

    if (codeAnalysis['isSingleChoice']) {
      return '💡 单选题解题技巧\n\n'
          '1. 仔细阅读题干，圈出关键词\n'
          '2. 逐一对比每个选项\n'
          '3. 排除明显错误的选项\n'
          '4. 关注选项中的细节差异\n'
          '5. 选择最符合题意的答案\n\n'
          '常见陷阱：\n'
          '• 选项A和B可能只差一个单词\n'
          '• 注意"不"、"不能"等否定词';
    }

    if (codeAnalysis['isEmpty']) {
      return '📝 开始编写代码\n\n'
          '对于CSS练习，建议：\n'
          '1. 先写出选择器（如 .highlight）\n'
          '2. 添加花括号 {}\n'
          '3. 在花括号内写属性和值\n\n'
          '示例结构：\n'
          '.selector {\n'
          '    property: value;\n'
          '}';
    }

    final buffer = StringBuffer();
    buffer.writeln('🔧 修正建议');
    buffer.writeln('');

    if (codeAnalysis['selectorType'] == 'none') {
      buffer.writeln('选择器问题：');
      buffer.writeln('• 类选择器：.className { }');
      buffer.writeln('• ID选择器：#idName { }');
      buffer.writeln('• 标签选择器：div { }');
      buffer.writeln('');
    }

    if (codeAnalysis['hasSelector'] && !codeAnalysis['hasProperty']) {
      buffer.writeln('属性问题：');
      buffer.writeln('• 背景色：background-color: yellow;');
      buffer.writeln('• 文字颜色：color: red;');
      buffer.writeln('• 边距：margin: 10px;');
      buffer.writeln('');
    }

    if (codeAnalysis['hasProperty'] && !codeAnalysis['hasValue']) {
      buffer.writeln('属性值问题：');
      buffer.writeln('• 颜色值：#fff, rgb(255,255,255), yellow');
      buffer.writeln('• 尺寸值：10px, 1rem, 50%');
      buffer.writeln('');
    }

    buffer.writeln('代码检查清单：');
    buffer.writeln('□ 选择器是否正确匹配目标元素？');
    buffer.writeln('□ 属性名是否拼写正确？');
    buffer.writeln('□ 属性值是否符合要求？');
    buffer.writeln('□ 是否添加了分号？');
    buffer.writeln('□ 花括号是否配对？');

    return buffer.toString();
  }

  String _buildOperationSuggestion({
    required bool passed,
    required bool isSingleChoice,
    required int failedCount,
    required Map<String, dynamic> codeAnalysis,
    required String userCode,
  }) {
    if (passed) {
      return '🎉 恭喜！代码已通过\n\n'
          '后续优化建议：\n'
          '1. 检查代码可读性，变量和类名是否有意义\n'
          '2. 确认没有冗余代码或重复样式\n'
          '3. 考虑响应式适配（媒体查询）\n'
          '4. 检查浏览器兼容性（前缀）\n'
          '5. 提交后观察是否有隐藏用例通过';
    }

    if (codeAnalysis['isSingleChoice']) {
      return '📋 单选题操作步骤\n\n'
          '1. 仔细阅读题目，理解要求\n'
          '2. 在纸上画出关键词\n'
          '3. 逐一对比每个选项\n'
          '4. 排除明显错误的选项\n'
          '5. 选择最符合题意的答案\n'
          '6. 点击"提交"查看反馈\n\n'
          '提示：不确定时先提交，系统会给出反馈';
    }

    if (codeAnalysis['isEmpty']) {
      return '🚀 开始编写代码\n\n'
          '步骤：\n'
          '1. 在代码编辑器中输入CSS代码\n'
          '2. 先写选择器（如 .highlight）\n'
          '3. 添加花括号 {}\n'
          '4. 在花括号内写属性和值\n'
          '5. 点击"提交"查看结果\n\n'
          '提示：可以参考题目中的示例代码';
    }

    final buffer = StringBuffer();
    buffer.writeln('📝 操作建议');
    buffer.writeln('');

    if (failedCount > 0) {
      buffer.writeln('当前状态：$failedCount 个测试用例未通过');
      buffer.writeln('');
    }

    buffer.writeln('执行步骤：');
    buffer.writeln('1. 对照测试用例要求，逐个检查代码');
    buffer.writeln('2. 从选择器开始，确保匹配目标元素');
    buffer.writeln('3. 检查属性名是否正确（注意拼写）');
    buffer.writeln('4. 验证属性值是否符合要求');
    buffer.writeln('5. 修改后点击"提交"查看结果');
    buffer.writeln('');

    if (codeAnalysis['codeLength'] < 20) {
      buffer.writeln('💡 建议：代码较短，可能需要补充更多内容');
    } else if (codeAnalysis['codeLength'] > 200) {
      buffer.writeln('💡 建议：代码较长，检查是否有冗余部分');
    }

    buffer.writeln('');
    buffer.writeln('调试技巧：');
    buffer.writeln('• 使用浏览器开发者工具检查元素');
    buffer.writeln('• 在控制台查看CSS属性是否生效');
    buffer.writeln('• 尝试简化代码，逐步添加功能');

    return buffer.toString();
  }

  Future<void> openAiHelpSheet() async {
    isRequestingAiHelp.value = true;

    try {
      final help = await _requestAiHelp();
      if (Get.context == null) {
        return;
      }

      await showModalBottomSheet<void>(
        context: Get.context!,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => AIHelpSheet(
          aiHelp: help,
          exerciseTitle: exerciseTitle,
        ),
      );
    } finally {
      isRequestingAiHelp.value = false;
    }
  }

  Future<AIHelp> _requestAiHelp() async {
    try {
      final body = <String, dynamic>{
        'request_type': 'hint',
        'source_code': currentCode,
      };

      if (exerciseId.value.isNotEmpty) {
        body['exercise_id'] = exerciseId.value;
      }

      final response = await _apiService
          .post('/learner/ai/help', data: body)
          .timeout(const Duration(seconds: 10));

      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return AIHelp.fromContract(data);
    } on TimeoutException {
      return _generateFallbackHint('hint');
    } catch (e) {
      if (e is dio.DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          return _generateFallbackHint('hint');
        }
      }
      return _generateFallbackHint('hint');
    }
  }

  Future<void> _openSubmissionResultSheet(SubmissionResult result) async {
    if (Get.context == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SubmissionResultSheet(
        result: result,
        onContinue: () {
          Navigator.of(Get.context!).pop();
          Get.back<void>();
        },
        onViewAiHelp: () async {
          Navigator.of(Get.context!).pop();
          await openAiHelpSheet();
        },
      ),
    );
  }
}

class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExerciseController>(() => ExerciseController());
  }
}
