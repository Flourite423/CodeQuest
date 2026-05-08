import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';

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
          primaryLabel: controller.isCompleted.value ? 'Go to Exercise' : 'Complete Learning',
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
                  if (chapter.sampleCode != null && chapter.sampleCode!.isNotEmpty) ...[
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
            color: isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Completed' : 'In Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isCompleted
                      ? 'You have completed this chapter. Practice with exercises!'
                      : 'Read through the content and mark as complete when ready.',
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

    for (final line in lines) {
      final trimmed = line.trim();
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

      // Code block
      if (trimmed.startsWith('```')) {
        if (currentParagraph != null && currentParagraph.isNotEmpty) {
          blocks.add(_MarkdownBlock(
            type: _BlockType.paragraph,
            content: currentParagraph.toString().trim(),
          ));
          currentParagraph = null;
        }
        continue;
      }

      // Regular paragraph line
      currentParagraph ??= StringBuffer();
      if (currentParagraph.isNotEmpty) {
        currentParagraph.write(' ');
      }
      currentParagraph.write(trimmed);
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
        }
      }).toList(),
    );
  }
}

enum _BlockType { heading1, heading2, heading3, bullet, paragraph }

class _MarkdownBlock {
  const _MarkdownBlock({required this.type, required this.content});

  final _BlockType type;
  final String content;
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
              'Sample Code',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'monospace',
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
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
                'Key Takeaway',
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
  final MockDataService _mockDataService = Get.find<MockDataService>();
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<Chapter?> chapter = Rx<Chapter?>(null);
  final RxString chapterId = ''.obs;
  final RxBool isCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    chapterId.value = Get.parameters['id'] ?? '';
    if (chapterId.value.isNotEmpty) {
      loadChapter();
    } else {
      setError(message: 'Chapter ID is missing.');
    }
  }

  Future<void> loadChapter() async {
    setLoading(message: 'Loading chapter...');
    registerRetry(loadChapter);

    try {
      final result = await _mockDataService.fetchCourse();
      if (result == null) {
        setEmpty(message: 'Chapter not found.');
        return;
      }

      // Find the chapter by ID from the course
      final foundChapter = result.chapters.firstWhereOrNull(
        (c) => c.id == chapterId.value,
      );

      if (foundChapter == null) {
        setEmpty(message: 'Chapter not found.');
        return;
      }

      chapter.value = foundChapter;
      isCompleted.value = foundChapter.isCompleted;

      // Check if user has previously marked this chapter as completed in storage
      final completedKey = 'chapter_completed_${chapterId.value}';
      final storedCompleted = _storageService.read<bool>(completedKey);
      if (storedCompleted == true) {
        isCompleted.value = true;
      }

      pageState.value = PageState.initial;
    } on MockDataException catch (e) {
      setError(message: e.message);
    } catch (e) {
      setError(message: 'Failed to load chapter. Please try again.');
    }
  }

  void onPrimaryCTA() {
    if (isCompleted.value) {
      _goToExercise();
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
            const Text('Complete Chapter?'),
          ],
        ),
        content: const Text(
          'Mark this chapter as completed? You will unlock exercises and the next chapter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              markChapterComplete();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Future<void> markChapterComplete() async {
    try {
      // Persist completion state
      final completedKey = 'chapter_completed_${chapterId.value}';
      await _storageService.write(completedKey, true);

      isCompleted.value = true;

      Get.snackbar(
        'Chapter Completed',
        'Great job! Exercises and the next chapter are now unlocked.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
      );
    } catch (e) {
      setError(message: 'Failed to save progress. Please try again.');
    }
  }

  void _goToExercise() {
    Get.toNamed('/exercise/${chapterId.value}');
  }
}

class ChapterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChapterController>(() => ChapterController());
  }
}
