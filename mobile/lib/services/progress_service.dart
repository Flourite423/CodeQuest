import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/models.dart';
import 'storage_service.dart';

class LearningStatsSnapshot {
  const LearningStatsSnapshot({
    required this.studyMinutes,
    required this.completedCourses,
    required this.completedChallenges,
    required this.streakDays,
    required this.earnedXp,
    required this.completedDailyChallenges,
  });

  final int studyMinutes;
  final int completedCourses;
  final int completedChallenges;
  final int streakDays;
  final int earnedXp;
  final int completedDailyChallenges;
}

class ProgressService extends GetxService {
  ProgressService();

  static const String _progressKeysRegistry = '_progress_keys_registry';
  static const String _cacheKeysRegistry = '_cache_keys_registry';
  static const String _pendingSyncActionsKey = '_pending_sync_actions';
  static const String _studyMinutesKey = 'study_minutes_total';
  static const String _streakDaysKey = 'study_streak_days';
  static const String _lastStudyDateKey = 'study_last_date';
  static const String _earnedXpKey = 'earned_xp_total';
  static const String _dailyChallengeRecordsKey = 'daily_challenge_records';
  static const String _activeStudySessionKey = '_active_study_session';
  static const String _lastSyncTimeKey = '_last_sync_time';

  final Connectivity _connectivity = Connectivity();

  final RxBool isOnline = true.obs;
  final RxBool isSyncing = false.obs;
  final Rxn<DateTime> lastSyncTime = Rxn<DateTime>();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  StorageService get _storage {
    if (Get.isRegistered<StorageService>()) {
      return Get.find<StorageService>();
    }
    return Get.put(StorageService());
  }

  @override
  void onInit() {
    super.onInit();
    final savedLastSync = _storage.read<String>(_lastSyncTimeKey);
    if (savedLastSync != null && savedLastSync.isNotEmpty) {
      lastSyncTime.value = DateTime.tryParse(savedLastSync);
    }
    _initializeConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _handleConnectivityChanged(result);
    } catch (_) {
      isOnline.value = true;
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
  }

  Future<void> _handleConnectivityChanged(List<ConnectivityResult> results) async {
    final wasOnline = isOnline.value;
    final hasConnection = results.any((item) => item != ConnectivityResult.none);
    isOnline.value = hasConnection;

    if (!wasOnline && hasConnection) {
      await syncPendingActions();
    }
  }

  String chapterCompletedKey(String chapterId) => 'chapter_completed_$chapterId';

  String courseProgressKey(String courseId) => 'course_progress_$courseId';

  String challengeCompletedKey(String challengeId) => 'challenge_completed_$challengeId';

  String challengeStarsKey(String challengeId) => 'challenge_stars_$challengeId';

  String challengeCompletedAtKey(String challengeId) =>
      'challenge_completed_at_$challengeId';

  String challengeRewardSettledKey(String challengeId) =>
      'challenge_reward_settled_$challengeId';

  String challengeRewardSettledAtKey(String challengeId) =>
      'challenge_reward_settled_at_$challengeId';

  String _cacheCourseKey(String courseId) => 'cache_course_$courseId';

  Future<void> _writeProgressValue(String key, dynamic value) async {
    await _registerKey(_progressKeysRegistry, key);
    await _storage.write(key, value);
  }

  Future<void> _writeCacheValue(String key, dynamic value) async {
    await _registerKey(_cacheKeysRegistry, key);
    await _storage.write(key, value);
  }

  Future<void> _removeProgressValue(String key) async {
    await _storage.remove(key);
    await _unregisterKey(_progressKeysRegistry, key);
  }

  Future<void> _registerKey(String registryKey, String key) async {
    final existing = _storage.read<List<dynamic>>(registryKey) ?? <dynamic>[];
    final normalized = existing.map((item) => item.toString()).toSet();
    if (normalized.add(key)) {
      await _storage.write(registryKey, normalized.toList());
    }
  }

