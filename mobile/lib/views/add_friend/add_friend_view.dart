import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/shared/empty_state.dart';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

class AddFriendView extends GetView<AddFriendController> {
  const AddFriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友'),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Obx(() => _buildBody(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: '搜索昵称...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.searchQuery.value.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: '搜索好友',
        description: '输入昵称查找其他学习者并添加为好友。',
      );
    }

    if (controller.isSearching.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final results = controller.searchResults;

    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.person_search_outlined,
        title: '未找到用户',
        description: '未找到与"${controller.searchQuery.value}"匹配的用户，请尝试其他关键词。',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final user = results[index];
        return _UserResultCard(
          user: user,
          isRequestSent: controller.isRequestSent(user.id),
          onAddFriend: () => controller.sendFriendRequest(user.id),
        );
      },
    );
  }
}

class _UserResultCard extends StatelessWidget {
  const _UserResultCard({
    required this.user,
    required this.isRequestSent,
    required this.onAddFriend,
  });

  final User user;
  final bool isRequestSent;
  final VoidCallback onAddFriend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      user.nickname.isNotEmpty
                          ? user.nickname[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontSize: 16.sp),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '等级 ${user.level}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isRequestSent)
              Chip(
                label: const Text('已发送'),
                avatar: const Icon(Icons.check, size: 16),
                backgroundColor: colorScheme.primaryContainer,
                side: BorderSide.none,
              )
            else
              FilledButton(
                onPressed: onAddFriend,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  minimumSize: Size(0, 36.h),
                ),
                child: const Text('添加'),
              ),
          ],
        ),
      ),
    );
  }
}

class AddFriendController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  /// Tracks locally sent friend request IDs for immediate UI feedback.
  final Set<String> _sentRequestIds = <String>{};

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<User> searchResults = <User>[].obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchControllerChanged);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchControllerChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchControllerChanged() {
    onSearchChanged(searchController.text);
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    isSearching.value = true;

    try {
      final response = await _apiService.get('/learner/friends', queryParameters: {'q': query});
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final results = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => User(
                id: (item['account_id'] ?? item['id'] ?? '').toString(),
                email: '',
                nickname: (item['nickname'] ?? '').toString(),
                avatar: item['avatar_url'] as String?,
                level: _asInt(item['level'] ?? item['current_level'], fallback: 1),
                xp: _asInt(item['xp'] ?? item['total_xp']),
                streak: _asInt(item['streak'] ?? item['streak_days']),
                dailyGoal: _asInt(item['daily_goal_minutes'], fallback: 30),
                themeMode: (item['theme_mode'] ?? 'system').toString(),
              ))
          .toList();
      searchResults.assignAll(results);
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  bool isRequestSent(String userId) {
    // Track sent requests locally for immediate UI feedback
    return _sentRequestIds.contains(userId);
  }

  Future<void> sendFriendRequest(String userId) async {
    try {
      await _apiService.post('/learner/friends/requests', data: {
        'friend_id': userId,
      });
      _sentRequestIds.add(userId);
      Get.snackbar(
        '好友请求已发送',
        '等待对方接受您的好友请求。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      // Refresh UI to show "sent" state
      searchResults.refresh();
    } catch (e) {
      Get.snackbar(
        '发送失败',
        '无法发送好友请求，请稍后重试。',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }
}

class AddFriendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddFriendController>(() => AddFriendController());
  }
}
