import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';
import '../../widgets/syntax_highlighter.dart';

class ChapterView extends GetView<ChapterController> {
  const ChapterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          message: controller.stateMessage.value,
          onRetry: controller.retry,
          child: _ChapterContent(controller: controller),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.chapter.value == null) return const SizedBox.shrink();
        return CTABar(
          primaryLabel: controller.isCompleted.value ? '前往练习' : '完成学习',
          onPrimary: () => controller.onPrimaryCTA(),
        );
      }),
    );
  }
}

class _ChapterContent extends StatelessWidget {
  const _ChapterContent({required this.controller});

  final ChapterController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chapter = controller.chapter.value;
      if (chapter == null) {
        return const SizedBox.shrink();
      }

      return CustomScrollView(
        slivers: [
          // App bar with chapter title and progress
          SliverAppBar(
            expandedHeight: 120.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                chapter.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          // Chapter content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _ProgressIndicator(
                    isCompleted: controller.isCompleted.value,
                  ),
                  SizedBox(height: 24.h),
                  // Markdown content
                  _MarkdownContent(content: chapter.content),
                  SizedBox(height: 24.h),
                  // Sample code card
                  if (chapter.sampleCode != null &&
                      chapter.sampleCode!.isNotEmpty) ...[
                    _SampleCodeCard(code: chapter.sampleCode!),
                    SizedBox(height: 24.h),
                  ],
                  // Knowledge summary card
                  _KnowledgeSummaryCard(summary: chapter.summary),
                  // Bottom padding for CTA
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? '已完成' : '进行中',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isCompleted ? '你已完成此章节。去练习吧！' : '阅读内容并在准备好后标记为完成。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.content});

  final String content;

  List<_MarkdownBlock> _parseMarkdown(String text) {
    final blocks = <_MarkdownBlock>[];
    final lines = text.split('\n');
    StringBuffer? currentParagraph;
    StringBuffer? currentCodeBlock;
    String? currentCodeLanguage;
    bool inCodeBlock = false;

    for (final line in lines) {
      final trimmed = line.trim();
      
      // Handle code block start/end
      if (trimmed.startsWith('```')) {
        if (inCodeBlock) {
          // End of code block
          if (currentCodeBlock != null && currentCodeBlock.isNotEmpty) {
            blocks.add(_MarkdownBlock(
              type: _BlockType.code,
              content: currentCodeBlock.toString(),
              language: currentCodeLanguage ?? 'html',
            ));
          }
          currentCodeBlock = null;
          currentCodeLanguage = null;
          inCodeBlock = false;
        } else {
          // Start of code block
          if (currentParagraph != null && currentParagraph.isNotEmpty) {
            blocks.add(_MarkdownBlock(
              type: _BlockType.paragraph,
              content: currentParagraph.toString().trim(),
            ));
            currentParagraph = null;
          }
          inCodeBlock = true;
          currentCodeBlock = StringBuffer();
          // Extract language from ```lang
          final lang = trimmed.substring(3).trim();
          if (lang.isNotEmpty) {
            currentCodeLanguage = lang;
          }
        }
        continue;
      }

      // If we're in a code block, collect lines
      if (inCodeBlock) {
        if (currentCodeBlock != null && currentCodeBlock.isNotEmpty) {
          currentCodeBlock.write('\n');
        }
        currentCodeBlock?.write(line);
        continue;
      }

      // Empty line
      if (trimmed.isEmpty) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        continue;
      }

      // Heading
      if (trimmed.startsWith('# ')) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        blocks.add(_MarkdownBlock(
          type: _BlockType.heading1,
          content: trimmed.substring(2),
        ));
        continue;
      }
      if (trimmed.startsWith('## ')) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        blocks.add(_MarkdownBlock(
          type: _BlockType.heading2,
          content: trimmed.substring(3),
        ));
        continue;
      }
      if (trimmed.startsWith('### ')) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        blocks.add(_MarkdownBlock(
          type: _BlockType.heading3,
          content: trimmed.substring(4),
        ));
        continue;
      }

