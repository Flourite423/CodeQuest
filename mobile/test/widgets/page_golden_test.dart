import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:codequest/controllers/base_controller.dart';
import 'package:codequest/models/models.dart' as app_models;
import 'package:codequest/services/api_service.dart';
import 'package:codequest/services/storage_service.dart';
import 'package:codequest/views/challenge/challenge_list_view.dart';
import 'package:codequest/views/course/course_list_view.dart';
import 'package:codequest/views/home/home_dashboard_view.dart';
import 'package:codequest/views/profile/profile_view.dart';
import 'package:codequest/views/social/social_view.dart';
import 'package:codequest/widgets/shared/empty_state.dart';
import 'package:codequest/widgets/shared/error_state.dart';
import 'package:codequest/widgets/shared/loading_state.dart';

class _FakeStorageService extends StorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip GetStorage initialization in tests
  }

  @override
  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  T? read<T>(String key) {
    return _data[key] as T?;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  bool hasKey(String key) {
    return _data.containsKey(key);
  }

  @override
  Future<void> clearAuthSession() async {
    _data.remove(StorageService.authTokenKey);
  }

  @override
  String? readAuthToken() {
    return read<String>(StorageService.authTokenKey);
  }
}

app_models.User _withoutAvatar(app_models.User user) {
  return app_models.User(
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    avatar: null,
    level: user.level,
    xp: user.xp,
    streak: user.streak,
    bio: user.bio,
    dailyGoal: user.dailyGoal,
    themeMode: user.themeMode,
  );
}

app_models.Course _withoutCover(app_models.Course course) {
  return app_models.Course(
    id: course.id,
    title: course.title,
    summary: course.summary,
    difficulty: course.difficulty,
    estimatedMinutes: course.estimatedMinutes,
    progress: course.progress,
    chapters: course.chapters,
    description: course.description,
    coverImageUrl: null,
    category: course.category,
  );
}

app_models.Badge _withoutBadgeIcon(app_models.Badge badge) {
  return app_models.Badge(
    id: badge.id,
    name: badge.name,
    description: badge.description,
    icon: null,
    earnedAt: badge.earnedAt,
  );
}

app_models.Activity _withoutActivityAvatar(app_models.Activity activity) {
  return app_models.Activity(
    id: activity.id,
    type: activity.type,
    description: activity.description,
    timestamp: activity.timestamp,
    user: app_models.ActivityUser(
      id: activity.user.id,
      nickname: activity.user.nickname,
      avatar: null,
    ),
  );
}

app_models.Friend _withoutFriendAvatar(app_models.Friend friend) {
  return app_models.Friend(
    id: friend.id,
    nickname: friend.nickname,
    avatar: null,
    level: friend.level,
    status: friend.status,
  );
}

class _TestHomeDashboardController extends HomeDashboardController {
  _TestHomeDashboardController() : super();

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip auto-loading in tests
    registerRetry(loadDashboardData);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = 'Loading dashboard...';
  }

  void setLoadedState() {
    user.value = _withoutAvatar(_testUser());
    stats.value = _testStats();
    dailyChallenge.value = _testDailyChallenge();
    continueCourse.value = _withoutCover(_testCourse(includeChapters: true));
    activities.assignAll(
      _testActivities(count: 3).map(_withoutActivityAvatar),
    );
    badges.assignAll(
      _testBadges(count: 2).map(_withoutBadgeIcon),
    );
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }
}

class _TestCourseListController extends CourseListController {
  _TestCourseListController() : super();

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip auto-loading in tests
    registerRetry(loadCourses);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = '加载课程中...';
  }

  void setLoadedState() {
    courses.value = _testCourses(count: 3)
        .map(_withoutCover)
        .toList();
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }

  void setEmptyState() {
    courses.clear();
    pageState.value = PageState.empty;
    stateMessage.value = '暂无可用课程。';
  }

  void setErrorState() {
    courses.clear();
    pageState.value = PageState.error;
    stateMessage.value = '加载课程失败，请重试。';
  }
}

