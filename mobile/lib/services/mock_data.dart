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

  Future<void> _simulateDelay(Duration? delay) {
    return Future<void>.delayed(delay ?? defaultDelay);
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
      nickname: 'Learner $seed',
      avatar: 'https://example.com/avatar/$seed.png',
      level: 4 + seed,
      xp: 1200 * seed,
      streak: 2 + seed,
      bio: 'Building steady frontend skills every day.',
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
      title: 'Chapter $seed',
      content: '# Chapter $seed\n\nThis chapter walks through learner-safe markdown content.',
      sampleCode: '<section>Chapter $seed sample</section>',
      summary: 'Core concept $seed summary',
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
      title: 'Frontend Foundations $seed',
      summary: 'Learn layout, styling, and interaction basics in small steps.',
      difficulty: seed.isEven ? 'intermediate' : 'beginner',
      estimatedMinutes: 90 + seed * 10,
      progress: 0.2 * seed,
      chapters: chapters,
      description: 'Contract-aligned learner course detail mock for course $seed.',
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
      title: 'Exercise $seed',
      description: type == 'coding'
          ? 'Implement the requested UI behavior using the starter template.'
          : 'Choose the best answer for the learner-facing prompt.',
      testCases: buildExerciseTestCases(),
      codeTemplate: type == 'coding' ? '<main>Complete me</main>' : null,
    );
  }

  List<Exercise> buildExercises({int count = 3}) {
    return List<Exercise>.generate(count, (index) => buildExercise(seed: index + 1));
  }

  ChallengeTask buildChallengeTask({int seed = 1}) {
    return ChallengeTask(
      id: 'challenge-task-$seed',
      title: 'Finish stage $seed',
      isCompleted: seed == 1,
    );
  }

  List<ChallengeTask> buildChallengeTasks({int count = 3}) {
    return List<ChallengeTask>.generate(count, (index) => buildChallengeTask(seed: index + 1));
  }

  Challenge buildChallenge({int seed = 1}) {
    return Challenge(
      id: 'challenge-$seed',
      title: 'Challenge $seed',
      description: 'Work through a linear set of learner tasks to earn stars.',
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
      title: 'Daily Challenge $seed',
      description: 'Ship one small coding win before the countdown ends.',
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
      content: 'Try breaking the layout into smaller flex containers.',
    );
  }

  SubmissionResult buildSubmissionResult({int seed = 1}) {
    return SubmissionResult(
      score: 60 + seed * 10,
      passedCases: 2 + seed,
      totalCases: 5,
      feedback: seed.isEven ? null : 'One selector still does not match the expected layout.',
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
      nickname: 'Friend $seed',
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
      description: 'Completed a visible learner milestone #$seed.',
      timestamp: DateTime.now().subtract(Duration(hours: seed * 3)),
      user: ActivityUser(
        id: 'activity-user-$seed',
        nickname: 'Peer $seed',
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
      nickname: 'Leader $seed',
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
      name: 'Badge $seed',
      description: 'Awarded for consistent learning progress.',
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
      description: 'Learner reward ledger entry $seed.',
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
}
