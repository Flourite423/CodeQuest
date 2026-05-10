# Learner Mobile Page Implementation - Decisions

- Task 4: Keep controller inheritance lightweight by introducing a standalone `mobile/lib/controllers/base_controller.dart` instead of refactoring existing view-local controllers immediately.
- Task 4: Put 401 handling in the service/controller base layer so auth-expired redirects do not depend on per-page UI code.
- Task 4: Implement offline detection as a UI-ready placeholder state for now; real connectivity plugin wiring can attach later without changing page contracts.
- Task 5: Use a single learner-facing `app_models.dart` file first to stabilize page implementation imports, with contract-to-UI mapping done in named factory constructors instead of exposing raw OpenAPI field names across widgets.
- Task 5: Treat UI-only fields like `progress`, `isLocked`, `isCompleted`, `mastery`, and badge card copy as explicit inferred/mock projections until learner/shared contracts add safe read models.
- Task 5: Mark rewards as hybrid mock-first because `/learner/rewards` returns ownership and ledger truth sources but does not currently include badge definition metadata required by the page design.
- Task 10: Keep exercise overlays as dedicated view-local widgets (`widgets/submission_result_sheet.dart`, `widgets/ai_help_sheet.dart`) instead of folding sheet markup into the main page, so Task 11 challenge flow can reuse the route-level exercise page without duplicating sheet logic.
- Task 10: Because the mobile package does not include a markdown dependency yet, the prompt area uses a constrained in-file learner-safe markdown renderer rather than adding a new package during workflow implementation.
- Task 10: Register `MockDataService` globally in `AppBinding` because multiple page controllers already call `Get.find<MockDataService>()`; without this, routed learner pages can fail at runtime despite passing static analysis.

- F1 audit: Treated `.sisyphus/plans/learner-mobile-page-implementation.md` as the primary source of truth because the referenced learner page design spec file was absent from the workspace.

- 2026-05-08: Treat plan compliance as requiring both overlay presence and actual exposed filter behavior. A visible filter option that does not affect results remains a compliance blocker.
