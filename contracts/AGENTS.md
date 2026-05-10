# Contracts — Agent Knowledge Base

**Scope:** OpenAPI spec, state machines, data dictionaries, examples
**Pattern:** Single source of truth for all API contracts

## STRUCTURE

```
contracts/
├── openapi/
│   └── openapi.yaml       # Main OpenAPI 3.0 spec
├── state-machines/
│   ├── account.md
│   ├── challenge.md
│   ├── course.md
│   ├── daily-challenge.md
│   ├── feedback.md
│   ├── friend-relation.md
│   └── moderation.md
├── dictionaries/
│   ├── admin-ops-fields.md
│   ├── challenge-reward-fields.md
│   ├── course-fields.md
│   ├── global-fields.md
│   ├── practice-fields.md
│   ├── social-profile-fields.md
│   └── stats-metrics.md
├── examples/
│   ├── admin-course-create.json
│   └── learner-course-list.json
└── mocks/
    ├── admin/
    ├── learner/
    └── shared/
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| API definition | `openapi/openapi.yaml` | All endpoints, schemas, responses |
| State transitions | `state-machines/{domain}.md` | Business logic flow |
| Field definitions | `dictionaries/{domain}-fields.md` | Data model documentation |
| Request/response examples | `examples/` | JSON samples for testing |
| Mock data | `mocks/{audience}/` | Test fixtures |

## CONVENTIONS

1. **Contract-first** — Always edit OpenAPI before implementing
2. **x-extensions** — Use `x-audience`, `x-permission`, `x-idempotent`
3. **No breaking changes in v1** — Bump to v2 for incompatible changes
4. **Examples required** — Every endpoint should have examples

## ANTI-PATTERNS

- **Never** implement API before updating OpenAPI
- **Never** make breaking changes without version bump
- **Never** skip state machine docs for complex flows

## NOTES

- Referenced by all three subprojects
- Backend enforces contract via `#[endpoint]` (oapi feature)
- Mobile uses Retrofit to generate types from spec
- Admin uses TypeScript types derived from spec