      // Bullet list
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        blocks.add(_MarkdownBlock(
          type: _BlockType.bullet,
          content: trimmed.substring(2),
        ));
        continue;
      }

      // Regular paragraph line
      currentParagraph ??= StringBuffer();
      if (currentParagraph.isNotEmpty) {
        currentParagraph.write(' ');
      }
      currentParagraph.write(trimmed);
    }

    // Handle any remaining content
    if (inCodeBlock && currentCodeBlock != null && currentCodeBlock.isNotEmpty) {
      blocks.add(_MarkdownBlock(
        type: _BlockType.code,
        content: currentCodeBlock.toString(),
        language: currentCodeLanguage,
      ));
    }
    if (currentParagraph != null && currentParagraph.isNotEmpty) {
      blocks.add(_MarkdownBlock(
        type: _BlockType.paragraph,
        content: currentParagraph.toString().trim(),
      ));
    }

    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final blocks = _parseMarkdown(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        switch (block.type) {
          case _BlockType.heading1:
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                block.content,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          case _BlockType.heading2:
            return Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
              child: Text(
                block.content,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          case _BlockType.heading3:
            return Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: Text(
                block.content,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          case _BlockType.bullet:
            return Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      block.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case _BlockType.paragraph:
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                block.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            );
          case _BlockType.code:
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: CodeBlock(
                code: block.content,
                language: block.language ?? 'html',
              ),
            );
        }
      }).toList(),
    );
  }
}

enum _BlockType { heading1, heading2, heading3, bullet, paragraph, code }

class _MarkdownBlock {
  const _MarkdownBlock({
    required this.type,
    required this.content,
    this.language,
  });

  final _BlockType type;
  final String content;
  final String? language;
}

class _SampleCodeCard extends StatelessWidget {
  const _SampleCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.code,
              size: 20.sp,
              color: colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              '示例代码',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CodeBlock(
          code: code,
          language: 'html',
        ),
      ],
    );
  }
}

