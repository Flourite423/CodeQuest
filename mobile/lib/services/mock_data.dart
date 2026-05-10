import 'package:get/get.dart';

import '../models/models.dart';

enum MockScenario { empty, single, multiple, error }

class MockDataException implements Exception {
  MockDataException(this.message);

  final String message;

  @override
  String toString() => 'MockDataException: $message';
}

class MockDataService extends GetxService {
  static const Duration defaultDelay = Duration(milliseconds: 350);
  
  // Allow disabling delay for tests
  bool enableDelay = true;

  Future<void> _simulateDelay(Duration? delay) async {
    if (enableDelay) {
      await Future<void>.delayed(delay ?? defaultDelay);
    }
  }

  Never _throwScenarioError(String resource) {
    throw MockDataException('Mock request failed for $resource');
  }

  Future<List<T>> _fetchList<T>({
    required String resource,
    required List<T> multipleItems,
    required MockScenario scenario,
    Duration? delay,
  }) async {
    await _simulateDelay(delay);

    switch (scenario) {
      case MockScenario.empty:
        return <T>[];
      case MockScenario.single:
        return multipleItems.isEmpty ? <T>[] : <T>[multipleItems.first];
      case MockScenario.multiple:
        return multipleItems;
      case MockScenario.error:
        _throwScenarioError(resource);
    }
  }

  Future<T?> _fetchItem<T>({
    required String resource,
    required T item,
    required MockScenario scenario,
    Duration? delay,
  }) async {
    await _simulateDelay(delay);

    switch (scenario) {
      case MockScenario.empty:
        return null;
      case MockScenario.single:
      case MockScenario.multiple:
        return item;
      case MockScenario.error:
        _throwScenarioError(resource);
    }
  }

