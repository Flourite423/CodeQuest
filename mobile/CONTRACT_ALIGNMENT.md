# Learner Mobile Contract Alignment Matrix

## Scope

- Source of truth: `contracts/openapi/openapi.yaml`
- Dictionary guardrails: `contracts/dictionaries/*.md`
- Audience rule: learner/shared only
- Adapter output: `mobile/lib/models/app_models.dart`
- Mock layer: `mobile/lib/services/mock_data.dart`

## Status Legend

- `confirmed`: field exists in learner/shared contract and can be consumed directly
- `inferred`: field is a UI-facing projection derived from contract data or route context
- `missing`: required by the page design, but no learner/shared contract field exists yet

## Forbidden Exposure

The learner adapter layer must never expose these admin-only or hidden-answer fields to UI:

- `course_code`
- `content_version`
- `is_correct`
- `expected_payload_json`

Additional internal-only fields such as `challenge_code`, `badge_code`, audit timestamps, and rule JSON are also intentionally kept out of the app-facing UI models unless a learner page explicitly needs a safe projection.

## Mock-First Summary

Mock-first is required where the current learner/shared contract does not provide a complete page DTO:

- `Home Dashboard`: no composite learner dashboard endpoint
- `Chapter Learning`: no standalone learner chapter endpoint; current route must compose from course detail and local progress state
- `Challenge Detail`: no learner challenge detail endpoint with task list/star rule projection
- `Rewards Center` badge cards: `/learner/rewards` returns award records and XP ledger, but not badge definition fields needed for card copy/iconography
- `Settings`: several design fields are local-only and not covered by contract
- `Filter Sheet`: no filter DTOs defined for courses/rewards
- `Achievement Preview`: no contract for share/preview payload

## Page Alignment Matrix

| 页面 / 覆盖面 | 契约字段 | 状态 | 数据来源 |
| --- | --- | --- | --- |
| Splash | local auth flag, onboarding flag | confirmed | `StorageService` local-first |
| Onboarding | local completion flag | confirmed | `StorageService` local-first |
| Login | `email`, `password`, `device_id`, `platform` from `LearnerLoginRequest`; response `Account` + `LearnerProfile` | confirmed | `/auth/learner/login`, real-api-first |
| Register | `email`, `password`, `nickname`, `device_id`, `platform` from `LearnerRegisterRequest`; response `Account` + `LearnerProfile` | confirmed | `/auth/register`, real-api-first |
| Home Dashboard | `nickname`, `total_xp`, `streak_days`, `daily_goal_minutes` from `LearnerProfile`; `current_xp_balance`, `current_rank`, `completed_course_count`, `completed_challenge_count`, `total_learning_minutes` from `LearnerPersonalStats`; hero progress cards | mixed: confirmed + missing | `/learner/profile` + `/learner/stats/personal` + mock composition, mock-first |
| Courses List | `id`, `title`, `summary`, `cover_image_url`, `difficulty`, `estimated_minutes` from `LearnerCourseListItem`; card progress | confirmed + inferred | `/learner/courses`, real-api-first; `progress` stays adapter-derived |
| Course Detail | `id`, `title`, `summary`, `description`, `cover_image_url`, `difficulty`, `estimated_minutes`, `chapters[]` from `LearnerCourseDetail` | confirmed + inferred | `/learner/courses/{course_id}`, real-api-first; chapter lock/completion state adapter-derived |
| Chapter Learning | `title`, `summary`, `learning_content_markdown`, `sample_code` from `LearnerCourseDetail.chapters[]`; completion flag, lock state, exercise card | mixed: confirmed + inferred + missing | composed from `/learner/courses/{course_id}` + local state, mock-first |
| Exercise Workspace | `exercise.prompt`, `exercise.exercise_type`, `exercise.starter_code`, `visible_test_cases[]` from `LearnerExerciseDetail` | confirmed | `/learner/exercises/{exercise_id}`, real-api-first |
| Submission Result Sheet | `score`, `passed_case_count`, `total_case_count`, `error_summary` from `Submission`; AI response text from `AIHelpRequest` | confirmed + inferred | `/learner/submissions`, `/learner/submissions/{submission_id}`, `/learner/ai/help`, real-api-first |
| AI Help Sheet | `request_type`, `status`, `response_text`, `response_structured_json` from `AIHelpRequest` | confirmed | `/learner/ai/help`, real-api-first |
| Challenges Map | `challenge_id`, `title`, `difficulty`, `learner_status`, `best_star`, `reward_xp`, `stage_count`, `completed_stage_count` from `LearnerChallengeMapItem` | confirmed | `/learner/challenges`, real-api-first |
| Challenge Detail | challenge summary fields from `LearnerChallengeMapItem`; task list, star rule explanation, reward breakdown | mixed: confirmed + missing | `/learner/challenges` seed data + mock task projection, mock-first |
| Daily Challenge | `title`, `time_limit_seconds`, `reward_xp`, `status` from `DailyChallenge`; `status`, `score`, `elapsed_seconds`, `streak_after_completion` from `DailyChallengeRecord` | confirmed + inferred | `/learner/daily-challenges/today` and submit endpoint, real-api-first |
| Social / Activity | `activity_type`, `payload_json`, `created_at`, `actor_profile` from `LearnerActivityFeedItem` | confirmed + inferred | `/learner/activities`, real-api-first |
| Social / Friends | `status`, `friend_profile.account_id`, `friend_profile.nickname`, `friend_profile.avatar_url` from `LearnerFriendListItem`; level chip | confirmed + missing | `/learner/friends`, real-api-first with mock level until contract extends |
| Social / Leaderboard | `rank_position`, `learner_id`, `learner_profile.nickname`, `current_xp_balance`, `badge_count`, `is_current_user` from `LearnerRankItem`; level chip | confirmed + missing | `/learner/leaderboards`, real-api-first with mock level until contract extends |
| Profile Center | `nickname`, `avatar_url`, `bio`, `theme_mode`, `daily_goal_minutes`, `streak_days`, `total_xp`, `current_level`, `friend_count` from `LearnerProfile`; stat tiles from `LearnerPersonalStats`; badge preview from rewards | mixed: confirmed + missing | `/learner/profile`, `/learner/stats/personal`, `/learner/rewards`, hybrid with mock badge metadata |
| Stats Detail | `current_rank`, `current_xp_balance`, `lifetime_xp_earned`, `completed_course_count`, `completed_challenge_count`, `ai_help_request_count`, `total_learning_minutes`, `streak_days` from `LearnerPersonalStats`; mastery chart | confirmed + missing | `/learner/stats/personal`, real-api-first with mock `mastery` |
| Rewards Center | summary `current_xp_balance`, `lifetime_xp_earned`, `badge_count`; `xp_ledger[]` from `XpLedger`; badge ownership from `LearnerBadge` | mixed: confirmed + missing | `/learner/rewards`, hybrid mock-first for badge names/descriptions/icons |
| Achievement Preview Overlay | earned badge summary card | missing | mock-first only |
| Edit Profile | `nickname`, `avatar_url`, `bio`, `theme_mode`, `daily_goal_minutes` from `LearnerProfile` and `LearnerProfileUpdateInput` | confirmed | `/learner/profile` GET/PATCH, real-api-first |
| Settings | `theme_mode`, `daily_goal_minutes` from `LearnerProfile`; AI hint switch, difficulty preference, cache controls, help/about | mixed: confirmed + missing | profile endpoint + local settings, mock-first |
| Filter Sheet Overlay | course and reward filter selections | missing | local state + mock-first |