class _TestChallengeListController extends ChallengeListController {
  _TestChallengeListController() : super();

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip auto-loading in tests
    registerRetry(loadChallenges);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = '加载挑战中...';
  }

  void setLoadedState() {
    challenges.assignAll(_testChallenges(count: 4));
    challengeStars.assignAll(<String, int>{
      for (final challenge in challenges) challenge.id: challenge.stars,
    });
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }
}

class _TestSocialController extends SocialController {
  _TestSocialController() : super();

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip auto-loading in tests
    registerRetry(loadAllData);
  }

  void setLoadedState() {
    activities.assignAll(
      _testActivities(count: 3).map(_withoutActivityAvatar),
    );
    friends.assignAll(
      _testFriends(count: 4).map(_withoutFriendAvatar),
    );
    leaderboard.assignAll(_testLeaderboardEntries(count: 6));
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }

  void setEmptyState() {
    activities.clear();
    friends.clear();
    leaderboard.clear();
    pageState.value = PageState.empty;
    stateMessage.value = '暂无动态。';
  }
}

class _TestProfileController extends ProfileController {
  _TestProfileController() : super();

  @override
  // ignore: must_call_super
  void onInit() {
    // Skip auto-loading in tests
    registerRetry(loadProfileData);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = '加载个人资料中...';
  }

  void setLoadedState() {
    user.value = _withoutAvatar(_testUser());
    stats.value = _testStats();
    badges.assignAll(
      _testBadges(count: 2).map(_withoutBadgeIcon),
    );
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }
}

Widget buildGoldenApp(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) {
      return GetMaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2DD4A0),
          brightness: Brightness.light,
        ),
        home: home,
      );
    },
  );
}

Future<void> _pumpPhoneSized(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
  await tester.pump();
}

void _expectNoFlutterErrors(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

const _goldenPath = '../goldens';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}


// ==================== Test Data Factories ====================
// These replace the MockDataService builder methods that were used before.

app_models.User _testUser({int seed = 1}) {
  return app_models.User(
    id: 'user-$seed',
    email: 'learner$seed@example.com',
    nickname: '学习者 $seed',
    avatar: 'https://example.com/avatar/$seed.png',
    level: 4 + seed,
    xp: 1200 * seed,
    streak: 2 + seed,
    bio: '每天都在稳步提升前端技能。',
    dailyGoal: 30 + seed * 5,
    themeMode: seed.isEven ? 'dark' : 'system',
  );
}

app_models.Stats _testStats({int seed = 1}) {
  return app_models.Stats(
    studyTime: 240 + seed * 30,
    coursesCompleted: 2 + seed,
    challengesWon: 1 + seed,
    currentStreak: 3 + seed,
    totalXp: 1400 + seed * 500,
    mastery: 0.55 + seed * 0.05,
  );
}

app_models.DailyChallenge _testDailyChallenge({int seed = 1}) {
  return app_models.DailyChallenge(
    id: 'daily-$seed',
    title: '每日挑战 $seed',
    description: '在倒计时结束前完成一个小型编码任务。',
    timeLimit: 900 + seed * 60,
    isAttempted: seed.isEven,
    isExpired: seed > 2,
  );
}

app_models.Chapter _testChapter({int seed = 1}) {
  return app_models.Chapter(
    id: 'chapter-$seed',
    title: '章节 $seed',
    content: '# 章节 $seed\n\n本章介绍学习者友好的 Markdown 内容。',
    sampleCode: '<section>章节 $seed 示例</section>',
    summary: '核心概念 $seed 总结',
    isCompleted: seed == 1,
    isLocked: seed > 2,
  );
}

app_models.Course _testCourse({int seed = 1, bool includeChapters = true}) {
  final chapters = includeChapters
      ? [for (var i = 1; i <= 3; i++) _testChapter(seed: i)]
      : <app_models.Chapter>[];
  return app_models.Course(
    id: 'course-$seed',
    title: '前端基础 $seed',
    summary: '循序渐进学习布局、样式和交互基础。',
    difficulty: seed.isEven ? 'intermediate' : 'beginner',
    estimatedMinutes: 90 + seed * 10,
    progress: 0.2 * seed,
    chapters: chapters,
    description: '课程 $seed 的契约对齐学习者课程详情模拟数据。',
    coverImageUrl: 'https://example.com/course/$seed.png',
    category: 'frontend',
  );
}

