import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/mock_data.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/cta_bar.dart';

class CourseDetailView extends GetView<CourseController> {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          message: controller.stateMessage.value,
          onRetry: controller.retry,
          child: _CourseContent(controller: controller),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.course.value == null) return const SizedBox.shrink();
        final nextChapter = controller.nextUncompletedChapter;
        if (nextChapter == null) return const SizedBox.shrink();

        return CTABar(
          primaryLabel: '继续学习',
          onPrimary: () => controller.openChapter(nextChapter),
        );
      }),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.controller});

  final CourseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final course = controller.course.value;
      if (course == null) {
        return const SizedBox.shrink();
      }

      return CustomScrollView(
        slivers: [
          // Hero cover image with back button
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _CoverImage(course: course),
            ),
          ),
          // Course info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CourseHeader(course: course),
                  SizedBox(height: 16.h),
                  if (course.description != null && course.description!.isNotEmpty) ...[
                    Text(
                      course.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  _ProgressOverview(course: course),
                  SizedBox(height: 24.h),
                  Text(
                    '章节',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
          // Chapter list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final chapter = course.chapters[index];
                return _ChapterTile(
                  chapter: chapter,
                  index: index,
                  onTap: () => controller.onChapterTap(chapter, index),
                );
              },
              childCount: course.chapters.length,
            ),
          ),
          // Bottom padding for CTA
          SliverToBoxAdapter(
            child: SizedBox(height: 80.h),
          ),
        ],
      );
    });
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primaryContainer,
      child: course.coverImageUrl != null
          ? Image.network(
              course.coverImageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _FallbackCover(colorScheme: colorScheme);
              },
            )
          : _FallbackCover(colorScheme: colorScheme),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.book,
        size: 80.sp,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course});

  final Course course;

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _MetaChip(
              icon: Icons.signal_cellular_alt,
              label: _capitalize(course.difficulty),
            ),
            SizedBox(width: 8.w),
            _MetaChip(
              icon: Icons.schedule,
              label: _formatDuration(course.estimatedMinutes),
            ),
            if (course.chapters.isNotEmpty) ...[
              SizedBox(width: 8.w),
              _MetaChip(
                icon: Icons.menu_book,
                label: '${course.chapters.length} 章节',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = course.progress ?? 0.0;
    final completedChapters = course.chapters.where((c) => c.isCompleted).length;
    final totalChapters = course.chapters.length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '进度',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          if (totalChapters > 0) ...[
            SizedBox(height: 8.h),
            Text(
              '已完成 $completedChapters / $totalChapters 章节',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  final Chapter chapter;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isLocked = chapter.isLocked;
    final bool isCompleted = chapter.isCompleted;

    IconData trailingIcon;
    Color? trailingColor;

    if (isCompleted) {
      trailingIcon = Icons.check_circle;
      trailingColor = colorScheme.primary;
    } else if (isLocked) {
      trailingIcon = Icons.lock;
      trailingColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    } else {
      trailingIcon = Icons.play_circle_outline;
      trailingColor = colorScheme.primary;
    }

    return Card(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      elevation: isLocked ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: isLocked ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 56.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Chapter number or status icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? colorScheme.primaryContainer
                      : isLocked
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 18.sp,
                          color: colorScheme.primary,
                        )
                      : Text(
                          '${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                : colorScheme.primary,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              // Chapter info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (chapter.summary.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        chapter.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLocked
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing icon
              Icon(
                trailingIcon,
                color: trailingColor,
                size: 24.sp,
              ),
            ],
          ),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseController extends BaseController {
  final MockDataService _mockDataService = Get.find<MockDataService>();

  ProgressService get _progressService {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  final Rx<Course?> course = Rx<Course?>(null);
  final RxString courseId = ''.obs;

  Chapter? get nextUncompletedChapter {
    final chapters = course.value?.chapters ?? [];
    for (final chapter in chapters) {
      if (!chapter.isCompleted && !chapter.isLocked) {
        return chapter;
      }
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    courseId.value = Get.parameters['id'] ?? '';
    if (courseId.value.isNotEmpty) {
      loadCourse();
    } else {
      setError(message: '课程ID缺失。');
    }
  }

  Future<void> loadCourse() async {
    if (!_progressService.isOnline.value) {
      final cachedCourse = _progressService.getCachedCourse(courseId.value);
      if (cachedCourse != null) {
        course.value = _progressService.applyCourseProgress(cachedCourse);
        setPartialData(message: '当前为离线模式，已显示本地缓存的课程内容。');
        return;
      }
    }

    setLoading(message: '加载课程中...');
    registerRetry(loadCourse);

    try {
      final result = await _mockDataService.fetchCourse();
      if (result == null) {
        setEmpty(message: '未找到课程。');
        return;
      }

      final courseWithProgress = _progressService.applyCourseProgress(result);
      await _progressService.cacheCourse(courseWithProgress);
      course.value = courseWithProgress;

      pageState.value = PageState.initial;
    } on MockDataException catch (e) {
      setError(message: e.message);
    } catch (e) {
      setError(message: '加载课程失败，请重试。');
    }
  }

  void onChapterTap(Chapter chapter, int index) {
    if (chapter.isLocked) {
      _showLockedChapterDialog(chapter, index);
      return;
    }

    openChapter(chapter);
  }

  void _showLockedChapterDialog(Chapter chapter, int index) {
    final previousIndex = index - 1;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock,
              color: Theme.of(Get.context!).colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            const Text('章节已锁定'),
          ],
        ),
        content: Text(
          previousIndex >= 0
              ? '完成"${course.value?.chapters[previousIndex].title ?? '上一章节'}"以解锁此章节。'
              : '此章节已锁定。完成前面的章节以解锁。',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void openChapter(Chapter chapter) {
    Get.toNamed('/chapter/${chapter.id}', parameters: <String, String>{
      'courseId': courseId.value,
    });
  }
}

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseController>(() => CourseController());
  }
}
