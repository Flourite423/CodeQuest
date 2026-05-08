import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:learning_app_mobile/controllers/base_controller.dart';
import 'package:learning_app_mobile/models/models.dart' as app_models;
import 'package:learning_app_mobile/services/mock_data.dart';
import 'package:learning_app_mobile/services/storage_service.dart';
import 'package:learning_app_mobile/views/challenge/challenge_list_view.dart';
import 'package:learning_app_mobile/views/course/course_list_view.dart';
import 'package:learning_app_mobile/views/home/home_dashboard_view.dart';
import 'package:learning_app_mobile/views/profile/profile_view.dart';
import 'package:learning_app_mobile/views/social/social_view.dart';
import 'package:learning_app_mobile/widgets/shared/empty_state.dart';
import 'package:learning_app_mobile/widgets/shared/error_state.dart';
import 'package:learning_app_mobile/widgets/shared/loading_state.dart';

class _FakeStorageService extends StorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};

  @override
  void onInit() {}

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
  void onInit() {
    registerRetry(loadDashboardData);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = 'Loading dashboard...';
  }

  void setLoadedState() {
    final mock = Get.find<MockDataService>();
    user.value = _withoutAvatar(mock.buildUser());
    stats.value = mock.buildStats();
    dailyChallenge.value = mock.buildDailyChallenge();
    continueCourse.value = _withoutCover(mock.buildCourse(includeChapters: true));
    activities.assignAll(
      mock.buildActivities(count: 3).map(_withoutActivityAvatar),
    );
    badges.assignAll(
      mock.buildBadges(count: 2).map(_withoutBadgeIcon),
    );
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }
}

class _TestCourseListController extends CourseListController {
  _TestCourseListController() : super();

  @override
  void onInit() {}

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = 'Loading courses...';
  }

  void setLoadedState() {
    final mock = Get.find<MockDataService>();
    courses.value = mock
        .buildCourses(count: 3)
        .map(_withoutCover)
        .toList();
    pageState.value = PageState.initial;
    stateMessage.value = '';
  }

  void setEmptyState() {
    courses.clear();
    pageState.value = PageState.empty;
    stateMessage.value = 'No courses available yet.';
  }

  void setErrorState() {
    courses.clear();
    pageState.value = PageState.error;
    stateMessage.value = 'Failed to load courses. Please try again.';
  }
}

class _TestChallengeListController extends ChallengeListController {
  _TestChallengeListController() : super();

  @override
  void onInit() {
    registerRetry(loadChallenges);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = 'Loading challenges...';
  }

  void setLoadedState() {
    final mock = Get.find<MockDataService>();
    challenges.assignAll(mock.buildChallenges(count: 4));
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
  void onInit() {}

  void setLoadedState() {
    final mock = Get.find<MockDataService>();
    activities.assignAll(
      mock.buildActivities(count: 3).map(_withoutActivityAvatar),
    );
    friends.assignAll(
      mock.buildFriends(count: 4).map(_withoutFriendAvatar),
    );
    leaderboard.assignAll(mock.buildLeaderboardEntries(count: 6));
  }

  void setEmptyState() {
    activities.clear();
    friends.clear();
    leaderboard.clear();
  }
}

class _TestProfileController extends ProfileController {
  _TestProfileController() : super();

  @override
  void onInit() {
    registerRetry(loadProfileData);
  }

  void setLoadingState() {
    pageState.value = PageState.loading;
    stateMessage.value = 'Loading profile...';
  }

  void setLoadedState() {
    final mock = Get.find<MockDataService>();
    user.value = _withoutAvatar(mock.buildUser());
    stats.value = mock.buildStats();
    badges.assignAll(
      mock.buildBadges(count: 2).map(_withoutBadgeIcon),
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
          colorSchemeSeed: const Color(0xFF2196F3),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<MockDataService>(MockDataService());
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

      expect(find.text('Retry'), findsOneWidget);
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
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump();
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
      expect(find.text('Loading courses...'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setLoadedState();
      await tester.pump();
      expect(find.text('Frontend Foundations 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setEmptyState();
      await tester.pump();
      expect(find.text('No courses yet'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      controller.setErrorState();
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
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
      expect(find.text('Challenge Map'), findsOneWidget);
      expect(find.text('Challenge 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);
    });

    testWidgets('social page renders loaded activity, friends and leaderboard tabs', (
      tester,
    ) async {
      final controller = _TestSocialController();
      Get.put<SocialController>(controller);
      controller.setLoadedState();

      await _pumpPhoneSized(tester, buildGoldenApp(const SocialView()));
      expect(find.text('Social Center'), findsOneWidget);
      expect(find.text('Peer 1'), findsOneWidget);
      _expectNoFlutterErrors(tester);

      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Friend Requests'), findsOneWidget);
      expect(find.text('Accept'), findsWidgets);
      _expectNoFlutterErrors(tester);

      await tester.tap(find.text('Leaderboard'));
      await tester.pumpAndSettle();
      expect(find.text('Leader 1'), findsOneWidget);
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
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Quick Access'), findsOneWidget);
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

      expect(find.text('Frontend Foundations 1'), findsOneWidget);
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

      expect(find.text('Challenge 1'), findsOneWidget);
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

      expect(find.text('Activity'), findsOneWidget);
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

      expect(find.text('Recent Badges'), findsOneWidget);
      _expectNoFlutterErrors(tester);
      await expectLater(
        find.byType(ScreenUtilInit),
        matchesGoldenFile('$_goldenPath/profile_loaded.png'),
      );
    });
  });
}