  User buildUser({int seed = 1}) {
    return User(
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

  List<User> buildUsers({int count = 4}) {
    return List<User>.generate(count, (index) => buildUser(seed: index + 1));
  }

  Chapter buildChapter({int seed = 1}) {
    return Chapter(
      id: 'chapter-$seed',
      title: '章节 $seed',
      content: '# 章节 $seed\n\n本章介绍学习者友好的 Markdown 内容。',
      sampleCode: '<section>章节 $seed 示例</section>',
      summary: '核心概念 $seed 总结',
      isCompleted: seed == 1,
      isLocked: seed > 2,
    );
  }

  List<Chapter> buildChapters({int count = 4}) {
    return List<Chapter>.generate(count, (index) => buildChapter(seed: index + 1));
  }

  Course buildCourse({int seed = 1, bool includeChapters = true, String? category}) {
    final chapters = includeChapters ? buildChapters(count: 3) : <Chapter>[];
    return Course(
      id: 'course-$seed',
      title: '前端基础 $seed',
      summary: '循序渐进学习布局、样式和交互基础。',
      difficulty: seed.isEven ? 'intermediate' : 'beginner',
      estimatedMinutes: 90 + seed * 10,
      progress: 0.2 * seed,
      chapters: chapters,
      description: '课程 $seed 的契约对齐学习者课程详情模拟数据。',
      coverImageUrl: 'https://example.com/course/$seed.png',
      category: category,
    );
  }

  List<Course> buildCourses({int count = 4, bool includeChapters = false}) {
    const categories = <String>['frontend', 'frontend', 'backend', 'devops', 'design', 'frontend', 'backend', 'design'];
    return List<Course>.generate(
      count,
      (index) => buildCourse(
        seed: index + 1,
        includeChapters: includeChapters,
        category: index < categories.length ? categories[index] : 'frontend',
      ),
    );
  }

  ExerciseTestCase buildExerciseTestCase({int seed = 1}) {
    return ExerciseTestCase(
      id: 'test-case-$seed',
      type: seed.isEven ? 'css_assert' : 'dom_snapshot',
      name: 'Visible test case $seed',
      weight: 25,
      inputPayload: <String, dynamic>{'selector': '#card-$seed'},
    );
  }

  List<ExerciseTestCase> buildExerciseTestCases({int count = 3}) {
    return List<ExerciseTestCase>.generate(
      count,
      (index) => buildExerciseTestCase(seed: index + 1),
    );
  }

  Exercise buildExercise({int seed = 1}) {
    final type = seed.isEven ? 'single_choice' : 'coding';
    return Exercise(
      id: 'exercise-$seed',
      type: type,
      title: '练习 $seed',
      description: type == 'coding'
          ? '使用起始模板实现所需的 UI 行为。'
          : '为学习者提示选择最佳答案。',
      testCases: buildExerciseTestCases(),
      codeTemplate: type == 'coding' ? '<main>完善我</main>' : null,
    );
  }

  List<Exercise> buildExercises({int count = 3}) {
    return List<Exercise>.generate(count, (index) => buildExercise(seed: index + 1));
  }

  ChallengeTask buildChallengeTask({int seed = 1}) {
    return ChallengeTask(
      id: 'challenge-task-$seed',
      title: '完成阶段 $seed',
      isCompleted: seed == 1,
    );
  }

  List<ChallengeTask> buildChallengeTasks({int count = 3}) {
    return List<ChallengeTask>.generate(count, (index) => buildChallengeTask(seed: index + 1));
  }

  Challenge buildChallenge({int seed = 1}) {
    return Challenge(
      id: 'challenge-$seed',
      title: '挑战 $seed',
      description: '完成一系列学习任务来赢取星星。',
      tasks: buildChallengeTasks(),
      stars: seed % 4,
      reward: seed * 150,
      isCompleted: seed == 1,
    );
  }

  List<Challenge> buildChallenges({int count = 4}) {
    return List<Challenge>.generate(count, (index) => buildChallenge(seed: index + 1));
  }

  DailyChallenge buildDailyChallenge({int seed = 1}) {
    return DailyChallenge(
      id: 'daily-$seed',
      title: '每日挑战 $seed',
      description: '在倒计时结束前完成一个小型编码任务。',
      timeLimit: 900 + seed * 60,
      isAttempted: seed.isEven,
      isExpired: seed > 2,
    );
  }

  List<DailyChallenge> buildDailyChallenges({int count = 3}) {
    return List<DailyChallenge>.generate(
      count,
      (index) => buildDailyChallenge(seed: index + 1),
    );
  }

  AIHelp buildAiHelp({int seed = 1}) {
    return AIHelp(
      requestType: seed.isEven ? 'hint' : 'error_explanation',
      status: 'succeeded',
      content: '尝试将布局拆分为更小的弹性容器。',
    );
  }

  SubmissionResult buildSubmissionResult({int seed = 1}) {
    return SubmissionResult(
      score: 60 + seed * 10,
      passedCases: 2 + seed,
      totalCases: 5,
      feedback: seed.isEven ? null : '有一个选择器仍与预期布局不匹配。',
      aiHelp: buildAiHelp(seed: seed),
    );
  }

  List<SubmissionResult> buildSubmissionResults({int count = 3}) {
    return List<SubmissionResult>.generate(
      count,
      (index) => buildSubmissionResult(seed: index + 1),
    );
  }

  Friend buildFriend({int seed = 1}) {
    return Friend(
      id: 'friend-$seed',
      nickname: '好友 $seed',
      avatar: 'https://example.com/friend/$seed.png',
      level: 3 + seed,
      status: seed.isEven ? 'pending' : 'accepted',
    );
  }

  List<Friend> buildFriends({int count = 5}) {
    return List<Friend>.generate(count, (index) => buildFriend(seed: index + 1));
  }

  Activity buildActivity({int seed = 1}) {
    return Activity(
      id: 'activity-$seed',
      type: switch (seed % 4) {
        0 => 'challenge_completed',
        1 => 'badge_earned',
        2 => 'streak_reached',
        _ => 'course_completed',
      },
      description: '完成了一个可见的学习里程碑 #$seed。',
      timestamp: DateTime.now().subtract(Duration(hours: seed * 3)),
      user: ActivityUser(
        id: 'activity-user-$seed',
        nickname: '用户 $seed',
        avatar: 'https://example.com/peer/$seed.png',
      ),
    );
  }

  List<Activity> buildActivities({int count = 6}) {
    return List<Activity>.generate(count, (index) => buildActivity(seed: index + 1));
  }

  LeaderboardEntry buildLeaderboardEntry({int seed = 1}) {
    return LeaderboardEntry(
      rank: seed,
      userId: 'leader-$seed',
      nickname: '榜首 $seed',
      level: 10 - seed < 1 ? 1 : 10 - seed,
      xp: 8000 - seed * 400,
    );
  }

  List<LeaderboardEntry> buildLeaderboardEntries({int count = 10}) {
    return List<LeaderboardEntry>.generate(
      count,
      (index) => buildLeaderboardEntry(seed: index + 1),
    );
  }

  Badge buildBadge({int seed = 1}) {
    return Badge(
      id: 'badge-$seed',
      name: '徽章 $seed',
      description: '因持续学习进步而授予。',
      icon: 'https://example.com/badge/$seed.png',
      earnedAt: DateTime.now().subtract(Duration(days: seed * 2)),
    );
  }

  List<Badge> buildBadges({int count = 6}) {
    return List<Badge>.generate(count, (index) => buildBadge(seed: index + 1));
  }

  Reward buildReward({int seed = 1}) {
    return Reward(
      id: 'reward-$seed',
      type: switch (seed % 4) {
        0 => 'chapter',
        1 => 'exercise',
        2 => 'challenge',
        _ => 'daily',
      },
      amount: 40 + seed * 10,
      description: '学习者奖励记录 $seed。',
      timestamp: DateTime.now().subtract(Duration(days: seed)),
    );
  }

  List<Reward> buildRewards({int count = 8}) {
    return List<Reward>.generate(count, (index) => buildReward(seed: index + 1));
  }

  Stats buildStats({int seed = 1}) {
    return Stats(
      studyTime: 240 + seed * 30,
      coursesCompleted: 2 + seed,
      challengesWon: 1 + seed,
      currentStreak: 3 + seed,
      totalXp: 1400 + seed * 500,
      mastery: 0.55 + seed * 0.05,
    );
  }

  List<Stats> buildStatsSeries({int count = 3}) {
    return List<Stats>.generate(count, (index) => buildStats(seed: index + 1));
  }

  Future<User?> fetchUser({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'user',
      item: buildUser(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Course>> fetchCourses({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'courses',
      multipleItems: buildCourses(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<Course?> fetchCourse({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'course',
      item: buildCourse(includeChapters: true),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Chapter>> fetchChapters({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'chapters',
      multipleItems: buildChapters(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<Exercise?> fetchExercise({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'exercise',
      item: buildExercise(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Challenge>> fetchChallenges({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'challenges',
      multipleItems: buildChallenges(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<DailyChallenge?> fetchDailyChallenge({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'daily_challenge',
      item: buildDailyChallenge(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<SubmissionResult?> fetchSubmissionResult({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'submission_result',
      item: buildSubmissionResult(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Friend>> fetchFriends({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'friends',
      multipleItems: buildFriends(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Activity>> fetchActivities({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'activities',
      multipleItems: buildActivities(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'leaderboard',
      multipleItems: buildLeaderboardEntries(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Badge>> fetchBadges({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'badges',
      multipleItems: buildBadges(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<List<Reward>> fetchRewards({
    MockScenario scenario = MockScenario.multiple,
    Duration? delay,
  }) {
    return _fetchList(
      resource: 'rewards',
      multipleItems: buildRewards(),
      scenario: scenario,
      delay: delay,
    );
  }

  Future<Stats?> fetchStats({
    MockScenario scenario = MockScenario.single,
    Duration? delay,
  }) {
    return _fetchItem(
      resource: 'stats',
      item: buildStats(),
      scenario: scenario,
      delay: delay,
    );
  }

  // ─── Friend Search & Requests ─────────────────────────────────────────────

  /// Simulated sent friend request IDs to track state across the session.
  final Set<String> _sentFriendRequestIds = <String>{};

  /// Search users by nickname query. Returns users that match the query
  /// and are not already friends.
  Future<List<User>> searchUsers({
    required String query,
    Duration? delay,
  }) async {
    await _simulateDelay(delay);

    if (query.trim().isEmpty) {
      return <User>[];
    }

    final allUsers = buildUsers(count: 12);
    final lowerQuery = query.toLowerCase();

    return allUsers.where((user) {
      return user.nickname.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Send a friend request to a user.
  Future<bool> sendFriendRequest({
    required String userId,
    Duration? delay,
  }) async {
    await _simulateDelay(delay);

    _sentFriendRequestIds.add(userId);
    return true;
  }

  /// Check if a friend request has already been sent to this user.
  bool hasSentFriendRequest(String userId) {
    return _sentFriendRequestIds.contains(userId);
  }
}