## Adapter Notes

### User

- `User.id` ← `LearnerProfile.account_id`
- `User.email` ← `Account.email`
- `User.level` ← `LearnerProfile.current_level`
- `User.xp` ← `LearnerProfile.total_xp`
- `User.streak` ← `LearnerProfile.streak_days`
- `User.dailyGoal` ← `LearnerProfile.daily_goal_minutes`
- `User.themeMode` ← `LearnerProfile.theme_mode`

### Course / Chapter

- `Course` consumes only learner DTOs (`LearnerCourseListItem`, `LearnerCourseDetail`)
- `Course.progress` is an inferred UI projection and intentionally not read from admin/internal fields
- `Chapter.isCompleted` and `Chapter.isLocked` are adapter-level projections; canonical chapter contract does not expose completion booleans

### Exercise / Submission / AI

- `Exercise.description` ← `Exercise.prompt`
- `Exercise.codeTemplate` ← `Exercise.starter_code`
- `Exercise.testCases[]` uses learner-visible public test cases only
- `SubmissionResult.feedback` currently maps to `Submission.error_summary`; richer learner-facing copy remains inferred

### Challenge / Daily / Rewards

- `Challenge.description` currently maps from learner-safe summary text
- `Challenge.tasks[]` is mock-first until learner detail projection exists
- `DailyChallenge.description` is inferred UI copy because the current contract only supplies `title`
- `Badge` card metadata is mock-enriched because `/learner/rewards` returns `LearnerBadge` ownership records without badge definition copy/icon fields

### Social / Stats

- `Friend.level`, `LeaderboardEntry.level`, and `Stats.mastery` are not present in learner/shared contract today and must stay documented as missing/inferred
- Leaderboard XP must come from server-derived read models; client must not recompute rank scores locally

## Exposure Guardrail Checklist

- Learner models do not include admin-only identifiers or hidden answer fields
- Learner adapters only consume learner/shared schemas
- Missing fields are documented instead of invented as real contract fields
- Mock-first pages are explicitly marked so later endpoint work has a clear handoff