class _KnowledgeSummaryCard extends StatelessWidget {
  const _KnowledgeSummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20.sp,
                color: colorScheme.secondary,
              ),
              SizedBox(width: 8.w),
              Text(
                '关键要点',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  ProgressService get _progressService {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  final Rx<Chapter?> chapter = Rx<Chapter?>(null);
  final RxList<Exercise> exercises = <Exercise>[].obs;
  final RxString chapterId = ''.obs;
  final RxString courseId = ''.obs;
  final RxBool isCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    chapterId.value = Get.parameters['id'] ?? '';
    courseId.value = Get.parameters['courseId'] ?? '';

    // 从 URL query 参数读取 course_id（如从练习页返回时）
    if (courseId.value.isEmpty) {
      final uri = Uri.tryParse(Get.currentRoute);
      courseId.value = uri?.queryParameters['course_id'] ?? '';
    }

    // 如果路由参数中没有 courseId，尝试从缓存课程中查找包含此章节的课程
    if (courseId.value.isEmpty && chapterId.value.isNotEmpty) {
      final cachedCourses = _progressService.getCachedCourses();
      for (final course in cachedCourses) {
        if (course.chapters.any((ch) => ch.id == chapterId.value)) {
          courseId.value = course.id;
          break;
        }
      }
    }

    if (chapterId.value.isEmpty) {
      setError(message: '章节ID缺失。');
    } else if (courseId.value.isEmpty) {
      // 没有 courseId 时直接加载 mock 数据
      _loadMockChapter();
    } else {
      loadChapter();
    }
  }

  Future<void> loadChapter() async {
    if (!_progressService.isOnline.value) {
      final cachedCourse = _progressService.getCachedCourse(courseId.value);
      if (cachedCourse != null) {
        final offlineChapter = cachedCourse.chapters.firstWhereOrNull(
          (item) => item.id == chapterId.value,
        );
        if (offlineChapter != null) {
          chapter.value = offlineChapter;
          isCompleted.value = offlineChapter.isCompleted;
          setPartialData(message: '当前为离线模式，已加载本地章节内容。');
          return;
        }
      }
    }

    setLoading(message: '加载章节中...');
    registerRetry(loadChapter);

    try {
      final response =
          await _apiService.get('/learner/courses/${courseId.value}');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data =
          payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final result = Course.fromDetailJson(data);
      // Find the chapter by ID from the course
      final foundChapter = result.chapters.firstWhereOrNull(
        (c) => c.id == chapterId.value,
      );

      if (foundChapter == null) {
        setEmpty(message: '未找到章节。');
        return;
      }

      final processedCourse = _progressService.applyCourseProgress(result);
      await _progressService.cacheCourse(processedCourse);
      final processedChapter = processedCourse.chapters.firstWhereOrNull(
        (item) => item.id == chapterId.value,
      );

      if (processedChapter == null) {
        setEmpty(message: '未找到章节。');
        return;
      }

      chapter.value = processedChapter;
      isCompleted.value = processedChapter.isCompleted;

      pageState.value = PageState.initial;
    } catch (e) {
      _loadMockChapter();
    }
  }

  void _loadMockChapter() {
    final mockChapter = Chapter(
      id: chapterId.value.isNotEmpty ? chapterId.value : 'mock-chapter-001',
      title: 'Python 基础语法',
      content: '# Python 基础语法\n\n## 变量与数据类型\n\nPython 是一种动态类型语言，变量类型在运行时确定。\n\n```python\n# 变量赋值\nname = "CodeQuest"\nage = 18\nis_active = True\n\nprint(f"用户名: {name}, 年龄: {age}")\n```\n\n## 条件语句\n\n```python\nscore = 85\n\nif score >= 90:\n    grade = "A"\nelif score >= 80:\n    grade = "B"\nelse:\n    grade = "C"\n\nprint(f"成绩等级: {grade}")\n```\n\n## 循环结构\n\n```python\n# for 循环\nfor i in range(5):\n    print(f"第 {i+1} 次迭代")\n\n# while 循环\ncount = 0\nwhile count < 3:\n    print(f"计数: {count}")\n    count += 1\n```',
      sampleCode: 'def greet(name):\n    """\n    这是一个简单的问候函数\n    参数: name - 用户名\n    返回: 问候语\n    """\n    return f"你好, {name}! 欢迎来到 CodeQuest。"\n\n# 调用函数\nresult = greet("学习者")\nprint(result)',
      summary: '本章介绍了 Python 的基础语法，包括变量定义、条件语句和循环结构。',
      isCompleted: false,
      isLocked: false,
    );
    chapter.value = mockChapter;
    isCompleted.value = false;
    pageState.value = PageState.initial;
  }

  void onPrimaryCTA() async {
    if (isCompleted.value) {
      await _goToExercise();
    } else {
      _showCompleteConfirmation();
    }
  }

  void _showCompleteConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(Get.context!).colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            const Text('完成章节？'),
          ],
        ),
        content: const Text(
          '将此章节标记为已完成？你将解锁练习和下一章节。',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              markChapterComplete();
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Future<void> markChapterComplete() async {
    try {
      final cachedCourse = _progressService.getCachedCourse(courseId.value);
      final totalChapters = cachedCourse?.chapters.length ?? 0;
      final completedCount = cachedCourse?.chapters
              .where((item) => item.isCompleted || item.id == chapterId.value)
              .length ??
          1;
      final nextProgress =
          totalChapters > 0 ? completedCount / totalChapters : 1.0;

      await _progressService.saveChapterCompleted(
        chapterId: chapterId.value,
        courseId: courseId.value,
        courseProgress: nextProgress,
      );

      isCompleted.value = true;
      final current = chapter.value;
      if (current != null) {
        chapter.value = Chapter(
          id: current.id,
          title: current.title,
          content: current.content,
          sampleCode: current.sampleCode,
          summary: current.summary,
          isCompleted: true,
          isLocked: current.isLocked,
        );
      }

      Get.snackbar(
        '章节完成',
        '太棒了！练习和下一章节现在已解锁。',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      );
    } catch (e) {
      setError(message: '保存进度失败，请重试。');
    }
  }

  Future<void> _goToExercise() async {
    if (exercises.isEmpty) {
      await _loadExercises();
    }
    final firstExercise = exercises.firstOrNull;
    if (firstExercise != null) {
      Get.toNamed('/exercise/${firstExercise.id}', parameters: <String, String>{
        'courseId': courseId.value,
      });
    } else {
      Get.snackbar(
        '暂无练习',
        '该章节暂无练习内容。',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      );
    }
  }

  Future<void> _loadExercises() async {
    try {
      final response = await _apiService.get(
          '/learner/courses/${courseId.value}/chapters/${chapterId.value}/exercises');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final items = (payload['data'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => Exercise.fromListJson(Map<String, dynamic>.from(item)))
          .toList();
      exercises.assignAll(items);
    } catch (e) {
      debugPrint('ChapterController: Failed to load exercises: $e');
    }
  }
}

class ChapterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChapterController>(() => ChapterController());
  }
}
