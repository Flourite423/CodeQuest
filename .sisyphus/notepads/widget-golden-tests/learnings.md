# Widget & Golden Test Learnings

## Test Structure
- `test/widgets/shared_widgets_test.dart`: 17 test cases for 7 shared widgets
- `test/widgets/page_golden_test.dart`: 5 test cases (golden + functional)
- `test/goldens/`: 4 golden reference images (PNG)

## Key Patterns Found

### PageStateHost `message` parameter
- `HomeDashboardView` and `ProfileView` do NOT pass `stateMessage` to `PageStateHost`
- Only `CourseListView` passes `message: controller.stateMessage.value`
- Loading state text (e.g. "Loading...") is only visible in CourseListView

### Obx Reactivity in Tests
- Setting Rx values BEFORE `pumpWidget` means Obx may not detect changes if the value matches its initial state
- Pattern: set loading state first → `pumpWidget` → set loaded state → `pump()` → triggers Obx rebuild

### NetworkImage in Tests
- `CircleAvatar` with `NetworkImage` causes HTTP 400 errors in test environment
- These exceptions ARE fatal to individual tests (even though caught by Image Resource Service)
- Workaround: use null avatars in test data to trigger fallback icons

## Pre-existing Issues Found
1. `course_list_view.dart:232` - Meta chip Row overflows at 375px width
2. `profile_view.dart:111` - XP progress Row overflows
3. `profile_view.dart:205` - Stat card Column overflows vertically
4. `profile_view.dart:245` - Badge preview Row overflows
5. `test/widget_test.dart` - Pre-existing file referencing non-existent `MyApp` class (deleted)