  Future<void> _unregisterKey(String registryKey, String key) async {
    final existing = _storage.read<List<dynamic>>(registryKey) ?? <dynamic>[];
    final normalized = existing.map((item) => item.toString()).toList();
    normalized.remove(key);
    await _storage.write(registryKey, normalized);
  }

  bool isChapterCompleted(String chapterId) {
    return _storage.read<bool>(chapterCompletedKey(chapterId)) ?? false;
  }

  Future<void> saveChapterCompleted({
    required String chapterId,
    String? courseId,
    double? courseProgress,
    int earnedXp = 20,
  }) async {
    await _writeProgressValue(chapterCompletedKey(chapterId), true);
    if (courseId != null && courseProgress != null) {
      await saveCourseProgress(courseId, courseProgress);
    }
    await addEarnedXp(earnedXp);
    await recordLearningActivity();
    await _queuePendingActionIfOffline(
      actionType: 'chapter_completed',
      entityId: chapterId,
      payload: <String, dynamic>{
        'courseId': courseId,
        'courseProgress': courseProgress,
      },
    );
  }

  double getCourseProgress(String courseId) {
    final stored = _storage.read<num>(courseProgressKey(courseId));
    if (stored == null) {
      return 0;
    }
    return stored.toDouble().clamp(0.0, 1.0);
  }

  Future<void> saveCourseProgress(String courseId, double progress) async {
    final normalized = progress.clamp(0.0, 1.0);
    await _writeProgressValue(courseProgressKey(courseId), normalized);
    await _queuePendingActionIfOffline(
      actionType: 'course_progress',
      entityId: courseId,
      payload: <String, dynamic>{'progress': normalized},
    );
  }

  bool isChallengeCompleted(String challengeId) {
    return _storage.read<bool>(challengeCompletedKey(challengeId)) ?? false;
  }

  int getChallengeStars(String challengeId) {
    final stored = _storage.read<num>(challengeStarsKey(challengeId));
    return stored?.toInt() ?? 0;
  }

