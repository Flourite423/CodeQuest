## Final Wave Prep Notes

### Current state

- Plan status: `9/13`
- Remaining items:
  - `F1. Plan Compliance Audit — oracle`
  - `F2. Code Quality Review — unspecified-high`
  - `F3. Real Manual QA — unspecified-high (+ playwright if UI)`
  - `F4. Scope Fidelity Check — deep`

### Local prep already completed

- Requirements draft has been repeatedly cleaned for scope drift.
- Task 9 local evidence exists:
  - `.sisyphus/evidence/task-9-finalize.txt`
  - `.sisyphus/evidence/task-9-finalize-error.txt`
- Local blocker/status evidence exists:
  - `.sisyphus/evidence/local-final-wave-status.md`

### Known execution caveats

- The original plan names `unspecified-high` and `deep`, but this environment previously reported those agent types as unavailable.
- If subagents are later allowed, the practical replacement strategy should be:
  - `F1` → `oracle`
  - `F2` → `general` or `build` for document-quality review
  - `F3` → `general` for manual QA style review (no UI runtime available here)
  - `F4` → `oracle` or `general` for scope-fidelity review

### Primary risks reviewers may still check

- Scope drift wording inside explanatory sections
- AI wording consistency across正文、MVP表、非MVP表、验收标准
- Social boundary consistency across正文、MVP表、异常场景
- Platform wording consistency: learner mobile app + web admin only

### Blocker

- Current session constraint forbids running subagents.
- Therefore Final Wave cannot be executed yet.