List<app_models.Course> _testCourses({int count = 3}) {
  return [for (var i = 1; i <= count; i++) _testCourse(seed: i, includeChapters: false)];
}

app_models.Challenge _testChallenge({int seed = 1}) {
  return app_models.Challenge(
    id: 'challenge-$seed',
    title: '挑战 $seed',
    description: '完成一系列学习任务来赢取星星。',
    tasks: [
      app_models.ChallengeTask(id: 'task-$seed-1', title: '完成阶段 1', isCompleted: seed == 1),
      app_models.ChallengeTask(id: 'task-$seed-2', title: '完成阶段 2', isCompleted: false),
      app_models.ChallengeTask(id: 'task-$seed-3', title: '完成阶段 3', isCompleted: false),
    ],
    stars: seed % 4,
    reward: seed * 150,
    isCompleted: seed == 1,
  );
}

List<app_models.Challenge> _testChallenges({int count = 4}) {
  return [for (var i = 1; i <= count; i++) _testChallenge(seed: i)];
}

app_models.ActivityUser _testActivityUser({int seed = 1}) {
  return app_models.ActivityUser(
    id: 'activity-user-$seed',
    nickname: '用户 $seed',
    avatar: 'https://example.com/peer/$seed.png',
  );
}

app_models.Activity _testActivity({int seed = 1}) {
  final types = ['challenge_completed', 'badge_earned', 'streak_reached', 'course_completed'];
  return app_models.Activity(
    id: 'activity-$seed',
    type: types[seed % 4],
    description: '完成了一个可见的学习里程碑 #$seed。',
    timestamp: DateTime.now().subtract(Duration(hours: seed * 3)),
    user: _testActivityUser(seed: seed),
  );
}

List<app_models.Activity> _testActivities({int count = 3}) {
  return [for (var i = 1; i <= count; i++) _testActivity(seed: i)];
}

app_models.Badge _testBadge({int seed = 1}) {
  return app_models.Badge(
    id: 'badge-$seed',
    name: '徽章 $seed',
    description: '因持续学习进步而授予。',
    icon: 'https://example.com/badge/$seed.png',
    earnedAt: DateTime.now().subtract(Duration(days: seed * 2)),
  );
}

List<app_models.Badge> _testBadges({int count = 2}) {
  return [for (var i = 1; i <= count; i++) _testBadge(seed: i)];
}

app_models.Friend _testFriend({int seed = 1}) {
  return app_models.Friend(
    id: 'friend-$seed',
    nickname: '好友 $seed',
    avatar: 'https://example.com/friend/$seed.png',
    level: 3 + seed,
    status: seed.isEven ? 'pending' : 'accepted',
  );
}

List<app_models.Friend> _testFriends({int count = 4}) {
  return [for (var i = 1; i <= count; i++) _testFriend(seed: i)];
}

app_models.LeaderboardEntry _testLeaderboardEntry({int seed = 1}) {
  return app_models.LeaderboardEntry(
    rank: seed,
    userId: 'leader-$seed',
    nickname: '榜首 $seed',
    level: (10 - seed) < 1 ? 1 : 10 - seed,
    xp: 8000 - seed * 400,
  );
}

