import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';
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
          emptyTitle: 'Exercise unavailable',
          emptyDescription: 'This exercise has no learner-safe content yet.',
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
              if (controller.isCoding)
                _MetaChip(
                  icon: Icons.save_outlined,
                  label: '离线草稿已启用',
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
              hintText: 'Write your learner-safe solution here...',
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
          Text(
            '预览',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '这里显示 learner 预览占位内容，提交前可先检查结构是否完整。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 160.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SelectableText(
              code.trim().isEmpty ? 'No preview available yet.' : code.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 6.w),
          Text(label),
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SelectableText(
            codeBuffer.join('\n'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              height: 1.5,
            ),
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

enum ExerciseWorkspaceTab { code, preview, run }

extension ExerciseWorkspaceTabLabel on ExerciseWorkspaceTab {
  String get label {
    switch (this) {
      case ExerciseWorkspaceTab.code:
        return '代码';
      case ExerciseWorkspaceTab.preview:
        return '预览';
      case ExerciseWorkspaceTab.run:
        return '运行';
    }
  }
}

class ExerciseChoiceOption {
  const ExerciseChoiceOption({required this.key, required this.text});

  final String key;
  final String text;
}

class ExerciseController extends BaseController {
  ExerciseController();

  final MockDataService _mockDataService = Get.find<MockDataService>();
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
  final RxString runSummary = '点击“运行”后可先做一次本地预检查。'.obs;
  final Rxn<DateTime> lastSavedAt = Rxn<DateTime>();

  final TextEditingController codeController = TextEditingController();

  Timer? _draftDebounce;
  bool _isHydratingDraft = false;

  bool get isCoding => exercise.value?.type == 'coding';
  bool get isSingleChoice => exercise.value?.type == 'single_choice';

  String get exerciseTitle => exercise.value?.title ?? 'Exercise';

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

  int get _seed {
    final match = RegExp(r'(\d+)').firstMatch(exerciseId.value);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  String get _correctChoiceKey {
    const keys = <String>['A', 'B', 'C', 'D'];
    return keys[(_seed - 1) % keys.length];
  }

  @override
  void onInit() {
    super.onInit();
    exerciseId.value = Get.parameters['id'] ?? '';
    codeController.addListener(_onCodeChanged);

    if (exerciseId.value.isEmpty) {
      setError(message: 'Exercise ID is missing.');
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
    setLoading(message: 'Loading exercise...');
    registerRetry(loadExercise);

    try {
      await Future<void>.delayed(MockDataService.defaultDelay);
      final item = _mockDataService.buildExercise(seed: _seed);
      exercise.value = item;
      choiceOptions.assignAll(_buildChoiceOptions(item));
      await _restoreDraft(item);

      if (item.testCases.isEmpty) {
        setEmpty(message: 'No visible test cases are available yet.');
        return;
      }

      resetState();
    } on MockDataException catch (error) {
      setError(message: error.message);
    } catch (_) {
      setError(message: 'Failed to load exercise. Please try again.');
    }
  }

  List<ExerciseChoiceOption> _buildChoiceOptions(Exercise item) {
    if (item.type != 'single_choice') {
      return const <ExerciseChoiceOption>[];
    }

    return const <ExerciseChoiceOption>[
      ExerciseChoiceOption(key: 'A', text: 'Use semantic structure so the learner layout stays readable.'),
      ExerciseChoiceOption(key: 'B', text: 'Rely only on visual spacing and skip structural tags.'),
      ExerciseChoiceOption(key: 'C', text: 'Hide the prompt inside comments so the UI stays clean.'),
      ExerciseChoiceOption(key: 'D', text: 'Expose hidden assertions to help the learner debug faster.'),
    ];
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
      await Future<void>.delayed(MockDataService.defaultDelay);
      final result = _buildSubmissionResult();
      latestSubmission.value = result;
      await _openSubmissionResultSheet(result);
    } finally {
      isSubmitting.value = false;
    }
  }

  SubmissionResult _buildSubmissionResult() {
    final totalCases = exercise.value?.testCases.length ?? 0;

    if (isSingleChoice) {
      final passed = selectedChoiceKey.value == _correctChoiceKey;
      return SubmissionResult(
        score: passed ? 100 : 40,
        passedCases: passed ? totalCases : (totalCases > 0 ? 1 : 0),
        totalCases: totalCases,
        feedback: passed
            ? '答题正确，继续下一步吧。'
            : '当前答案没有满足题目要求，请重新检查题目中的关键约束。',
        aiHelp: _buildLearnerSafeAiHelp(passed: passed),
      );
    }

    final trimmed = currentCode.trim();
    final containsStructure = trimmed.contains('<main') || trimmed.contains('<section');
    final containsStyle = trimmed.contains('display') || trimmed.contains('class=');
    final passedCases = [containsStructure, containsStyle, trimmed.length >= 40]
        .where((item) => item)
        .length
        .clamp(0, totalCases);
    final passed = totalCases == 0 ? trimmed.isNotEmpty : passedCases == totalCases;

    return SubmissionResult(
      score: passed ? 100 : 40 + passedCases * 20,
      passedCases: passed ? totalCases : passedCases,
      totalCases: totalCases,
      feedback: passed
          ? '公开用例全部通过，可以继续下一步。'
          : '还有公开用例未通过。优先检查结构层级、类名和基础样式是否完整。',
      aiHelp: _buildLearnerSafeAiHelp(passed: passed),
    );
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
        content: '回到题干，先找“面向 learner 的正确做法”这一类描述，再排除会泄露答案或破坏结构的选项。',
      );
    }

    return const AIHelp(
      requestType: 'error_explanation',
      status: 'succeeded',
      content: '先别重写全部代码。先检查最外层结构是否存在，再确认公开用例里提到的选择器是否真的出现在代码中。',
    );
  }

  Future<void> openAiHelpSheet() async {
    isRequestingAiHelp.value = true;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final help = latestSubmission.value?.aiHelp ?? _buildLearnerSafeAiHelp(passed: false);
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
