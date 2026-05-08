# Learner Mobile Page Implementation - Learnings

## Project Conventions
- Framework: Flutter 3.x + GetX + ScreenUtil
- Design basis: 375x812, 12px radius
- Each page: View + Controller + Binding in single file
- State: .obs + Obx()
- Navigation: Get.toNamed(), Get.offAllNamed()
- Theme: Material 3, ColorScheme.fromSeed(seedColor: 0xFF2196F3)

## Current Issues
- Route inconsistency: ProfileView/LeaderboardView inline in home_view.dart AND standalone in app_pages.dart
- Current shell: 4 tabs (Courses/Challenges/Ranking/Profile)
- Target shell: 5 tabs (Home/Courses/Challenges/Social/Profile)
- Leaderboard should move into Social tab as segmented content

## Key Decisions
- Auth: Email+password (replace phone verification placeholder)
- Shell: IndexedStack with 5 tabs, persistent state
- Shared widgets: empty/error/loading/CTA/card/rank-row states
- Page states: loading/empty/error/offline/auth_expired/partial_data
- Contract-first: mock-first strategy for pages with unstable APIs

## Color System
- Primary: #4F46E5 (from design spec, may need to update theme)
- Success: #22C55E
- Current theme uses 0xFF2196F3 (Material Blue)

## Mobile Ergonomics
- Safe margin: 16
- Primary button height: 56
- Input height: 52
- Min touch target: 48x48
- Primary actions in lower screen half
- List item min height: 56

- Task 4: Added `BaseController` for shared GetX page states (`initial/loading/empty/error/offline/authExpired/partialData`) with standardized retry registration.
- Task 4: Added `PageStateHost` to map shared page states to reusable Task 3 widgets plus dedicated offline/auth-expired/partial-data UI.
- Task 4: Centralized unauthorized handling in `ApiService` 401 interceptor and `BaseController.handleUnauthorized()`, clearing stored auth token before redirecting to `/login`.
- Task 5: Added `mobile/lib/models/app_models.dart` as the learner-safe adapter layer and kept admin-only / hidden-answer fields (`course_code`, `content_version`, `is_correct`, `expected_payload_json`) out of mobile UI models.
- Task 5: Added `mobile/CONTRACT_ALIGNMENT.md` covering every learner page and overlay with `confirmed / inferred / missing` status plus mock-first vs real-api-first decisions.
- Task 5: Confirmed direct learner/shared endpoints exist for courses, profile, friends, activities, leaderboards, personal stats, challenges, daily challenge, rewards, exercise detail, submissions, and AI help; Home, Chapter detail composition, Challenge detail, Rewards badge metadata, Settings extras, and overlay filters still need mock-first support.
- Task 10: Implemented `mobile/lib/views/exercise/exercise_view.dart` as a full learner workspace using `BaseController` + `PageStateHost`, with single-choice and coding modes sharing the same submit/help flow.
- Task 10: Learner-safe exercise UI only renders prompt, starter code, public test case names/types/input payloads, aggregate submission feedback, and hint-style AI text; it never surfaces `is_correct`, hidden assertions, or admin-only expected payloads.
- Task 10: Coding drafts persist locally via `StorageService/GetStorage` under per-exercise keys, so offline typing and restart recovery work without network dependencies.

- Task 18: Expanded , , , and rebuilt  to cover shared widgets plus representative Home/Courses/Challenges/Social/Profile states and goldens at 375x812.
- Task 18: Golden/widget tests are stable when loaded-state fixtures strip network-backed avatars/covers/badge icons and use local fake  overrides that no-op  to avoid  plugin initialization in tests.
- Task 18: Fixing phone-width overflows required replacing rigid metadata/action rows with  and more  usage in course/challenge/social/profile/rank-row layouts; this keeps top-level tabs render-safe on 375x812 without changing page behavior.

- Task 18 (corrected): Expanded mobile/test/widgets/shared_widgets_test.dart, mobile/test/widgets/page_state_host_test.dart, mobile/test/widgets/base_controller_test.dart, and rebuilt mobile/test/widgets/page_golden_test.dart to cover shared widgets plus representative Home/Courses/Challenges/Social/Profile states and goldens at 375x812.
- Task 18 (corrected): Golden/widget tests are stable when loaded-state fixtures strip network-backed avatars, covers, and badge icons, and when fake StorageService test doubles override onInit() so GetStorage does not initialize plugins during tests.
- Task 18 (corrected): Fixing phone-width overflows required replacing rigid metadata and action rows with Wrap plus Expanded/Flexible in course, challenge, social, profile, and rank-row layouts, which keeps top-level tabs render-safe on 375x812 without changing page behavior.

