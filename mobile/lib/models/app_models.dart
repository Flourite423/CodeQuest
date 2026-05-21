typedef JsonMap = Map<String, dynamic>;

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

double? _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

String _activityDescription(String type, JsonMap payload) {
  final summary = payload['summary'] ?? payload['title'] ?? payload['label'];
  if (summary is String && summary.isNotEmpty) {
    return summary;
  }

  switch (type) {
    case 'challenge_completed':
      return 'Completed a challenge';
    case 'badge_earned':
      return 'Earned a new badge';
    case 'streak_reached':
      return 'Reached a new streak milestone';
    case 'course_completed':
      return 'Completed a course';
    default:
      return 'Shared a learning update';
  }
}

String _rewardDescription(String type) {
  switch (type) {
    case 'chapter':
      return 'Chapter completion reward';
    case 'exercise':
      return 'Exercise completion reward';
    case 'challenge':
      return 'Challenge settlement reward';
    case 'daily':
      return 'Daily challenge reward';
    case 'admin_adjustment':
      return 'Manual XP adjustment';
    default:
      return 'Reward update';
  }
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.avatar,
    required this.level,
    required this.xp,
    required this.streak,
    this.bio,
    required this.dailyGoal,
    required this.themeMode,
  });

  final String id;
  final String email;
  final String nickname;
  final String? avatar;
  final int level;
  final int xp;
  final int streak;
  final String? bio;
  final int dailyGoal;
  final String themeMode;

  factory User.fromContracts({
    required JsonMap account,
    required JsonMap profile,
  }) {
    return User(
      id: (profile['account_id'] ?? account['id'] ?? '').toString(),
      email: (account['email'] ?? '').toString(),
      nickname: (profile['nickname'] ?? '').toString(),
      avatar: profile['avatar_url'] as String?,
      level: _asInt(profile['current_level'], fallback: 1),
      xp: _asInt(profile['total_xp']),
      streak: _asInt(profile['streak_days']),
      bio: profile['bio'] as String?,
      dailyGoal: _asInt(profile['daily_goal_minutes']),
      themeMode: (profile['theme_mode'] ?? 'system').toString(),
    );
  }

  factory User.fromJson(JsonMap json) {
    return User(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatar: json['avatar'] as String?,
      level: _asInt(json['level'], fallback: 1),
      xp: _asInt(json['xp']),
      streak: _asInt(json['streak']),
      bio: json['bio'] as String?,
      dailyGoal: _asInt(json['dailyGoal']),
      themeMode: (json['themeMode'] ?? 'system').toString(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'avatar': avatar,
        'level': level,
        'xp': xp,
        'streak': streak,
        'bio': bio,
        'dailyGoal': dailyGoal,
        'themeMode': themeMode,
      };
}

class Chapter {
  const Chapter({
    required this.id,
    required this.title,
    required this.content,
    this.sampleCode,
    required this.summary,
    required this.isCompleted,
    required this.isLocked,
  });

  final String id;
  final String title;
  final String content;
  final String? sampleCode;
  final String summary;
  final bool isCompleted;
  final bool isLocked;

  factory Chapter.fromCourseDetailJson(
    JsonMap json, {
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return Chapter(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['learning_content_markdown'] ?? '').toString(),
      sampleCode: json['sample_code'] as String?,
      summary: (json['summary'] ?? '').toString(),
      isCompleted: isCompleted,
      isLocked: isLocked,
    );
  }

  factory Chapter.fromJson(JsonMap json) {
    return Chapter(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      sampleCode: json['sampleCode'] as String?,
      summary: (json['summary'] ?? '').toString(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'sampleCode': sampleCode,
        'summary': summary,
        'isCompleted': isCompleted,
        'isLocked': isLocked,
      };
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.estimatedMinutes,
    this.progress,
    this.chapters = const [],
    this.description,
    this.coverImageUrl,
    this.category,
  });

  final String id;
  final String title;
  final String summary;
  final String difficulty;
  final int estimatedMinutes;
  final double? progress;
  final List<Chapter> chapters;
  final String? description;
  final String? coverImageUrl;
  final String? category;

  factory Course.fromListItemJson(JsonMap json, {double? progress}) {
    return Course(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      estimatedMinutes: _asInt(json['estimated_minutes']),
      progress: progress,
      coverImageUrl: json['cover_image_url'] as String?,
      category: json['category'] as String?,
    );
  }

  factory Course.fromDetailJson(JsonMap json, {double? progress}) {
    final chapterList = (json['chapters'] as List<dynamic>? ?? <dynamic>[])
        .cast<JsonMap>()
        .map(Chapter.fromCourseDetailJson)
        .toList();

    return Course(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      estimatedMinutes: _asInt(json['estimated_minutes']),
      progress: progress,
      chapters: chapterList,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      category: json['category'] as String?,
    );
  }

  factory Course.fromJson(JsonMap json) {
    return Course(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      estimatedMinutes: _asInt(json['estimatedMinutes']),
      progress: _asDouble(json['progress']),
      chapters: (json['chapters'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(Chapter.fromJson)
          .toList(),
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      category: json['category'] as String?,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'difficulty': difficulty,
        'estimatedMinutes': estimatedMinutes,
        'progress': progress,
        'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
        'description': description,
        'coverImageUrl': coverImageUrl,
        'category': category,
      };
}

class ExerciseTestCase {
  const ExerciseTestCase({
    required this.id,
    required this.type,
    required this.name,
    required this.weight,
    this.inputPayload,
  });

  final String id;
  final String type;
  final String name;
  final int weight;
  final JsonMap? inputPayload;

  factory ExerciseTestCase.fromVisibleCaseJson(JsonMap json) {
    return ExerciseTestCase(
      id: (json['id'] ?? '').toString(),
      type: (json['case_type'] ?? '').toString(),
      name: (json['case_name'] ?? '').toString(),
      weight: _asInt(json['weight']),
      inputPayload: json['input_payload_json'] as JsonMap?,
    );
  }

  factory ExerciseTestCase.fromJson(JsonMap json) {
    return ExerciseTestCase(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      weight: _asInt(json['weight']),
      inputPayload: json['inputPayload'] as JsonMap?,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'weight': weight,
        'inputPayload': inputPayload,
      };
}

class ExerciseChoiceOption {
  const ExerciseChoiceOption({required this.key, required this.text});

  final String key;
  final String text;

  factory ExerciseChoiceOption.fromJson(JsonMap json) {
    return ExerciseChoiceOption(
      key: (json['option_key'] ?? '').toString(),
      text: (json['option_text'] ?? '').toString(),
    );
  }
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.options = const [],
    this.testCases = const [],
    this.codeTemplate,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final List<ExerciseChoiceOption> options;
  final List<ExerciseTestCase> testCases;
  final String? codeTemplate;

  factory Exercise.fromDetailJson(JsonMap json) {
    final exercise = (json['exercise'] as JsonMap? ?? <String, dynamic>{});
    return Exercise(
      id: (exercise['id'] ?? '').toString(),
      type: (exercise['exercise_type'] ?? '').toString(),
      title: (exercise['title'] ?? '').toString(),
      description: (exercise['prompt'] ?? '').toString(),
      options: (json['options'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(ExerciseChoiceOption.fromJson)
          .toList(),
      testCases: (json['visible_test_cases'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(ExerciseTestCase.fromVisibleCaseJson)
          .toList(),
      codeTemplate: exercise['starter_code'] as String?,
    );
  }

  factory Exercise.fromJson(JsonMap json) {
    return Exercise(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      options: (json['options'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(ExerciseChoiceOption.fromJson)
          .toList(),
      testCases: (json['testCases'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(ExerciseTestCase.fromJson)
          .toList(),
      codeTemplate: json['codeTemplate'] as String?,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'options': options.map((option) => {'key': option.key, 'text': option.text}).toList(),
        'testCases': testCases.map((testCase) => testCase.toJson()).toList(),
        'codeTemplate': codeTemplate,
      };
}

class ChallengeTask {
  const ChallengeTask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  factory ChallengeTask.fromJson(JsonMap json) {
    return ChallengeTask(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.tasks = const [],
    required this.stars,
    required this.reward,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String description;
  final List<ChallengeTask> tasks;
  final int stars;
  final int reward;
  final bool isCompleted;

  factory Challenge.fromMapItemJson(JsonMap json, {List<ChallengeTask> tasks = const []}) {
    return Challenge(
      id: (json['challenge_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['summary'] ?? '').toString(),
      tasks: tasks,
      stars: _asInt(json['best_star']),
      reward: _asInt(json['reward_xp']),
      isCompleted: json['learner_status'] == 'completed',
    );
  }

  factory Challenge.fromJson(JsonMap json) {
    return Challenge(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      tasks: (json['tasks'] as List<dynamic>? ?? <dynamic>[])
          .cast<JsonMap>()
          .map(ChallengeTask.fromJson)
          .toList(),
      stars: _asInt(json['stars']),
      reward: _asInt(json['reward']),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'stars': stars,
        'reward': reward,
        'isCompleted': isCompleted,
      };
}

class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLimit,
    required this.isAttempted,
    required this.isExpired,
  });

  final String id;
  final String title;
  final String description;
  final int timeLimit;
  final bool isAttempted;
  final bool isExpired;

  factory DailyChallenge.fromContracts({
    required JsonMap challenge,
    JsonMap? record,
  }) {
    final status = (record?['status'] ?? '').toString();
    final challengeStatus = (challenge['status'] ?? '').toString();
    return DailyChallenge(
      id: (challenge['id'] ?? '').toString(),
      title: (challenge['title'] ?? '').toString(),
      description: (challenge['title'] ?? '').toString(),
      timeLimit: _asInt(challenge['time_limit_seconds']),
      isAttempted: status.isNotEmpty && status != 'not_started',
      isExpired: status == 'expired' || challengeStatus == 'closed',
    );
  }

  factory DailyChallenge.fromJson(JsonMap json) {
    return DailyChallenge(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      timeLimit: _asInt(json['timeLimit']),
      isAttempted: json['isAttempted'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'timeLimit': timeLimit,
        'isAttempted': isAttempted,
        'isExpired': isExpired,
      };
}

class AIHelp {
  const AIHelp({
    required this.requestType,
    required this.status,
    this.content,
    this.isFallback = false,
  });

  final String requestType;
  final String status;
  final String? content;
  final bool isFallback;

  factory AIHelp.fromContract(JsonMap json) {
    return AIHelp(
      requestType: (json['request_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      content: json['response_text'] as String?,
      isFallback: json['is_fallback'] == true,
    );
  }

  factory AIHelp.fromJson(JsonMap json) {
    return AIHelp(
      requestType: (json['requestType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      content: json['content'] as String?,
      isFallback: json['isFallback'] == true,
    );
  }

  JsonMap toJson() => {
        'requestType': requestType,
        'status': status,
        'content': content,
        'isFallback': isFallback,
      };
}

class SubmissionResult {
  const SubmissionResult({
    required this.score,
    required this.passedCases,
    required this.totalCases,
    this.feedback,
    this.aiHelp,
  });

  final int score;
  final int passedCases;
  final int totalCases;
  final String? feedback;
  final AIHelp? aiHelp;

  factory SubmissionResult.fromContracts({
    required JsonMap submission,
    JsonMap? aiHelp,
  }) {
    return SubmissionResult(
      score: _asInt(submission['score']),
      passedCases: _asInt(submission['passed_case_count']),
      totalCases: _asInt(submission['total_case_count']),
      feedback: submission['error_summary'] as String?,
      aiHelp: aiHelp == null ? null : AIHelp.fromContract(aiHelp),
    );
  }

  factory SubmissionResult.fromJson(JsonMap json) {
    return SubmissionResult(
      score: _asInt(json['score']),
      passedCases: _asInt(json['passedCases']),
      totalCases: _asInt(json['totalCases']),
      feedback: json['feedback'] as String?,
      aiHelp: json['aiHelp'] is JsonMap ? AIHelp.fromJson(json['aiHelp'] as JsonMap) : null,
    );
  }

  JsonMap toJson() => {
        'score': score,
        'passedCases': passedCases,
        'totalCases': totalCases,
        'feedback': feedback,
        'aiHelp': aiHelp?.toJson(),
      };
}

class Friend {
  const Friend({
    required this.id,
    required this.nickname,
    this.avatar,
    this.level,
    required this.status,
  });

  final String id;
  final String nickname;
  final String? avatar;
  final int? level;
  final String status;

  factory Friend.fromContract(JsonMap json) {
    final profile = json['friend_profile'] as JsonMap? ?? <String, dynamic>{};
    return Friend(
      id: (profile['account_id'] ?? json['id'] ?? '').toString(),
      nickname: (profile['nickname'] ?? '').toString(),
      avatar: profile['avatar_url'] as String?,
      level: profile['level'] == null ? null : _asInt(profile['level']),
      status: (json['status'] ?? '').toString(),
    );
  }

  factory Friend.fromJson(JsonMap json) {
    return Friend(
      id: (json['id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatar: json['avatar'] as String?,
      level: json['level'] == null ? null : _asInt(json['level']),
      status: (json['status'] ?? '').toString(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'nickname': nickname,
        'avatar': avatar,
        'level': level,
        'status': status,
      };
}

class ActivityUser {
  const ActivityUser({
    required this.id,
    required this.nickname,
    this.avatar,
  });

  final String id;
  final String nickname;
  final String? avatar;

  factory ActivityUser.fromContract(JsonMap json) {
    return ActivityUser(
      id: (json['account_id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatar: json['avatar_url'] as String?,
    );
  }

  factory ActivityUser.fromJson(JsonMap json) {
    return ActivityUser(
      id: (json['id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      avatar: json['avatar'] as String?,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'nickname': nickname,
        'avatar': avatar,
      };
}

class Activity {
  const Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.user,
  });

  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final ActivityUser user;

  factory Activity.fromContract(JsonMap json) {
    final payload = json['payload_json'] as JsonMap? ?? <String, dynamic>{};
    return Activity(
      id: (json['id'] ?? '').toString(),
      type: (json['activity_type'] ?? '').toString(),
      description: _activityDescription((json['activity_type'] ?? '').toString(), payload),
      timestamp: _parseDateTime(json['created_at']) ?? DateTime.now(),
      user: ActivityUser.fromContract(
        json['actor_profile'] as JsonMap? ?? <String, dynamic>{},
      ),
    );
  }

  factory Activity.fromJson(JsonMap json) {
    return Activity(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
      user: ActivityUser.fromJson(json['user'] as JsonMap? ?? <String, dynamic>{}),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'user': user.toJson(),
      };
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    this.level,
    required this.xp,
  });

  final int rank;
  final String userId;
  final String nickname;
  final int? level;
  final int xp;

  factory LeaderboardEntry.fromContract(JsonMap json) {
    final profile = json['learner_profile'] as JsonMap? ?? <String, dynamic>{};
    return LeaderboardEntry(
      rank: _asInt(json['rank_position'], fallback: 1),
      userId: (json['learner_id'] ?? '').toString(),
      nickname: (profile['nickname'] ?? '').toString(),
      level: profile['level'] == null ? null : _asInt(profile['level']),
      xp: _asInt(json['current_xp_balance'] ?? json['score']),
    );
  }

  factory LeaderboardEntry.fromJson(JsonMap json) {
    return LeaderboardEntry(
      rank: _asInt(json['rank'], fallback: 1),
      userId: (json['userId'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      level: json['level'] == null ? null : _asInt(json['level']),
      xp: _asInt(json['xp']),
    );
  }

  JsonMap toJson() => {
        'rank': rank,
        'userId': userId,
        'nickname': nickname,
        'level': level,
        'xp': xp,
      };
}

class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.earnedAt,
  });

  final String id;
  final String name;
  final String description;
  final String? icon;
  final DateTime earnedAt;

  factory Badge.fromAwardJson(
    JsonMap json, {
    required String name,
    required String description,
    String? icon,
  }) {
    return Badge(
      id: (json['badge_id'] ?? json['id'] ?? '').toString(),
      name: name,
      description: description,
      icon: icon,
      earnedAt: _parseDateTime(json['awarded_at']) ?? DateTime.now(),
    );
  }

  factory Badge.fromJson(JsonMap json) {
    return Badge(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: json['icon'] as String?,
      earnedAt: _parseDateTime(json['earnedAt']) ?? DateTime.now(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'earnedAt': earnedAt.toIso8601String(),
      };
}

class Reward {
  const Reward({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  final String id;
  final String type;
  final int amount;
  final String description;
  final DateTime timestamp;

  factory Reward.fromLedgerJson(JsonMap json) {
    final type = (json['source_type'] ?? '').toString();
    return Reward(
      id: (json['id'] ?? '').toString(),
      type: type,
      amount: _asInt(json['delta_xp']),
      description: _rewardDescription(type),
      timestamp: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  factory Reward.fromJson(JsonMap json) {
    return Reward(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      amount: _asInt(json['amount']),
      description: (json['description'] ?? '').toString(),
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };
}

class Stats {
  const Stats({
    required this.studyTime,
    required this.coursesCompleted,
    required this.challengesWon,
    required this.currentStreak,
    required this.totalXp,
    this.mastery,
  });

  final int studyTime;
  final int coursesCompleted;
  final int challengesWon;
  final int currentStreak;
  final int totalXp;
  final double? mastery;

  factory Stats.fromPersonalStatsJson(JsonMap json, {double? mastery}) {
    return Stats(
      studyTime: _asInt(json['total_learning_minutes']),
      coursesCompleted: _asInt(json['completed_course_count']),
      challengesWon: _asInt(json['completed_challenge_count']),
      currentStreak: _asInt(json['streak_days']),
      totalXp: _asInt(json['current_xp_balance']),
      mastery: mastery ?? _asDouble(json['mastery']),
    );
  }

  factory Stats.fromJson(JsonMap json) {
    return Stats(
      studyTime: _asInt(json['studyTime']),
      coursesCompleted: _asInt(json['coursesCompleted']),
      challengesWon: _asInt(json['challengesWon']),
      currentStreak: _asInt(json['currentStreak']),
      totalXp: _asInt(json['totalXp']),
      mastery: _asDouble(json['mastery']),
    );
  }

  JsonMap toJson() => {
        'studyTime': studyTime,
        'coursesCompleted': coursesCompleted,
        'challengesWon': challengesWon,
        'currentStreak': currentStreak,
        'totalXp': totalXp,
        'mastery': mastery,
      };
}
