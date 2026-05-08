# Category Filter Implementation

## 2026-05-08

### Observations
- The `Course` model already had `category` field in the constructor/field declaration but it was NOT propagated through factory constructors or `toJson()`.
- The filter UI (FilterSheet) already had category options wired up — only the filter logic and data were missing.
- `_withoutCover` helper in golden tests was missing the `category` parameter.

### Changes Made
1. **app_models.dart**: Added `category:` to `fromListItemJson`, `fromDetailJson`, `fromJson`, and `toJson()`.
2. **mock_data.dart**: Added `category` parameter to `buildCourse()`, assigned categories in `buildCourses()` (frontend/backend/devops/design).
3. **course_list_view.dart**: Replaced TODO with actual category filter logic matching the existing difficulty/progress filter pattern.
4. **page_golden_test.dart**: Added `category: course.category` to `_withoutCover()`.

### Verification
- `flutter analyze --no-pub` — 0 new issues (19 pre-existing warnings/infos)
- `flutter test --no-pub` — all 54 tests pass
