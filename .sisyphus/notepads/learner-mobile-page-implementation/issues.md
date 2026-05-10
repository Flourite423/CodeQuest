- Task 5: `flutter pub get` exceeded both 120s and 600s timeouts while downloading packages in this environment, so final verification used existing `.dart_tool/` state with `flutter analyze --no-pub`.
- F1 audit: Referenced design spec path `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md` is missing from the workspace, so exact spec-to-code comparison had to fall back to the execution plan and requirements draft.
- F1 audit: Remaining compliance gaps are missing filter sheet, achievement preview delivered as bottom sheet instead of fullscreen modal, leftover `/friends` route ownership, and failing direct execution of `mobile/integration_test/app_flow_test.dart`.

- 2026-05-08: F1 audit still cannot be marked PASS because `CourseListController.filteredCourses` leaves the exposed Category filter as a no-op (`TODO`) due to missing `Course.category` data.
