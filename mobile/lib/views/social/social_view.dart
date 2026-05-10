import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/base_controller.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/list_card.dart';
import '../../widgets/shared/rank_row.dart';

class SocialView extends GetView<SocialController> {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('社交中心'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '动态'),
              Tab(text: '好友'),
              Tab(text: '排行榜'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActivityTab(controller: controller),
            _FriendsTab(controller: controller),
            _LeaderboardTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class SocialController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<Friend> friends = <Friend>[].obs;
  final RxList<LeaderboardEntry> leaderboard = <LeaderboardEntry>[].obs;

  String currentUserId = '';

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadActivities(),
      loadFriends(),
      loadLeaderboard(),
      loadCurrentUserId(),
    ]);
  }

  Future<void> loadCurrentUserId() async {
    try {
      final response = await _apiService.get('/me');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      currentUserId = (data['id'] ?? '').toString();
    } catch (_) {
      // Non-critical, leaderboard highlight will be disabled
    }
  }

  Future<void> loadActivities() async {
    try {
      final response = await _apiService.get('/learner/activities');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => Activity.fromContract(Map<String, dynamic>.from(item)))
          .toList();
      activities.value = items;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        activities.value = <Activity>[];
      } else {
        activities.value = <Activity>[];
      }
    } catch (e) {
      activities.value = <Activity>[];
    }
  }

  Future<void> loadFriends() async {
    try {
      final response = await _apiService.get('/learner/friends');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) => Friend.fromContract(Map<String, dynamic>.from(item)))
          .toList();
      friends.value = items;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        friends.value = <Friend>[];
      } else {
        friends.value = <Friend>[];
      }
    } catch (e) {
      friends.value = <Friend>[];
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      final response = await _apiService.get('/learner/leaderboards');
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((item) =>
              LeaderboardEntry.fromContract(Map<String, dynamic>.from(item)))
          .toList();
      leaderboard.value = items;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        leaderboard.value = <LeaderboardEntry>[];
      } else {
        leaderboard.value = <LeaderboardEntry>[];
      }
    } catch (e) {
      leaderboard.value = <LeaderboardEntry>[];
    }
  }

  void acceptFriendRequest(String friendId) {
    final index = friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final friend = friends[index];
      friends[index] = Friend(
        id: friend.id,
        nickname: friend.nickname,
        avatar: friend.avatar,
        level: friend.level,
        status: 'accepted',
      );
    }
  }

  void declineFriendRequest(String friendId) {
    friends.removeWhere((f) => f.id == friendId);
  }
}

class SocialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialController>(() => SocialController());
  }
}

// ─── Activity Tab ───────────────────────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.controller});

  final SocialController controller;

  IconData _activityIcon(String type) {
    switch (type) {
      case 'challenge_completed':
        return Icons.flag_outlined;
      case 'badge_earned':
        return Icons.workspace_premium_outlined;
      case 'streak_reached':
        return Icons.local_fire_department_outlined;
      case 'course_completed':
        return Icons.book_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${diff.inDays ~/ 7}周前';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.activities;

      if (items.isEmpty) {
        return const EmptyState(
          icon: Icons.notifications_none_outlined,
          title: '暂无动态',
          description: '好友的动态将显示在这里。',
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final activity = items[index];
          return ListCard(
            leading: CircleAvatar(
              radius: 20.r,
              backgroundImage: activity.user.avatar != null
                  ? NetworkImage(activity.user.avatar!)
                  : null,
              child: activity.user.avatar == null
                  ? Text(
                      activity.user.nickname.isNotEmpty
                          ? activity.user.nickname[0].toUpperCase()
                          : '?',
                      style: TextStyle(fontSize: 14.sp),
                    )
                  : null,
            ),
            title: activity.user.nickname,
            subtitle: '${activity.description} · ${_timeAgo(activity.timestamp)}',
            trailing: Icon(
              _activityIcon(activity.type),
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      );
    });
  }
}

// ─── Friends Tab ────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({required this.controller});

  final SocialController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allFriends = controller.friends;
      final pendingFriends =
          allFriends.where((f) => f.status == 'pending').toList();
      final acceptedFriends =
          allFriends.where((f) => f.status == 'accepted').toList();

      return ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Add friend button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton.icon(
              onPressed: () => Get.toNamed('/add-friend'),
              icon: const Icon(Icons.person_add),
              label: const Text('添加好友'),
            ),
          ),
          SizedBox(height: 16.h),

          if (allFriends.isEmpty) ...[
            EmptyState(
              icon: Icons.people_outline,
              title: '暂无好友',
              description: '与其他学习者建立联系，他们将显示在这里。',
              actionLabel: '添加好友',
              onAction: () => Get.toNamed('/add-friend'),
            ),
          ],

          if (allFriends.isNotEmpty) ...[
            // Pending requests section
            if (pendingFriends.isNotEmpty) ...[
              Text(
                '好友请求 (${pendingFriends.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 12.h),
              ...pendingFriends.map((friend) => _FriendRequestCard(
                    friend: friend,
                    onAccept: () => controller.acceptFriendRequest(friend.id),
                    onDecline: () => controller.declineFriendRequest(friend.id),
                  )),
              SizedBox(height: 24.h),
            ],

            // Accepted friends section
            if (acceptedFriends.isNotEmpty) ...[
              Text(
                '好友',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 12.h),
              ...acceptedFriends.map((friend) => _FriendCard(friend: friend)),
            ],
          ],
        ],
      );
    });
  }
}

class _FriendRequestCard extends StatelessWidget {
  const _FriendRequestCard({
    required this.friend,
    required this.onAccept,
    required this.onDecline,
  });

  final Friend friend;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage:
                      friend.avatar != null ? NetworkImage(friend.avatar!) : null,
                  child: friend.avatar == null
                      ? Text(
                          friend.nickname.isNotEmpty
                              ? friend.nickname[0].toUpperCase()
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
                        friend.nickname,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (friend.level != null)
                        Text(
                          '等级 ${friend.level}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    minimumSize: Size(0, 36.h),
                  ),
                  child: const Text('拒绝'),
                ),
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    minimumSize: Size(0, 36.h),
                  ),
                  child: const Text('接受'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage:
            friend.avatar != null ? NetworkImage(friend.avatar!) : null,
        child: friend.avatar == null
            ? Text(
                friend.nickname.isNotEmpty
                    ? friend.nickname[0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 14.sp),
              )
            : null,
      ),
      title: friend.nickname,
      subtitle: friend.level != null ? '等级 ${friend.level}' : null,
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () => Get.toNamed('/friends'),
      ),
    );
  }
}

// ─── Leaderboard Tab ────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.controller});

  final SocialController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.leaderboard;

      if (entries.isEmpty) {
        return const EmptyState(
          icon: Icons.emoji_events_outlined,
          title: '暂无排名',
          description: '学习者开始竞争后，排行榜将可用。',
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: entries.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return RankRow(
            rank: entry.rank,
            username: entry.nickname,
            level: entry.level ?? 1,
            xp: entry.xp,
            avatarUrl: null,
            isCurrentUser: entry.userId == controller.currentUserId,
          );
        },
      );
    });
  }
}