- F2 Code Quality Review: All data-page controllers (16/16) consistently extend BaseController and use PageStateHost. SocialView is the gap — controller extends BaseController but view does not use PageStateHost.
- F2 Code Quality Review: Forbidden fields audit found zero data leaks; only a Chinese disclaimer string references `is_correct` as text.
- F2 Code Quality Review: FriendsView is a 59-line hardcoded stub that doesn't use the Friend model, BaseController, or PageStateHost — marked as tech debt.
- F2 Code Quality Review: Touch target audit found 2 buttons (friend Accept/Decline) set to 36.h minimumSize, below the 48dp mobile ergonomics minimum.
- F2 Code Quality Review: Flutter analyze passes with 0 errors in lib/ code; all 6 warnings are in test/ files.
- F2 Code Quality Review: Test coverage includes 5 unit test files and 1 integration test (717 lines), but individual page controller unit tests are missing.

- F1 audit: `flutter test --no-pub` only verified widget/unit suites in this workspace; the standalone integration suite requires direct execution and currently fails, so passing test counts alone overstate final verification readiness.

## F3 Real Manual QA Findings
- Widget tests: 54/54 pass covering all shared widgets, page states, golden baselines, and representative page compositions for all 5 tabs
- Golden images: 12 valid PNGs at 1125x2436 (3x @ 375x812), covering shared states + Home/Courses/Challenges/Social/Profile
- Integration tests: Cannot execute due to `pumpAndSettle` + `CircularProgressIndicator` incompatibility in `SplashView` - known Flutter testing limitation
- Integration test code is correctly structured with 9 scenarios covering auth, tab switching, detail flows, overlays, and failure paths
- Flow coverage mapping: 4/9 scenarios fully covered by widget tests, 3/9 partially covered, 2/9 not directly covered (register, locked challenge)

- Task FilterSheet: Implemented `mobile/lib/widgets/shared/filter_sheet.dart` as a reusable bottom sheet for list filtering.
- Task FilterSheet: FilterSheet uses `BottomSheetScaffold` with `FilterSection` (chip groups) and `FilterOption` models, supporting both single and multi-select via `FilterChip`.
- Task FilterSheet: Sheet manages temporary local selection state (`_localSelections`) and only commits to controller on Apply; Reset clears local state and dispatches empty sets.
- Task FilterSheet: Added course filters (Difficulty/Category/Progress) to `CourseListController` with RxString state and reactive `filteredCourses` getter.
- Task FilterSheet: Added reward filters (Type/Time Range) to `ProfileRewardsController` with reactive `filteredRewards` getter and time-range comparison logic.
- Task FilterSheet: Added filter icon buttons with Material `Badge` indicator to both CourseListView and ProfileRewardsView app bars.
- Important: Material's `Badge` widget conflicts with app_models `Badge` class — use `hide Badge` on the models import to resolve.
- Important: Golden tests need updating when app bar icons change (`flutter test --update-goldens`).
- Verified: `flutter analyze --no-pub` passes with 0 errors in lib/ code (19 total issues, all pre-existing).
- Verified: `flutter test --no-pub` passes with 54/54 tests after golden update.

## 2026-05-08: F4 Scope Fidelity Re-audit — Filter Sheet Implementation

- FilterSheet implemented at `mobile/lib/widgets/shared/filter_sheet.dart`
- Uses BottomSheetScaffold with multi-select FilterChip sections, Apply/Reset actions
- Integrated in CourseListView (Difficulty/Category/Progress) and ProfileRewardsView (Type/Time Range)
- BadgePreviewSheet (achievement preview) already existed in profile_rewards_view.dart but was missed in the initial audit
- All 4 overlays now confirmed PRESENT
- No prohibited features added, no admin field leakage
- Verdict updated: CONDITIONAL PASS → PASS
- Only remaining minor concern: `admin_adjustment` display label string in app_models.dart and profile_rewards_view.dart

- 2026-05-08: Re-ran F1 compliance audit after Filter Sheet work. Shared `FilterSheet` widget now exists and is integrated into both Courses and Rewards views; rewards filters are behaviorally wired through computed lists.