List<app_models.LeaderboardEntry> _testLeaderboardEntries({int count = 6}) {
  return [for (var i = 1; i <= count; i++) _testLeaderboardEntry(seed: i)];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<ApiService>(ApiService());
    Get.put<StorageService>(_FakeStorageService());
  });

  tearDown(() {
    Get.reset();
  });

  group('Shared state goldens', () {
    testWidgets('empty state matches golden reference', (tester) async {
      await _pumpPhoneSized(
        tester,
        buildGoldenApp(
          const Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nothing here',
              description: 'Content will appear when available.',
              actionLabel: 'Refresh',
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/shared_empty_state.png'),
      );
    });

    testWidgets('error state matches golden reference', (tester) async {
      await _pumpPhoneSized(
        tester,
        buildGoldenApp(
          Scaffold(
            body: ErrorState(
              message: 'Network error occurred.',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('重试'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/shared_error_state.png'),
      );
    });

    testWidgets('loading state matches golden reference', (tester) async {
      await _pumpPhoneSized(
        tester,
        buildGoldenApp(
          const Scaffold(
            body: LoadingState(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/shared_loading_state.png'),
      );
    });
  });

  group('Representative page widget states', () {
    testWidgets('home dashboard renders loading and loaded states', (
      tester,
    ) async {
      final controller = _TestHomeDashboardController();
      Get.put<HomeDashboardController>(controller);

      controller.setLoadingState();
      await _pumpPhoneSized(tester, buildGoldenApp(const HomeDashboardView()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('今日成长'), findsOneWidget);
      expect(find.text('每日挑战'), findsOneWidget);
      expect(find.text('继续学习'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });

    testWidgets('course list renders loading, loaded, empty and error states', (
      tester,
    ) async {
      final controller = _TestCourseListController();
      Get.put<CourseListController>(controller);

      controller.setLoadingState();
      await _pumpPhoneSized(tester, buildGoldenApp(const CourseListView()));
      expect(find.text('加载课程中...'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump();
      expect(find.text('前端基础 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setEmptyState();
      await tester.pump();
      expect(find.text('暂无课程'), findsOneWidget);
      expect(find.text('刷新'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setErrorState();
      await tester.pump();
      expect(find.text('出了点问题'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });

    testWidgets('challenge list renders loading and loaded states', (
      tester,
    ) async {
      final controller = _TestChallengeListController();
      Get.put<ChallengeListController>(controller);

      controller.setLoadingState();
      await _pumpPhoneSized(tester, buildGoldenApp(const ChallengeListView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump();
      expect(find.text('挑战地图'), findsOneWidget);
      expect(find.text('挑战 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });

    testWidgets('social page renders loaded activity, friends and leaderboard tabs', (
      tester,
    ) async {
      final controller = _TestSocialController();
      Get.put<SocialController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const SocialView()));
      expect(find.text('社交中心'), findsOneWidget);
      expect(find.text('用户 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      await tester.tap(find.text('好友'));
      await tester.pumpAndSettle();
      expect(find.textContaining('好友请求'), findsOneWidget);
      expect(find.text('接受'), findsWidgets);
      _expectNoFlutterErrors(tester);

      await tester.tap(find.text('排行榜'));
      await tester.pumpAndSettle();
      expect(find.text('榜首 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });

    testWidgets('profile page renders loading and loaded states', (tester) async {
      final controller = _TestProfileController();
      Get.put<ProfileController>(controller);

      controller.setLoadingState();
      await _pumpPhoneSized(tester, buildGoldenApp(const ProfileView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump();
      expect(find.text('统计数据'), findsOneWidget);
      expect(find.text('快捷入口'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });
  });

  group('Representative page goldens', () {
    testWidgets('home dashboard loaded state matches golden reference', (
      tester,
    ) async {
      final controller = _TestHomeDashboardController();
      Get.put<HomeDashboardController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const HomeDashboardView()));

      expect(find.text('今日成长'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/home_dashboard_loaded.png'),
      );
    });

    testWidgets('course list loaded state matches golden reference', (
      tester,
    ) async {
      final controller = _TestCourseListController();
      Get.put<CourseListController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const CourseListView()));

      expect(find.text('前端基础 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/course_list_loaded.png'),
      );
    });

    testWidgets('challenge list loaded state matches golden reference', (
      tester,
    ) async {
      final controller = _TestChallengeListController();
      Get.put<ChallengeListController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const ChallengeListView()));

      expect(find.text('挑战 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/challenge_list_loaded.png'),
      );
    });

    testWidgets('social page loaded state matches golden reference', (
      tester,
    ) async {
      final controller = _TestSocialController();
      Get.put<SocialController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const SocialView()));

      expect(find.text('动态'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/social_activity_loaded.png'),
      );
    });

    testWidgets('profile page loaded state matches golden reference', (
      tester,
    ) async {
      final controller = _TestProfileController();
      Get.put<ProfileController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const ProfileView()));

      expect(find.text('最近徽章'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/profile_loaded.png'),
      );
    });
  });
}
