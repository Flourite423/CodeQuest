import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart' hide Badge;
import '../../services/api_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/page_state_host.dart';
import '../../widgets/shared/filter_sheet.dart';

class CourseListView extends GetView<CourseListController> {
  const CourseListView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('课程'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => controller.toggleSearch(),
          ),
          Obx(() => IconButton(
            icon: Badge(
              isLabelVisible: controller.hasActiveCourseFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => controller.showCourseFilterSheet(),
          )),
        ],
      ),
      body: Obx(() {
        return PageStateHost(
          state: controller.pageState.value,
          message: controller.stateMessage.value,
          onRetry: controller.retry,
          emptyTitle: '暂无课程',
          emptyDescription: '课程将在可用时显示于此。',
          emptyIcon: Icons.school_outlined,
          child: Column(
            children: [
              if (controller.isSearchActive.value) _SearchBar(controller: controller),
              Expanded(child: _CourseList(controller: controller)),
            ],
          ),
        );
      }),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final CourseListController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: '搜索课程...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.searchController.clear();
              controller.onSearchChanged('');
            },
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.controller});

  final CourseListController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final courses = controller.filteredCourses;

      if (courses.isEmpty) {
        final hasActiveFilters = controller.hasActiveCourseFilters;
        final hasSearch = controller.searchQuery.value.isNotEmpty;

        if (hasSearch || hasActiveFilters) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSearch ? Icons.search_off : Icons.filter_list_off,
                    size: 64.sp,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    hasSearch ? '无结果' : '无匹配课程',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    hasSearch
                        ? '尝试不同的搜索词。'
                        : '尝试调整筛选条件。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _CourseCard(course: course);
        },
      );
    });
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

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
    final colorScheme = theme.colorScheme;
    final progress = course.progress ?? 0.0;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/course/${course.id}'),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Container(
                height: 140.h,
                width: double.infinity,
                color: colorScheme.primaryContainer,
                child: course.coverImageUrl != null
                    ? Image.network(
                        course.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.book,
                              size: 48.sp,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.book,
                          size: 48.sp,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    course.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _MetaChip(
                        icon: Icons.signal_cellular_alt,
                        label: _capitalize(course.difficulty),
                      ),
                      _MetaChip(
                        icon: Icons.schedule,
                        label: _formatDuration(course.estimatedMinutes),
                      ),
                      if (progress > 0) ...[
                        _MetaChip(
                          icon: Icons.check_circle,
                          label: '${(progress * 100).toInt()}%',
                        ),
                      ],
                    ],
                  ),
                  if (progress > 0) ...[
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
      child: Wrap(
        spacing: 4.w,
        runSpacing: 4.h,
        crossAxisAlignment: WrapCrossAlignment.center,
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

class CourseListController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  ProgressService get _progressService {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }

  final RxList<Course> courses = <Course>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearchActive = false.obs;
  final TextEditingController searchController = TextEditingController();

  final RxString difficultyFilter = ''.obs;
  final RxString categoryFilter = ''.obs;
  final RxString progressFilter = ''.obs;

  bool get hasActiveCourseFilters =>
      difficultyFilter.value.isNotEmpty ||
      categoryFilter.value.isNotEmpty ||
      progressFilter.value.isNotEmpty;

  List<Course> get filteredCourses {
    var result = courses.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((course) {
        return course.title.toLowerCase().contains(query) ||
            course.summary.toLowerCase().contains(query);
      }).toList();
    }

    if (difficultyFilter.value.isNotEmpty) {
      result = result.where((c) => c.difficulty == difficultyFilter.value).toList();
    }

    if (categoryFilter.value.isNotEmpty) {
      result = result.where((c) => c.category == categoryFilter.value).toList();
    }

    if (progressFilter.value.isNotEmpty) {
      result = result.where((c) {
        final p = c.progress ?? 0.0;
        switch (progressFilter.value) {
          case 'not_started':
            return p <= 0.0;
          case 'in_progress':
            return p > 0.0 && p < 1.0;
          case 'completed':
            return p >= 1.0;
          default:
            return true;
        }
      }).toList();
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void showCourseFilterSheet() {
    final List<FilterSection> sections = _buildFilterSections();
    FilterSheet.show(
      title: '筛选课程',
      sections: sections,
      onApply: () {
        // Filters applied reactively via section onChanged callbacks.
      },
      onReset: resetCourseFilters,
    );
  }

  List<FilterSection> _buildFilterSections() {
    return [
      FilterSection(
        title: '难度',
        options: const [
          FilterOption(value: 'beginner', label: '初级'),
          FilterOption(value: 'intermediate', label: '中级'),
          FilterOption(value: 'advanced', label: '高级'),
        ],
        selectedValues: difficultyFilter.value.isNotEmpty
            ? {difficultyFilter.value}
            : <String>{},
        onChanged: (values) {
          difficultyFilter.value = values.isEmpty ? '' : values.first;
        },
        allowMultiple: false,
      ),
      FilterSection(
        title: '分类',
        options: const [
          FilterOption(value: 'frontend', label: '前端'),
          FilterOption(value: 'backend', label: '后端'),
          FilterOption(value: 'devops', label: '运维'),
          FilterOption(value: 'design', label: '设计'),
        ],
        selectedValues: categoryFilter.value.isNotEmpty
            ? {categoryFilter.value}
            : <String>{},
        onChanged: (values) {
          categoryFilter.value = values.isEmpty ? '' : values.first;
        },
        allowMultiple: false,
      ),
      FilterSection(
        title: '进度',
        options: const [
          FilterOption(value: 'not_started', label: '未开始'),
          FilterOption(value: 'in_progress', label: '进行中'),
          FilterOption(value: 'completed', label: '已完成'),
        ],
        selectedValues: progressFilter.value.isNotEmpty
            ? {progressFilter.value}
            : <String>{},
        onChanged: (values) {
          progressFilter.value = values.isEmpty ? '' : values.first;
        },
        allowMultiple: false,
      ),
    ];
  }

  void resetCourseFilters() {
    difficultyFilter.value = '';
    categoryFilter.value = '';
    progressFilter.value = '';
  }

  Future<void> loadCourses() async {
    if (!_progressService.isOnline.value) {
      final cachedCourses = _progressService.getCachedCourses();
      if (cachedCourses.isNotEmpty) {
        courses.value = _progressService.applyCourseProgressList(cachedCourses);
        setPartialData(message: '当前为离线模式，已显示本地缓存课程。');
        return;
      }
    }

    setLoading(message: '加载课程中...');
    registerRetry(loadCourses);

    try {
      final response = await _apiService.get('/learner/courses');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => Course.fromListItemJson(Map<String, dynamic>.from(item)))
          .toList();

      final withProgress = _progressService.applyCourseProgressList(items);
      await _progressService.cacheCourses(withProgress);
      courses.value = withProgress;

      if (items.isEmpty) {
        setEmpty(message: '暂无可用课程。');
      } else {
        resetState();
      }
    } on dio.DioException catch (e) {
      debugPrint('Failed to load courses: $e');
      setError(message: '加载课程失败，请重试。');
    } catch (e) {
      debugPrint('Failed to load courses: $e');
      setError(message: '加载课程失败，请重试。');
    }
  }
}

class CourseListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseListController>(() => CourseListController());
  }
}
