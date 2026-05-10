# Learner Mobile Page Implementation Plan

## TL;DR
> **Summary**: Implement the full learner-side mobile page system for the Flutter/GetX app using the completed page design spec as the single UI source of truth, while normalizing the current route tree, aligning all page data to contracts, and enforcing mobile-first ergonomics and executable QA.
> **Deliverables**:
> - Full learner-side route/page/modal structure matching `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md`
> - Shared mobile UI foundation (shell, cards, states, CTA patterns, bottom sheets)
> - Contract-aligned page data adapters and mock/real data integration strategy
> - Widget/integration/golden verification for tabs, detail pages, auth flow, error states, and route behavior
> **Effort**: XL
> **Parallel**: YES - 6 waves
> **Critical Path**: Route normalization → shared UI/state foundation → tab pages → detail/workflow pages → auth/profile/settings/rewards/social completion → verification

## Context
### Original Request
基于需求和辅助文档先设计移动端 learner 页面，并继续推进为正式执行计划。

### Interview Summary
- Scope fixed to full learner-side page system, not admin.
- Detail level fixed to high-detail, text-reconstructable layouts.
- Visual direction fixed to modern learning-growth, clean + light gamification.
- Mobile ergonomics explicitly required: all layout and components must be phone-first and thumb-friendly.
- User selected the “turn this into a formal execution plan” path.

### Metis Review (gaps addressed)
- Add explicit route normalization plan to resolve current `ProfileView`/`LeaderboardView` ownership inconsistency.
- Add contract alignment matrix and page ownership rules so implementers do not infer fields or page/modal boundaries.
- Add shared widget/state foundation tasks before page implementation to prevent repetition.
- Add explicit mock-vs-real API strategy and route return-stack verification.
- Add executable QA for every top-level tab, detail page, auth branch, and failure path.

## Work Objectives
### Core Objective
Build a decision-complete implementation plan for the learner-side Flutter app so an executor can implement the entire mobile page system exactly as specified in `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md`, without making new IA, routing, UX, or state decisions.

### Deliverables
- Normalized learner route tree for all page and overlay destinations.
- 5-tab learner shell: Home / Courses / Challenges / Social / Profile.
- Full learner page set:
  - Splash, Onboarding, Login, Register
  - Home Dashboard
  - Courses list, course detail, chapter learning, exercise workspace
  - Challenge map, challenge detail, daily challenge
  - Social center
  - Profile center, stats detail, rewards center, edit profile, settings
  - Overlays: submission result sheet, AI help sheet, filter sheet, achievement card fullscreen preview
- Shared widget/layout/state system for phone-first UI.
- Contract mapping per page for fields, state enums, and error handling.
- Automated verification artifacts and test coverage plan.

### Definition of Done (verifiable conditions with commands)
- `flutter analyze` passes in `mobile/` with zero errors.
- `flutter test` passes for shared widgets, state widgets, and page/controller logic.
- `flutter test test/widgets/...` covers all top-level tabs, auth pages, and detail page route entry.
- `flutter test integration_test/...` verifies login flow, tab switching, detail navigation, bottom-sheet presentation, and auth-expired redirect.
- Golden tests exist for shared empty/error/loading/CTA widgets and at least one representative page per top-level tab.
- Route ownership matches the plan: no inline `ProfileView`/`LeaderboardView` leakage inside unrelated file ownership after normalization.

### Must Have
- Follow `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md` exactly for page boundaries, hierarchy, ergonomics, and wireframe intent.
- Keep implementation learner-side only.
- Preserve Material 3, 12px radius baseline, 375x812 design basis, and mobile ergonomics constraints.
- Use contract-first consumption: learner/shared audience only.
- Provide loading / empty / error / offline / auth-expired behavior consistently across pages.
- Use executable QA only.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No admin/web/teacher implementation.
- No product expansion into chat, forum, push center, external sharing, video course, code completion, AI continuous chat, or forgotten-password flow not covered by contract.
- No architecture rewrite beyond learner route/page normalization.
- No desktop-first layouts, dense multicolumn forms, or tablet-dependent IA.
- No contract guessing for admin-only or hidden fields (`course_code`, `content_version`, `is_correct`, hidden test assertions, etc.).
- No vague “looks right” acceptance criteria.

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: tests-after + Flutter widget tests + integration tests + golden tests
- QA policy: Every task includes agent-executed scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: Route normalization + shell + shared foundation + contract mapping
Wave 2: Auth/onboarding + Home + Courses foundation
Wave 3: Chapter learning + Exercise workflow + Challenge foundation
Wave 4: Daily challenge + Social center + Profile foundation
Wave 5: Stats + Rewards + Edit Profile + Settings + remaining overlays
Wave 6: Test/golden/integration completion + contract alignment hardening

### Parallel Execution Waves Details
- Wave 1 creates all shared prerequisites so downstream page tasks avoid duplicated routing/state/widget work.
- Wave 2 establishes user entry and the first two high-frequency learner paths: auth and course discovery.
- Wave 3 completes the study core loop: learn → practice → challenge.
- Wave 4 adds re-engagement and community loops: daily challenge, social, profile hub.
- Wave 5 finishes secondary detail surfaces and account management.
- Wave 6 locks regression safety through automated verification.