  DateTime? getChallengeCompletedAt(String challengeId) {
    final value = _storage.read<String>(challengeCompletedAtKey(challengeId));
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  bool isChallengeRewardSettled(String challengeId) {
    return _storage.read<bool>(challengeRewardSettledKey(challengeId)) ?? false;
  }

  DateTime? getChallengeRewardSettledAt(String challengeId) {
    final value = _storage.read<String>(challengeRewardSettledAtKey(challengeId));
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Future<void> saveChallengeCompletion({
    required String challengeId,
    required int stars,
    required int rewardXp,
    DateTime? completedAt,
  }) async {
    final completedTime = completedAt ?? DateTime.now();
    await _writeProgressValue(challengeCompletedKey(challengeId), true);
    await _writeProgressValue(challengeStarsKey(challengeId), stars);
    await _writeProgressValue(
      challengeCompletedAtKey(challengeId),
      completedTime.toIso8601String(),
    );
    await addEarnedXp(rewardXp);
    await recordLearningActivity(date: completedTime);
    await _queuePendingActionIfOffline(
      actionType: 'challenge_completed',
      entityId: challengeId,
      payload: <String, dynamic>{
        'stars': stars,
        'rewardXp': rewardXp,
        'completedAt': completedTime.toIso8601String(),
      },
    );
  }

  Future<void> markChallengeRewardSettled(String challengeId) async {
    final settledAt = DateTime.now();
    await _writeProgressValue(challengeRewardSettledKey(challengeId), true);
    await _writeProgressValue(
      challengeRewardSettledAtKey(challengeId),
      settledAt.toIso8601String(),
    );
    await _queuePendingActionIfOffline(
      actionType: 'challenge_reward_settled',
      entityId: challengeId,
      payload: <String, dynamic>{'settledAt': settledAt.toIso8601String()},
    );
  }

  Map<String, dynamic> getDailyChallengeRecords() {
    final stored = _storage.read<Map<String, dynamic>>(_dailyChallengeRecordsKey);
    return Map<String, dynamic>.from(stored ?? <String, dynamic>{});
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isDailyChallengeCompletedOn(DateTime date) {
    return getDailyChallengeRecords().containsKey(_formatDateKey(date));
  }

  int getCompletedDailyChallengeCount() {
    return getDailyChallengeRecords().length;
  }

  Future<void> saveDailyChallengeCompletion({
    required String challengeId,
    int earnedXp = 30,
    DateTime? completedAt,
  }) async {
    final completedTime = completedAt ?? DateTime.now();
    final records = getDailyChallengeRecords();
    records[_formatDateKey(completedTime)] = <String, dynamic>{
      'challengeId': challengeId,
      'completedAt': completedTime.toIso8601String(),
    };
    await _writeProgressValue(_dailyChallengeRecordsKey, records);
    await addEarnedXp(earnedXp);
    await recordLearningActivity(date: completedTime);
    await _queuePendingActionIfOffline(
      actionType: 'daily_challenge_completed',
      entityId: challengeId,
      payload: <String, dynamic>{
        'completedAt': completedTime.toIso8601String(),
      },
    );
  }

  int getStudyMinutes() {
    return _storage.read<int>(_studyMinutesKey) ?? 0;
  }

  Future<void> addStudyMinutes(int minutes, {DateTime? date}) async {
    if (minutes <= 0) {
      return;
    }
    final total = getStudyMinutes() + minutes;
    await _writeProgressValue(_studyMinutesKey, total);
    await recordLearningActivity(date: date);
  }

  Future<void> startStudySession(String sessionId) async {
    final current = _storage.read<Map<String, dynamic>>(_activeStudySessionKey);
    if (current != null && current['id'] == sessionId) {
      return;
    }
    await stopStudySession();
    await _writeProgressValue(_activeStudySessionKey, <String, dynamic>{
      'id': sessionId,
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<int> stopStudySession({String? sessionId}) async {
    final current = _storage.read<Map<String, dynamic>>(_activeStudySessionKey);
    if (current == null) {
      return 0;
    }
    if (sessionId != null && current['id'] != sessionId) {
      return 0;
    }

    final startedAt = DateTime.tryParse((current['startedAt'] ?? '').toString());
    await _removeProgressValue(_activeStudySessionKey);
    if (startedAt == null) {
      return 0;
    }

    final elapsedSeconds = DateTime.now().difference(startedAt).inSeconds;
    if (elapsedSeconds < 30) {
      return 0;
    }

    final minutes = (elapsedSeconds / 60).ceil();
    await addStudyMinutes(minutes, date: DateTime.now());
    return minutes;
  }

  int getStreakDays() {
    return _storage.read<int>(_streakDaysKey) ?? 0;
  }

  Future<void> recordLearningActivity({DateTime? date}) async {
    final currentDate = date ?? DateTime.now();
    final dateKey = _formatDateKey(currentDate);
    final lastDateKey = _storage.read<String>(_lastStudyDateKey);
    final currentStreak = getStreakDays();

    if (lastDateKey == dateKey) {
      return;
    }

    final yesterdayKey = _formatDateKey(currentDate.subtract(const Duration(days: 1)));
    final nextStreak = lastDateKey == yesterdayKey ? currentStreak + 1 : 1;

    await _writeProgressValue(_lastStudyDateKey, dateKey);
    await _writeProgressValue(_streakDaysKey, nextStreak);
  }

  int getEarnedXp() {
    return _storage.read<int>(_earnedXpKey) ?? 0;
  }

  int getCompletedCourseCount() {
    final progressKeys = _storage.read<List<dynamic>>(_progressKeysRegistry) ?? <dynamic>[];
    return progressKeys
        .map((item) => item.toString())
        .where((key) => key.startsWith('course_progress_'))
        .where((key) => (_storage.read<num>(key)?.toDouble() ?? 0) >= 1.0)
        .length;
  }

  int getCompletedChallengeCount() {
    final progressKeys = _storage.read<List<dynamic>>(_progressKeysRegistry) ?? <dynamic>[];
    return progressKeys
        .map((item) => item.toString())
        .where((key) => key.startsWith('challenge_completed_'))
        .where((key) => _storage.read<bool>(key) == true)
        .length;
  }

  Future<void> addEarnedXp(int xp) async {
    if (xp <= 0) {
      return;
    }
    final total = getEarnedXp() + xp;
    await _writeProgressValue(_earnedXpKey, total);
  }

  LearningStatsSnapshot getLearningStatsSnapshot({
    List<Course> courses = const <Course>[],
    List<Challenge> challenges = const <Challenge>[],
  }) {
    final completedCourses = courses
        .where((course) => (course.progress ?? 0) >= 1.0)
        .length;
    final completedChallenges = challenges
        .where((challenge) => challenge.isCompleted)
        .length;

    return LearningStatsSnapshot(
      studyMinutes: getStudyMinutes(),
      completedCourses: completedCourses > 0 ? completedCourses : getCompletedCourseCount(),
      completedChallenges:
          completedChallenges > 0 ? completedChallenges : getCompletedChallengeCount(),
      streakDays: getStreakDays(),
      earnedXp: getEarnedXp(),
      completedDailyChallenges: getCompletedDailyChallengeCount(),
    );
  }

  Course applyCourseProgress(Course course) {
    final storedProgress = getCourseProgress(course.id);
    final processedChapters = <Chapter>[];

    for (var index = 0; index < course.chapters.length; index++) {
      final chapter = course.chapters[index];
      final isCompleted = isChapterCompleted(chapter.id) || chapter.isCompleted;
      final isLocked = index == 0 ? false : !processedChapters[index - 1].isCompleted;
      processedChapters.add(
        Chapter(
          id: chapter.id,
          title: chapter.title,
          content: chapter.content,
          sampleCode: chapter.sampleCode,
          summary: chapter.summary,
          isCompleted: isCompleted,
          isLocked: isLocked,
        ),
      );
    }

    final computedProgress = processedChapters.isEmpty
        ? (storedProgress > 0 ? storedProgress : (course.progress ?? 0))
        : processedChapters.where((chapter) => chapter.isCompleted).length /
            processedChapters.length;

    return Course(
      id: course.id,
      title: course.title,
      summary: course.summary,
      difficulty: course.difficulty,
      estimatedMinutes: course.estimatedMinutes,
      progress: computedProgress,
      chapters: processedChapters.isEmpty ? course.chapters : processedChapters,
      description: course.description,
      coverImageUrl: course.coverImageUrl,
      category: course.category,
    );
  }

  List<Course> applyCourseProgressList(List<Course> courses) {
    return courses.map((course) {
      final storedProgress = getCourseProgress(course.id);
      return Course(
        id: course.id,
        title: course.title,
        summary: course.summary,
        difficulty: course.difficulty,
        estimatedMinutes: course.estimatedMinutes,
        progress: storedProgress > 0 ? storedProgress : (course.progress ?? 0),
        chapters: course.chapters,
        description: course.description,
        coverImageUrl: course.coverImageUrl,
        category: course.category,
      );
    }).toList();
  }

  Challenge applyChallengeProgress(Challenge challenge) {
    final completed = isChallengeCompleted(challenge.id) || challenge.isCompleted;
    final stars = getChallengeStars(challenge.id);
    return Challenge(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      tasks: challenge.tasks,
      stars: stars > 0 ? stars : challenge.stars,
      reward: challenge.reward,
      isCompleted: completed,
    );
  }

  List<Challenge> applyChallengeProgressList(List<Challenge> challenges) {
    return challenges.map(applyChallengeProgress).toList();
  }

  DailyChallenge applyDailyChallengeProgress(DailyChallenge challenge) {
    final attemptedToday = isDailyChallengeCompletedOn(DateTime.now());
    return DailyChallenge(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      timeLimit: challenge.timeLimit,
      isAttempted: attemptedToday || challenge.isAttempted,
      isExpired: challenge.isExpired,
    );
  }

  Future<void> cacheCourses(List<Course> courses) async {
    await _writeCacheValue(
      'cache_courses',
      courses.map((course) => course.toJson()).toList(),
    );
  }

  List<Course> getCachedCourses() {
    final stored = _storage.read<List<dynamic>>('cache_courses') ?? <dynamic>[];
    return stored
        .whereType<Map>()
        .map((item) => Course.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> cacheCourse(Course course) async {
    await _writeCacheValue(_cacheCourseKey(course.id), course.toJson());
  }

  Course? getCachedCourse(String courseId) {
    final stored = _storage.read<Map<String, dynamic>>(_cacheCourseKey(courseId));
    if (stored == null) {
      return null;
    }
    return Course.fromJson(Map<String, dynamic>.from(stored));
  }

  Future<void> cacheChallenges(List<Challenge> challenges) async {
    await _writeCacheValue(
      'cache_challenges',
      challenges.map((challenge) => challenge.toJson()).toList(),
    );
  }

  List<Challenge> getCachedChallenges() {
    final stored = _storage.read<List<dynamic>>('cache_challenges') ?? <dynamic>[];
    return stored
        .whereType<Map>()
        .map((item) => Challenge.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> cacheDailyChallenge(DailyChallenge challenge) async {
    await _writeCacheValue('cache_daily_challenge', challenge.toJson());
  }

  DailyChallenge? getCachedDailyChallenge() {
    final stored = _storage.read<Map<String, dynamic>>('cache_daily_challenge');
    if (stored == null) {
      return null;
    }
    return DailyChallenge.fromJson(Map<String, dynamic>.from(stored));
  }

  Future<void> cacheUser(User user) async {
    await _writeCacheValue('cache_user', user.toJson());
  }

  User? getCachedUser() {
    final stored = _storage.read<Map<String, dynamic>>('cache_user');
    if (stored == null) {
      return null;
    }
    return User.fromJson(Map<String, dynamic>.from(stored));
  }

  Future<void> cacheStats(Stats stats) async {
    await _writeCacheValue('cache_stats', stats.toJson());
  }

  Stats? getCachedStats() {
    final stored = _storage.read<Map<String, dynamic>>('cache_stats');
    if (stored == null) {
      return null;
    }
    return Stats.fromJson(Map<String, dynamic>.from(stored));
  }

  List<Map<String, dynamic>> getPendingSyncActions() {
    final stored = _storage.read<List<dynamic>>(_pendingSyncActionsKey) ?? <dynamic>[];
    return stored
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _queuePendingActionIfOffline({
    required String actionType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    if (isOnline.value) {
      return;
    }

    final pending = getPendingSyncActions();
    pending.add(<String, dynamic>{
      'actionType': actionType,
      'entityId': entityId,
      'payload': payload,
      'queuedAt': DateTime.now().toIso8601String(),
    });
    await _writeProgressValue(_pendingSyncActionsKey, pending);
  }

  Future<void> syncPendingActions() async {
    if (!isOnline.value || isSyncing.value) {
      return;
    }

    final pending = getPendingSyncActions();
    if (pending.isEmpty) {
      final now = DateTime.now();
      lastSyncTime.value = now;
      await _writeProgressValue(_lastSyncTimeKey, now.toIso8601String());
      return;
    }

    isSyncing.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _writeProgressValue(_pendingSyncActionsKey, <Map<String, dynamic>>[]);
      final now = DateTime.now();
      lastSyncTime.value = now;
      await _writeProgressValue(_lastSyncTimeKey, now.toIso8601String());

      if (Get.context != null) {
        Get.snackbar(
          '网络已恢复',
          '离线期间的学习记录已同步到本地队列。',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> clearLearningProgress() async {
    final progressKeys = _storage.read<List<dynamic>>(_progressKeysRegistry) ?? <dynamic>[];
    for (final key in progressKeys.map((item) => item.toString())) {
      await _storage.remove(key);
    }
    await _storage.write(_progressKeysRegistry, <String>[]);

    final cacheKeys = _storage.read<List<dynamic>>(_cacheKeysRegistry) ?? <dynamic>[];
    for (final key in cacheKeys.map((item) => item.toString())) {
      await _storage.remove(key);
    }
    await _storage.write(_cacheKeysRegistry, <String>[]);
  }
}