### Dependency Matrix (full, all tasks)
- T1 blocks all route-aware tasks.
- T2/T3/T4 block nearly all page implementation tasks.
- T5 blocks T6-T18 where contract-bound fields/states are consumed.
- T6/T7 block T8/T9.
- T8 blocks T10 and O1/O2 behavior finalization.
- T9 blocks T10.
- T10 blocks T11 and parts of T16.
- T11 blocks T16.
- T12 blocks T13/T14/T15/T17 only for navigation handoff completion, not initial scaffolding.
- T13 blocks T14/T15/T17.
- T18/T19 depend on all implementation tasks.
- Final verification depends on every implementation and test task.

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 5 tasks → deep / quick / unspecified-high / visual-engineering
- Wave 2 → 3 tasks → visual-engineering / unspecified-high
- Wave 3 → 3 tasks → visual-engineering / unspecified-high
- Wave 4 → 3 tasks → visual-engineering / unspecified-high
- Wave 5 → 5 tasks → visual-engineering / quick
- Wave 6 → 2 tasks → unspecified-high / quick

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. Normalize learner route tree and page ownership

  **What to do**: Replace the current ad hoc route ownership with a normalized learner route map matching the design spec. Explicitly define top-level tab hosts, push pages, bottom sheets, and fullscreen modal destinations. Fix the current inconsistency where `ProfileView` and `LeaderboardView` are inline widgets in `home_view.dart` while also being referenced as standalone routed pages in `app_pages.dart`. Decide and implement a single ownership model per destination.
  **Must NOT do**: Do not redesign IA. Do not add routes not listed in the design spec. Do not modify admin or backend code.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: route normalization touches app structure and must avoid regressions.
  - Skills: [] - no special project skill matches; use repo conventions and draft as source.
  - Omitted: [`frontend-design`] - Reason: this is structural routing work, not visual styling.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 6,7,8,9,10,11,12,13,14,15,16,17,18,19 | Blocked By: none

  **References**:
  - Pattern: `mobile/lib/routes/app_pages.dart` - current GetPage registration pattern and current route names.
  - Pattern: `mobile/lib/views/home/home_view.dart` - current tab shell and inline `LeaderboardView` / `ProfileView` ownership bug.
  - Pattern: `mobile/lib/main.dart` - `GetMaterialApp`, route bootstrap, and app shell entry.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:15-24` - locked navigation and page/modal ownership.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:43-60` - app launch flow and deep link expectations.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `mobile/lib/routes/app_pages.dart` contains a route structure that maps every page in the Page Inventory and does not reference nonexistent bindings.
  - [ ] `grep -n "ProfileBinding\|LeaderboardBinding" mobile/lib/routes/app_pages.dart` returns only valid, implemented ownership references.
  - [ ] No top-level destination is still defined only as an inline widget inside an unrelated file when the route plan requires standalone ownership.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: Route ownership normalization succeeds
    Tool: Bash
    Steps: Run `flutter analyze` in `mobile/`; run `grep -n "ProfileView\|LeaderboardView\|ProfileBinding\|LeaderboardBinding" mobile/lib/routes/app_pages.dart mobile/lib/views/home/home_view.dart`
    Expected: Analyzer reports no route ownership errors; grep output matches the normalized plan without orphan bindings
    Evidence: .sisyphus/evidence/task-1-route-normalization.txt

  Scenario: Auth and tab routes respect intended entry structure
    Tool: Bash
    Steps: Run widget/integration tests covering startup route selection and tab shell route registration
    Expected: Tests pass and confirm unauthenticated app enters auth flow while authenticated app enters learner shell
    Evidence: .sisyphus/evidence/task-1-route-normalization-tests.txt
  ```

  **Commit**: YES | Message: `refactor(mobile): normalize learner route ownership` | Files: `mobile/lib/routes/**`, `mobile/lib/views/**`, `mobile/lib/main.dart`

- [x] 2. Build the learner app shell and navigation foundation

  **What to do**: Implement the 5-tab learner shell (Home / Courses / Challenges / Social / Profile) with IndexedStack or equivalent persistent state behavior, consistent app bar strategy, safe-area handling, and mobile-first bottom navigation. Replace current 4-tab shell and move leaderboard into Social segmented content per spec.
  **Must NOT do**: Do not introduce tablet-only navigation patterns or redesign the tab list.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: this is the shared mobile page container and navigation UX base.
  - Skills: [`frontend-design`] - useful for polished, production-grade mobile shell composition.
  - Omitted: [`playwright`] - browser-only, not relevant to Flutter implementation.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 12,13,14,15,16,17 | Blocked By: 1

  **References**:
  - Pattern: `mobile/lib/views/home/home_view.dart` - current bottom navigation + IndexedStack baseline.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:15-18` - locked top-level tabs.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:235-259` - Home dashboard shell behavior.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:610-813` - phone-first wireframe annotations.
  - Guidance: Metis finding - keep top-level route ownership fixed and do not over-rewrite architecture.

  **Acceptance Criteria** (agent-executable only):
  - [ ] Learner shell renders 5 top-level destinations and preserves tab state on switch.
  - [ ] Navigation shell uses phone-first sizing and bottom navigation with safe-area support.
  - [ ] Widget tests verify tab switching and return behavior.

  **QA Scenarios**:
  ```
  Scenario: Five-tab shell renders and switches correctly
    Tool: Bash
    Steps: Run `flutter test test/widgets/learner_shell_test.dart`
    Expected: Tests assert 5 tabs, current tab state preservation, and correct default authenticated landing tab
    Evidence: .sisyphus/evidence/task-2-learner-shell.txt

  Scenario: Tab return behavior stays within learner shell
    Tool: Bash
    Steps: Run integration test that navigates from Home to Courses to Challenge detail and back
    Expected: Back returns to the correct owning tab/page stack rather than a wrong tab or root route
    Evidence: .sisyphus/evidence/task-2-learner-shell-nav.txt
  ```

  **Commit**: YES | Message: `feat(mobile): add learner navigation shell` | Files: `mobile/lib/views/home/**`, `mobile/lib/routes/**`, `mobile/test/widgets/**`

- [x] 3. Create shared mobile layout, state, and CTA component system

  **What to do**: Implement the reusable shared widgets and layout primitives implied by the page spec: app bars, section headers, empty/error/loading states, primary/secondary CTA bars, list cards, stat tiles, badge cards, rank rows, bottom sheet scaffolds, and safe-area CTA containers. Standardize spacing, radius, state visuals, and mobile ergonomics so pages do not reimplement them independently.
  **Must NOT do**: Do not build page-specific business logic into shared widgets. Do not add generic component libraries not required by the spec.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: shared UI primitives drive page consistency and mobile ergonomics.
  - Skills: [`frontend-design`] - reason: component polish and reusable visual quality.
  - Omitted: [`review-work`] - post-implementation review belongs to final verification, not component authoring.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 6,7,8,9,10,11,12,13,14,15,16,17,18,19 | Blocked By: none

  **References**:
  - Pattern: `mobile/lib/themes/app_theme.dart` - current Material 3 theme baseline.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:33-41` - global size locks.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:92-118` - complex component specs.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:610-813` - wireframe sizing for shared rows/cards.
  - Guidance: `bg_577dc3ee` summary - use Material 3, 48x48 targets, bottom-priority CTA placement, one main scroll axis.

  **Acceptance Criteria**:
  - [ ] Shared empty, error, loading, CTA, card, and rank-row widgets exist and are reusable across pages.
  - [ ] Golden/widget tests cover at least empty state, error state, loading state, CTA bar, and one list-card variant.
  - [ ] Theme usage aligns with Material 3 and the locked color/radius system.

  **QA Scenarios**:
  ```
  Scenario: Shared UI states render consistently
    Tool: Bash
    Steps: Run `flutter test test/widgets/shared_states_test.dart`
    Expected: Empty, error, loading, and CTA widgets render expected copy and controls
    Evidence: .sisyphus/evidence/task-3-shared-states.txt

  Scenario: Shared UI golden baselines pass
    Tool: Bash
    Steps: Run golden tests for card/list/CTA widgets
    Expected: Golden tests pass for phone-sized rendering without overflow
    Evidence: .sisyphus/evidence/task-3-shared-goldens.txt
  ```

  **Commit**: YES | Message: `feat(mobile): add shared learner UI primitives` | Files: `mobile/lib/widgets/**`, `mobile/lib/themes/**`, `mobile/test/widgets/**`

- [x] 4. Implement unified page state handling strategy

  **What to do**: Create the app-wide learner page-state pattern for `loading / empty / error / offline / auth_expired / partial_data`, including UI components, controller conventions, and refresh/retry behavior. Ensure every page can adopt the same structure and that auth expiration redirects cleanly to the login flow.
  **Must NOT do**: Do not leave state handling ad hoc per page. Do not rely on text-only placeholders without reusable patterns.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: this combines controller structure, route behavior, and reusable UX states.
  - Skills: []
  - Omitted: [`frontend-design`] - state architecture is primary; shared visuals come from task 3.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 6,7,8,9,10,11,12,13,14,15,16,17,18,19 | Blocked By: 3

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:76-90` - global state rules.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:815-835` - required happy/failure path matrix.
  - Contracts: `contracts/dictionaries/practice-fields.md:93-115` - submission and AI failure state semantics.
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:115-151` - challenge/daily terminal states.
  - Contracts: `contracts/README.md` - contract-first consumer discipline.

  **Acceptance Criteria**:
  - [ ] Reusable page-state pattern exists and can represent loading, empty, error, offline, auth-expired, and partial-data cases.
  - [ ] Unauthorized state triggers a tested redirect path to login.
  - [ ] Retry/refresh behavior is standardized and tested.

  **QA Scenarios**:
  ```
  Scenario: Standard learner page states render correctly
    Tool: Bash
    Steps: Run `flutter test test/widgets/page_state_host_test.dart`
    Expected: Each state renders the expected UI and action callbacks without overflow
    Evidence: .sisyphus/evidence/task-4-page-states.txt

  Scenario: Auth-expired state redirects to login
    Tool: Bash
    Steps: Run integration or controller test simulating a 401 from a protected page
    Expected: User is redirected to login and protected content no longer renders
    Evidence: .sisyphus/evidence/task-4-auth-expired.txt
  ```

  **Commit**: YES | Message: `feat(mobile): standardize learner page states` | Files: `mobile/lib/controllers/**`, `mobile/lib/widgets/**`, `mobile/test/**`

- [x] 5. Build contract alignment matrix and data adapter layer

  **What to do**: For every learner page, map the UI-required fields to the existing learner/shared contract schemas, document `confirmed / inferred / missing` fields, and implement the adapter/model layer required by the Flutter UI. Define which pages can use contract-conformant mock data first and which must wire to real endpoints immediately. Ensure hidden/admin-only fields are never exposed to UI.
  **Must NOT do**: Do not let page implementation invent fields. Do not consume admin-only contract shapes. Do not skip missing-field documentation.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: contract alignment is high-risk and drives many downstream tasks.
  - Skills: []
  - Omitted: [`salvo-openapi`] - backend OpenAPI generation is not the task; consumer-side mapping is.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 6,7,8,9,10,11,12,13,14,15,16,17 | Blocked By: none

  **References**:
  - Contracts: `contracts/openapi/openapi.yaml` - learner/shared routes and schemas.
  - Contracts: `contracts/dictionaries/course-fields.md:46-86` - learner DTO boundary for courses/chapters.
  - Contracts: `contracts/dictionaries/practice-fields.md:7-115` - exercise/submission/AI field visibility and hidden-case rules.
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:7-151` - challenge, daily, XP, badges, source-of-truth rules.
  - Contracts: `contracts/dictionaries/social-profile-fields.md:3-64` - friends/activity/leaderboard/profile boundaries.
  - Contracts: `contracts/dictionaries/stats-metrics.md:5-56` - stats and leaderboard derivation rules.
  - Example: `contracts/examples/learner-course-list.json` - list response envelope pattern.

  **Acceptance Criteria**:
  - [ ] A contract alignment artifact exists for every page and overlay destination.
  - [ ] Mock-first vs real-API-first strategy is explicitly defined per page.
  - [ ] Adapter/model layer compiles and excludes admin-only / hidden fields.

  **QA Scenarios**:
  ```
  Scenario: Contract alignment matrix covers all learner pages
    Tool: Bash
    Steps: Read generated contract mapping artifacts and run grep checks for each Page Inventory item
    Expected: Every page has a corresponding mapping entry and data source decision
    Evidence: .sisyphus/evidence/task-5-contract-alignment.txt

  Scenario: Hidden/admin-only fields never appear in learner adapters
    Tool: Bash
    Steps: Run grep for `course_code|content_version|is_correct|expected_payload_json` across learner UI models/widgets
    Expected: No forbidden admin/hidden fields are consumed in learner page UI
    Evidence: .sisyphus/evidence/task-5-forbidden-fields.txt
  ```

  **Commit**: YES | Message: `feat(mobile): add learner contract adapters` | Files: `mobile/lib/models/**`, `mobile/lib/services/**`, `mobile/lib/repositories/**`, `mobile/test/**`

- [x] 6. Implement startup and auth flow pages

  **What to do**: Implement Splash, Onboarding, Login, and Register pages according to the page spec and normalized auth flow. Ensure startup routing, email/password form validation, auth error states, and successful transition into the learner shell are consistent with the spec and contracts.
  **Must NOT do**: Do not keep the phone-number verification placeholder as the final auth model. Do not add forgot-password flow unless contract support is explicitly introduced later.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: these are user-facing mobile pages with strong form ergonomics and auth transitions.
  - Skills: [`frontend-design`] - for polished mobile auth/onboarding UX.
  - Omitted: [`playwright`] - browser-only.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: none beyond auth-dependent detail tests | Blocked By: 1,2,3,4,5

  **References**:
  - Existing: `mobile/lib/views/splash/splash_view.dart`, `mobile/lib/views/login/login_view.dart` - current starter patterns.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:149-233` - P01-P04 page definitions.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:618-657` - W01-W04 auth wireframe sizing.
  - SRS: `doc/软件需求规格说明书.md:244-334` - registration/login/profile business rules and errors.
  - Metis: lock auth to email+password and keep startup flow explicit.

  **Acceptance Criteria**:
  - [ ] Unauthenticated startup lands in auth flow after splash/onboarding gating.
  - [ ] Login/register forms validate inputs and show correct failure states.
  - [ ] Success path enters learner shell and preserves auth session handling contract.

  **QA Scenarios**:
  ```
  Scenario: Unauthenticated startup flow works
    Tool: Bash
    Steps: Run integration test covering splash -> onboarding (first launch) -> login
    Expected: App routes correctly and onboarding is skipped on later launches when flag exists
    Evidence: .sisyphus/evidence/task-6-auth-startup.txt

  Scenario: Login and register failure states render correctly
    Tool: Bash
    Steps: Run widget tests with mocked invalid email, duplicate email, 401, suspended account, and offline responses
    Expected: Correct inline validation/error cards appear and no wrong navigation occurs
    Evidence: .sisyphus/evidence/task-6-auth-errors.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement learner auth flow` | Files: `mobile/lib/views/auth/**`, `mobile/lib/controllers/**`, `mobile/test/**`, `mobile/integration_test/**`

- [x] 7. Implement Home dashboard page

  **What to do**: Implement the Home dashboard as the learner re-entry page, with the exact module stack defined in the spec: greeting header, streak pill, today growth hero, daily challenge card, continue-learning card, weekly stats grid, friend activity preview, and badge preview. Support partial failures without collapsing the whole page.
  **Must NOT do**: Do not turn Home into a substitute for Courses/Challenges/Social full functionality. Do not move primary actions to the top-only area.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: dashboard composition and mobile hierarchy matter.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: none | Blocked By: 2,3,4,5

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:235-259` - Home dashboard structure.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:659-670` - Home wireframe annotation.
  - Contracts: stats/reward/social dictionaries for card data semantics.
  - Existing: `mobile/lib/views/home/home_view.dart` - starter shell file.

  **Acceptance Criteria**:
  - [ ] Home renders all spec-required modules in order.
  - [ ] Continue-learning action routes to the most recent unfinished chapter.
  - [ ] Partial module failure degrades locally instead of blanking the full page.

  **QA Scenarios**:
  ```
  Scenario: Home dashboard happy path renders all modules
    Tool: Bash
    Steps: Run widget test with mocked successful dashboard data
    Expected: Greeting, hero card, daily challenge card, continue-learning card, stats grid, activity preview, and badge preview are all present in order
    Evidence: .sisyphus/evidence/task-7-home-happy.txt

  Scenario: Home partial-data error degrades locally
    Tool: Bash
    Steps: Run widget test where one module (friend activity or badge preview) fails while others succeed
    Expected: Only the failed module shows an error card; rest of page remains usable
    Evidence: .sisyphus/evidence/task-7-home-partial.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement learner home dashboard` | Files: `mobile/lib/views/home/**`, `mobile/test/widgets/**`

- [x] 8. Implement courses list and course detail pages

  **What to do**: Implement Courses list and Course detail with locked/unlocked handling, learner-visible DTO boundaries, progress display, chapter ordering, and a fixed bottom CTA for course continuation. Include search/filter entry points only to the extent defined by the filter sheet.
  **Must NOT do**: Do not expose draft/archived content. Do not invent unsupported sort/filter behavior.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: course browsing pages are highly visual and mobile list/detail oriented.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 9 | Blocked By: 1,2,3,4,5

  **References**:
  - Existing: `mobile/lib/views/course/course_detail_view.dart` - placeholder detail page.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:261-297` - P06-P07 specs.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:672-693` - W06-W07 wireframe.
  - Contracts: `contracts/dictionaries/course-fields.md:7-86` - learner-visible fields, status rules, unlock rules.
  - Example: `contracts/examples/learner-course-list.json` - list response structure.

  **Acceptance Criteria**:
  - [ ] Courses list renders learner-visible fields only and uses phone-appropriate card density.
  - [ ] Course detail displays ordered chapters, progress, and locked-state messaging.
  - [ ] Locked chapter taps produce the correct non-destructive feedback.

  **QA Scenarios**:
  ```
  Scenario: Courses list happy path renders learner course cards
    Tool: Bash
    Steps: Run widget test with mocked learner course list JSON
    Expected: Course cards render title, summary, difficulty, estimated minutes, progress, and CTA without overflow
    Evidence: .sisyphus/evidence/task-8-courses-list.txt

  Scenario: Locked chapter handling works
    Tool: Bash
    Steps: Run widget test with course detail containing locked and unlocked chapters; tap a locked chapter
    Expected: Locked chapter does not navigate and shows the correct unlock message
    Evidence: .sisyphus/evidence/task-8-course-locked.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement course browsing pages` | Files: `mobile/lib/views/course/**`, `mobile/test/widgets/**`

- [x] 9. Implement chapter learning page

  **What to do**: Implement the chapter reading experience with markdown content, sample code card, knowledge summary card, learning-progress persistence, and the `Complete learning` CTA that unlocks the linked exercise and next chapter.
  **Must NOT do**: Do not mix chapter content editing/admin fields into the learner page. Do not auto-complete the chapter without explicit CTA confirmation.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: content reading page with fixed CTA and progressive unlock behavior.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 10 | Blocked By: 8

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:299-321` - chapter learning behavior.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:695-703` - chapter learning wireframe.
  - SRS: `doc/软件需求规格说明书.md:368-395` - chapter reading rules and errors.
  - Contracts: `contracts/dictionaries/course-fields.md:27-86` - chapter learner-visible fields and unlock rules.

  **Acceptance Criteria**:
  - [ ] Chapter page renders markdown, sample code, summary, and linked exercise entry card.
  - [ ] Completing a chapter updates progress and enables next-step navigation.
  - [ ] Loading and content-load failure states are implemented.

  **QA Scenarios**:
  ```
  Scenario: Chapter learning happy path unlocks next step
    Tool: Bash
    Steps: Run widget/controller test that marks a chapter complete
    Expected: UI switches CTA to `去做练习` and unlock messaging is shown
    Evidence: .sisyphus/evidence/task-9-chapter-complete.txt

  Scenario: Chapter content load failure shows retry state
    Tool: Bash
    Steps: Run widget test with failed chapter content fetch
    Expected: `内容加载失败` and `重试` are rendered and retry callback is wired
    Evidence: .sisyphus/evidence/task-9-chapter-error.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement chapter learning page` | Files: `mobile/lib/views/course/**`, `mobile/test/widgets/**`

- [x] 10. Implement exercise workspace and overlays

  **What to do**: Implement the exercise workspace for single-choice and coding modes, including code editor/preview tabs, public test case preview, autosave draft, submission flow, submission result bottom sheet, and AI help bottom sheet. Respect hidden test case rules and non-answer AI constraints.
  **Must NOT do**: Do not expose hidden assertions, `is_correct`, or admin-only expected payloads. Do not let AI return complete solutions in the learner UI flow.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: this is the most complex learner workflow and combines UI, state, contracts, autosave, and overlays.
  - Skills: []
  - Omitted: [`frontend-design`] - polish matters, but workflow/state correctness dominates.

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 11 | Blocked By: 3,4,5,9

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:323-379` - exercise page and AI sheet behavior.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:705-733` - workspace and sheet wireframes.
  - SRS: `doc/软件需求规格说明书.md:425-509` - editor, submission, preview rules.
  - Contracts: `contracts/dictionaries/practice-fields.md:7-115` - exercise, test case, submission, AI request visibility/state rules.

  **Acceptance Criteria**:
  - [ ] Exercise workspace supports both single-choice and coding variants.
  - [ ] Submission result and AI help sheets follow the specified bottom-sheet behavior.
  - [ ] Hidden/admin-only fields do not appear in learner UI.
  - [ ] Autosave works offline for coding drafts.

  **QA Scenarios**:
  ```
  Scenario: Coding exercise happy path submits and shows result sheet
    Tool: Bash
    Steps: Run integration/widget test for entering code, autosaving, submitting, and receiving a passed result
    Expected: Result sheet opens with score, passed case count, and next-step CTA
    Evidence: .sisyphus/evidence/task-10-exercise-submit.txt

  Scenario: Failed submission and AI help path works without leaking answers
    Tool: Bash
    Steps: Mock a failed submission and AI help response; inspect rendered text and fields
    Expected: Result sheet shows failure summary; AI sheet shows explanation/hints only, with no hidden assertion or direct full answer leakage
    Evidence: .sisyphus/evidence/task-10-exercise-ai.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement exercise workflow` | Files: `mobile/lib/views/exercise/**`, `mobile/lib/views/shared/**`, `mobile/test/**`, `mobile/integration_test/**`

- [x] 11. Implement challenge map, challenge detail, and daily challenge flow

  **What to do**: Implement Challenge map, Challenge detail, and Daily challenge pages using the locked state machines and wireframe rules. Include linear node map, challenge task list, star rules, reward summary, daily countdown, terminal result states, and route links into exercise tasks.
  **Must NOT do**: Do not add branching maps, boss fights, or non-MVP challenge mechanics. Do not treat daily challenge as infinitely retryable.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: map/detail/timer pages are highly UI-driven but contract-bound.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 3-4 | Blocks: 16 | Blocked By: 3,4,5,10

  **References**:
  - Existing: `mobile/lib/views/challenge/challenge_detail_view.dart` - current placeholder detail page.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:380-441` - challenge and daily pages.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:735-756` - wireframe rules for map/detail/daily.
  - SRS: `doc/软件需求规格说明书.md:513-650` - challenge map, star rules, daily challenge rules.
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:7-151` - challenge/daily/reward state machines and reward source-of-truth.

  **Acceptance Criteria**:
  - [ ] Challenge map shows linear learner progress with correct locked/unlocked/in-progress/completed behavior.
  - [ ] Challenge detail renders task list, star rules, and reward summary.
  - [ ] Daily challenge respects single-attempt-per-day, timer, and terminal states.

  **QA Scenarios**:
  ```
  Scenario: Challenge map and detail happy path work
    Tool: Bash
    Steps: Run widget/integration tests for opening an unlocked challenge, viewing detail, and entering an exercise task
    Expected: Correct node state, detail content, and route transition occur
    Evidence: .sisyphus/evidence/task-11-challenge-flow.txt

  Scenario: Daily challenge expired and retry-block states render correctly
    Tool: Bash
    Steps: Mock expired and already-submitted daily challenge records
    Expected: Expired and non-retry terminal states are rendered exactly and submission is blocked
    Evidence: .sisyphus/evidence/task-11-daily-edge.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement challenge flows` | Files: `mobile/lib/views/challenge/**`, `mobile/test/**`, `mobile/integration_test/**`

- [x] 12. Implement social center tab

  **What to do**: Implement the Social center with segmented `Activity / Friends / Leaderboard` content, friend request actions, friend list, activity feed, my-rank summary, and top-50 leaderboard presentation. Keep leaderboard inside Social rather than as a top-level tab.
  **Must NOT do**: Do not add chat, forum, follow graph, external share, or separate leaderboard app-shell tab.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: segmented mobile page with multiple social subviews.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: none | Blocked By: 2,3,4,5

  **References**:
  - Existing: `mobile/lib/views/friends/friends_view.dart` and inline leaderboard/profile placeholders in `home_view.dart`.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:443-481` - social center and achievement preview.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:758-779` - social wireframes.
  - SRS: `doc/软件需求规格说明书.md:735-759` and learner social sections in the analyzed docs.
  - Contracts: `contracts/dictionaries/social-profile-fields.md:3-64` - friend relations, activities, leaderboard boundaries.

  **Acceptance Criteria**:
  - [ ] Social center provides segmented views for activity, friends, and leaderboard.
  - [ ] Friend requests and accepted friends render with mobile-appropriate action density.
  - [ ] Leaderboard renders rank rows and current-user highlight according to the spec.

  **QA Scenarios**:
  ```
  Scenario: Social segmented content happy path works
    Tool: Bash
    Steps: Run widget test switching between Activity, Friends, and Leaderboard segments
    Expected: Segment state persists and each segment renders its required content
    Evidence: .sisyphus/evidence/task-12-social-segments.txt

  Scenario: Empty friends and empty rank states are handled
    Tool: Bash
    Steps: Run widget test with no friends, no activity, and leaderboard-not-generated mocks
    Expected: Correct empty-state copy and CTA guidance are shown for each segment
    Evidence: .sisyphus/evidence/task-12-social-empty.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement social center` | Files: `mobile/lib/views/social/**`, `mobile/lib/views/friends/**`, `mobile/test/**`

- [x] 13. Implement profile center page

  **What to do**: Implement the Profile tab as the single learner-owned personal hub page, with avatar/profile summary, level/XP, stats grid, badge preview, and navigation to stats detail, rewards, edit profile, and settings.
  **Must NOT do**: Do not leave Profile as an inline anonymous subview in Home. Do not surface admin configuration fields.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: profile tab is a major top-level mobile page.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: 14,15,16,17 | Blocked By: 1,2,3,4,5

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:483-499` - profile center page spec.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:781-787` - profile wireframe.
  - Contracts: `contracts/dictionaries/social-profile-fields.md:58-64` - personal center boundary.
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:77-114` - reward/badge truth-source relation.

  **Acceptance Criteria**:
  - [ ] Profile tab exists as its own owned page.
  - [ ] Profile summary, stats grid, badge preview, and navigation shortcuts render correctly.
  - [ ] No admin-only/profile-external fields are shown.

  **QA Scenarios**:
  ```
  Scenario: Profile center happy path renders correctly
    Tool: Bash
    Steps: Run widget test with mocked learner profile and reward summary
    Expected: Avatar card, stats grid, badge preview, and shortcut list are present in correct order
    Evidence: .sisyphus/evidence/task-13-profile-happy.txt

  Scenario: Empty badge state is handled
    Tool: Bash
    Steps: Run widget test with zero learner badges
    Expected: Empty badge preview message renders and page remains fully usable
    Evidence: .sisyphus/evidence/task-13-profile-empty.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement profile center` | Files: `mobile/lib/views/profile/**`, `mobile/test/**`

- [x] 14. Implement learner stats detail page

  **What to do**: Implement the Stats detail page with range switching, core metrics, study-time trend, knowledge mastery visualization, and rank comparison card using server-derived values only.
  **Must NOT do**: Do not compute canonical stats client-side. Do not invent unsupported time ranges or metrics.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: data-rich stats page with strict phone layout and server-derived values.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 5 | Blocks: none | Blocked By: 5,13

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:500-515` - stats detail spec.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:789-794` - stats wireframe.
  - Contracts: `contracts/dictionaries/stats-metrics.md:5-56` - server-derived metric definitions and learner stats rules.

  **Acceptance Criteria**:
  - [ ] Stats page shows only server-derived learner metrics.
  - [ ] Time-range switching updates the visible metrics/visuals without overflow.
  - [ ] New-user empty-data state is implemented.

  **QA Scenarios**:
  ```
  Scenario: Stats detail happy path renders server-derived metrics
    Tool: Bash
    Steps: Run widget test with mocked learner stats payload
    Expected: Core metrics, trend chart container, mastery card, and rank comparison card all render
    Evidence: .sisyphus/evidence/task-14-stats-happy.txt

  Scenario: New-user stats empty state works
    Tool: Bash
    Steps: Run widget test with zero-progress stats payload
    Expected: New-user empty-state message renders and no chart overflow occurs
    Evidence: .sisyphus/evidence/task-14-stats-empty.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement learner stats page` | Files: `mobile/lib/views/profile/**`, `mobile/test/**`

- [x] 15. Implement rewards center and achievement preview

  **What to do**: Implement the Rewards center and fullscreen achievement preview, including XP summary, badge grid, reward ledger list, filter behavior, and system-generated achievement-card preview actions.
  **Must NOT do**: Do not add freeform share text, custom card editing, or use leaderboard snapshots as reward truth source.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: rewards page is layout-heavy and shares achievement visuals.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 5 | Blocks: none | Blocked By: 5,13

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:516-531` and `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:475-481` - rewards + preview specs.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:776-800` - preview/rewards wireframes.
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:77-151` - XP ledger, badge, learner badge truth-source rules.

  **Acceptance Criteria**:
  - [ ] Rewards center renders XP summary, badge grid, and reward ledger.
  - [ ] Achievement preview is fullscreen and only uses structured system fields.
  - [ ] Empty-ledger and empty-badge states exist.

  **QA Scenarios**:
  ```
  Scenario: Rewards center happy path renders correctly
    Tool: Bash
    Steps: Run widget test with mocked reward summary, badges, and ledger entries
    Expected: XP summary, 2-column badge grid, and ledger list render in order
    Evidence: .sisyphus/evidence/task-15-rewards-happy.txt

  Scenario: Achievement preview uses system-generated content only
    Tool: Bash
    Steps: Run widget test for fullscreen preview and inspect rendered fields
    Expected: Only nickname, achievement type, core value, date, and brand mark are shown; no freeform text input exists
    Evidence: .sisyphus/evidence/task-15-achievement-preview.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement rewards center` | Files: `mobile/lib/views/rewards/**`, `mobile/test/**`

- [x] 16. Implement remaining challenge-linked reward/result surfaces

  **What to do**: Finalize challenge completion result cards, reward-claimed display, and cross-links from challenge completion into rewards and achievement preview. Ensure completion does not regress to earlier challenge states and that reward timestamps are surfaced correctly.
  **Must NOT do**: Do not allow completed challenges to revert state or emit duplicate reward UI as if the reward is newly claimable again.

  **Recommended Agent Profile**:
  - Category: `quick` - Reason: this is a focused completion surface once challenge and rewards exist.
  - Skills: []
  - Omitted: [`frontend-design`] - shared visuals are already established.

  **Parallelization**: Can Parallel: YES | Wave 5 | Blocks: none | Blocked By: 11,15

  **References**:
  - Spec: challenge detail/result sections in `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:398-419`
  - Contracts: `contracts/dictionaries/challenge-reward-fields.md:40-49` and `:124-151` - reward timestamps and completion constraints.

  **Acceptance Criteria**:
  - [ ] Completed challenge pages display best star, completion timestamp, and reward settlement timestamp.
  - [ ] Rewards are not shown as re-claimable for already settled attempts.

  **QA Scenarios**:
  ```
  Scenario: Completed challenge result surface renders correctly
    Tool: Bash
    Steps: Run widget test with completed challenge attempt payload including `reward_claimed_at`
    Expected: Best star, completion time, and reward settlement time render together with achievement preview entry point
    Evidence: .sisyphus/evidence/task-16-challenge-result.txt

  Scenario: Completed challenge does not regress to claimable state
    Tool: Bash
    Steps: Run state/controller test with completed challenge payload and re-entry to detail page
    Expected: UI remains in completed/result mode and does not show a fresh claim CTA
    Evidence: .sisyphus/evidence/task-16-challenge-no-regress.txt
  ```

  **Commit**: YES | Message: `feat(mobile): finalize challenge reward surfaces` | Files: `mobile/lib/views/challenge/**`, `mobile/lib/views/rewards/**`, `mobile/test/**`

- [x] 17. Implement edit profile and settings pages

  **What to do**: Implement Edit Profile and Settings pages with the exact fields and option groups from the spec, including avatar upload placeholder flow, nickname/bio validation, daily goal, theme mode, AI hint switch, difficulty preference, cache controls, logout confirmation, and help/about entries.
  **Must NOT do**: Do not add unsupported account-security or password-reset pages. Do not make settings groups desktop-like multi-column blocks.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: settings/forms are mobile ergonomics sensitive.
  - Skills: [`frontend-design`]
  - Omitted: []

  **Parallelization**: Can Parallel: YES | Wave 5 | Blocks: none | Blocked By: 5,13

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:532-564` - edit profile + settings.
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md:802-813` - wireframe annotations.
  - SRS: `doc/软件需求规格说明书.md:306-334` - profile management rules.
  - Metis: keep pages single-column, phone-first, and avoid unsupported lifecycle/security expansions.

  **Acceptance Criteria**:
  - [ ] Edit Profile page supports avatar, nickname, bio, daily goal, and theme mode changes with validation.
  - [ ] Settings page renders grouped options and logout confirm flow.
  - [ ] Offline settings degradation is explicit where sync is unavailable.

  **QA Scenarios**:
  ```
  Scenario: Edit profile happy path and validation work
    Tool: Bash
    Steps: Run widget/controller tests for saving valid profile data and rejecting invalid nickname/avatar input
    Expected: Save succeeds for valid input; invalid input shows inline validation without navigation
    Evidence: .sisyphus/evidence/task-17-edit-profile.txt

  Scenario: Settings logout confirm and offline handling work
    Tool: Bash
    Steps: Run widget test for logout confirmation and offline mode rendering
    Expected: Logout shows confirmation sheet; offline-unavailable synced settings are visually disabled while local cache actions remain enabled
    Evidence: .sisyphus/evidence/task-17-settings.txt
  ```

  **Commit**: YES | Message: `feat(mobile): implement profile editing and settings` | Files: `mobile/lib/views/profile/**`, `mobile/lib/views/settings/**`, `mobile/test/**`

- [x] 18. Add widget and golden test coverage for shared/page components

  **What to do**: Build the widget/golden test suite covering shared state widgets, top app bar variants, list/card variants, CTA bars, and representative page compositions for Home, Courses, Challenges, Social, and Profile. Include phone-sized rendering assertions to catch overflow and density regressions.
  **Must NOT do**: Do not rely on manual visual checks. Do not leave page states untested.

  **Recommended Agent Profile**:
  - Category: `quick` - Reason: focused QA task once shared/page UI is present.
  - Skills: []
  - Omitted: [`review-work`] - final review happens later.

  **Parallelization**: Can Parallel: YES | Wave 6 | Blocks: F1-F4 only | Blocked By: 3,4,6,7,8,9,10,11,12,13,14,15,17

  **References**:
  - Spec: `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md` - all page and wireframe requirements.
  - Metis: shared widget/golden verification is mandatory.

  **Acceptance Criteria**:
  - [ ] Golden/widget tests exist for shared widgets and one representative page per top-level tab.
  - [ ] Tests explicitly cover loading, empty, error, and CTA states.
  - [ ] No golden/widget overflow on phone-sized layouts.

  **QA Scenarios**:
  ```
  Scenario: Shared and representative page golden tests pass
    Tool: Bash
    Steps: Run golden test suite for shared widgets and representative pages
    Expected: All goldens pass for 375x812 or equivalent phone-sized render baselines
    Evidence: .sisyphus/evidence/task-18-goldens.txt

  Scenario: Widget tests cover page state permutations
    Tool: Bash
    Steps: Run `flutter test test/widgets/...`
    Expected: Tests pass for loading, empty, error, and CTA interactions across shared/page widgets
    Evidence: .sisyphus/evidence/task-18-widget-suite.txt
  ```

  **Commit**: YES | Message: `test(mobile): add learner widget and golden coverage` | Files: `mobile/test/widgets/**`, `mobile/test/goldens/**`

- [x] 19. Add integration tests for auth, tab, detail, modal, and failure flows

  **What to do**: Implement integration tests covering startup/auth routing, tab switching, detail navigation, bottom-sheet opening/closing, fullscreen modal presentation, auth-expired redirect, and failure states for representative pages.
  **Must NOT do**: Do not leave navigation and modal behavior to manual QA only.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: end-to-end mobile route and overlay behavior is cross-cutting and regression-prone.
  - Skills: []
  - Omitted: [`playwright`] - Flutter integration tests should be native to Flutter tooling.

  **Parallelization**: Can Parallel: YES | Wave 6 | Blocks: F1-F4 only | Blocked By: 1,2,4,6,7,8,9,10,11,12,13,14,15,16,17

  **References**:
  - Spec: startup/auth flow, top-level nav, overlay ownership, and State Matrix in `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md`.
  - Metis: route ownership and auth-expired redirect require explicit automated verification.

  **Acceptance Criteria**:
  - [ ] Integration suite covers startup/auth, tab navigation, representative detail routes, bottom-sheet flows, fullscreen modal flows, and auth-expired redirect.
  - [ ] Failure-path integration or controller-level route tests exist for at least login failure, locked challenge, and unauthorized protected-page access.

  **QA Scenarios**:
  ```
  Scenario: Core integration flows pass
    Tool: Bash
    Steps: Run `flutter test integration_test/...`
    Expected: Startup/auth/tab/detail/modal flows all pass on the integration suite
    Evidence: .sisyphus/evidence/task-19-integration-core.txt

  Scenario: Failure-path integration coverage works
    Tool: Bash
    Steps: Run integration/controller tests simulating login failure, locked challenge, and auth-expired protected route
    Expected: Correct user-visible failure states and route redirects occur
    Evidence: .sisyphus/evidence/task-19-integration-failures.txt
  ```

  **Commit**: YES | Message: `test(mobile): add learner integration flows` | Files: `mobile/integration_test/**`, `mobile/test/**`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle
- [x] F2. Code Quality Review — unspecified-high
- [x] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [x] F4. Scope Fidelity Check — deep

### Final Verification Execution Contract
- All four verification tasks run only after Tasks 1-19 are complete.
- All four must produce written evidence files under `.sisyphus/evidence/`.
- Consolidate the four outputs into a single verification summary for the user.
- If any verifier rejects or finds material issues, fix the issues, regenerate evidence, and rerun all affected final verification tasks.
- Even after all four approve, do not mark execution complete until the user explicitly says `okay`.

#### F1. Plan Compliance Audit — oracle
**What to do**: Compare implemented learner routes, pages, overlays, shared states, and tests against this plan and the design spec. Verify that every promised page, overlay, route ownership decision, and page-state rule was actually implemented.

**QA Scenario**:
```
Scenario: Implementation matches the execution plan and page design spec
  Tool: Bash
  Steps: Run `flutter analyze`; run `flutter test`; read the final route map and compare against `.sisyphus/drafts/frontend-learning-app-learner-page-design-spec.md` and this plan; generate a checklist of all promised pages, overlays, shared state patterns, and tests
  Expected: Oracle report confirms implemented scope matches the plan with no missing promised learner pages, overlays, or route-normalization requirements
  Evidence: .sisyphus/evidence/f1-plan-compliance-audit.md
```

#### F2. Code Quality Review — unspecified-high
**What to do**: Review implementation quality across learner pages, controllers, shared widgets, and adapters. Check for duplication, broken ownership boundaries, hidden-field leaks, inconsistent state handling, and poor mobile ergonomics implementation.

**QA Scenario**:
```
Scenario: Learner mobile implementation passes code quality review
  Tool: Bash
  Steps: Run `flutter analyze`; inspect shared widgets, route files, page files, and adapters; grep for forbidden admin/hidden fields (`course_code|content_version|is_correct|expected_payload_json`) in learner UI code; review test coverage outputs
  Expected: Review confirms no critical code-quality regressions, no forbidden field leakage, and no major duplication or ownership violations
  Evidence: .sisyphus/evidence/f2-code-quality-review.md
```

#### F3. Real Manual QA — unspecified-high (+ playwright if UI)
**What to do**: Execute end-to-end learner flows using the actual runnable app/test environment. Validate startup/auth, tab shell, representative detail flows, overlays, and representative failure paths with concrete checks.

**QA Scenario**:
```
Scenario: End-to-end learner flows behave correctly in runnable QA
  Tool: Bash
  Steps: Run `flutter test integration_test/...`; if a runnable UI harness exists, capture screenshots or test logs for login, tab switch, course detail, chapter completion, exercise result sheet, AI help sheet, challenge flow, social tab, rewards preview, and settings logout confirm
  Expected: Integration suite passes and QA evidence shows all representative learner flows and failure paths behave as specified
  Evidence: .sisyphus/evidence/f3-real-manual-qa.md
```

#### F4. Scope Fidelity Check — deep
**What to do**: Audit the delivered implementation for unauthorized scope growth or missing in-scope items. Confirm learner-only scope, no accidental admin/web features, no unsupported product expansion, and no skipped required page groups.

**QA Scenario**:
```
Scenario: Final implementation stays within approved learner-side scope
  Tool: Bash
  Steps: Compare implemented files/routes/features to the Must Have, Must NOT Have, and Exclusions sections of this plan and the page design spec; verify that unsupported features (chat, forum, push center, video course, AI continuous chat, forgot-password flow, admin pages) are absent
  Expected: Deep scope audit confirms learner-only delivery with no prohibited expansion and no missing in-scope page families
  Evidence: .sisyphus/evidence/f4-scope-fidelity-check.md
```

## Commit Strategy
- Prefer one commit per completed task or tightly-related task pair when changes are inseparable.
- Keep routing/shell/shared foundation commits separate from page feature commits so regressions can be isolated.
- Never bundle tests only at the very end; add tests alongside the relevant task.
- Expected commit sequence roughly follows tasks 1→19.

## Success Criteria
- The learner-side Flutter app structure matches the design spec’s page inventory and page/modal ownership exactly.
- All five top-level tabs render and behave as defined.
- Detail pages and overlays have deterministic route ownership, return behavior, and state handling.
- Contract-aligned data consumption exists for every page without leaking admin/hidden fields.
- Mobile ergonomics constraints are respected across forms, lists, cards, overlays, and CTA placement.
- Automated verification covers happy paths and failure paths for auth, tabs, detail pages, overlays, and state widgets.
