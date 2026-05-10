# CodeQuest — Project Knowledge Base

**Generated:** 2026-05-10
**Branch:** main
**Type:** Monorepo (3 subprojects)

## OVERVIEW

CodeQuest is a learning application with three client-facing subprojects:
- **Backend** (Rust/Salvo) — REST API with PostgreSQL
- **Admin** (Vue 3/TypeScript) — Management dashboard
- **Mobile** (Flutter/GetX) — Learner mobile app

All projects follow **contract-first development** using OpenAPI specs in `contracts/`.

## STRUCTURE

```
.
├── admin/              # Vue 3 + Element Plus + Pinia
│   ├── src/
│   │   ├── main.ts
│   │   ├── api/        # Axios client
│   │   ├── views/      # Page components
│   │   ├── stores/     # Pinia stores
│   │   └── router/     # Vue Router
│   └── package.json
├── backend/            # Rust + Salvo + SQLx
│   ├── src/
│   │   ├── main.rs     # Entry: tracing → config → pool → router → serve
│   │   ├── handlers/   # HTTP handlers by domain
│   │   ├── models.rs   # Domain types + ApiResponse/ApiError envelopes
│   │   └── middleware/ # Logging, auth, CORS
│   ├── config/         # default.toml + local.toml (gitignored)
│   └── Cargo.toml
├── mobile/             # Flutter 3.x + GetX
│   ├── lib/
│   │   ├── main.dart
│   │   ├── views/      # Pages (View + Controller + Binding per page)
│   │   ├── services/   # ApiService, StorageService
│   │   └── routes/     # GetX routing
│   └── pubspec.yaml
├── contracts/          # OpenAPI spec, state machines, dictionaries
│   ├── openapi/openapi.yaml
│   ├── state-machines/
│   └── examples/
└── doc/                # 技术栈选型.md, 软件需求规格说明书.md
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add API endpoint | `backend/src/handlers/{domain}.rs` | Register in `routes.rs` |
| Add model | `backend/src/models.rs` | Derive `Serialize, Deserialize, sqlx::FromRow` |
| DB query | Handler file | Use `depot.obtain::<PgPool>()` |
| Admin page | `admin/src/views/{page}/` | Vue SFC with `<script setup>` |
| Admin API call | `admin/src/api/` | Centralized Axios instance |
| Mobile page | `mobile/lib/views/{page}/` | View + Controller + Binding in one file |
| Mobile service | `mobile/lib/services/` | Extend `GetxService` |
| Update contract | `contracts/openapi/openapi.yaml` | All changes start here |

## CROSS-CUTTING CONVENTIONS

1. **Contract-first** — Edit `contracts/openapi/openapi.yaml` before any API change
2. **Envelope responses** — Backend always returns `ApiResponse<T>` or `ApiError`
3. **Pool injection** — `affix_state::inject(pool)` in main, `depot.obtain::<PgPool>()` in handlers
4. **Config prefix** — Backend env vars use `APP__*` prefix (e.g., `APP__DATABASE_URL`)
5. **No unwrap in production** — Map to `StatusError` instead

## ANTI-PATTERNS (Project-wide)

- **Never** modify API without updating `contracts/openapi/openapi.yaml` first
- **Never** use `unwrap()` in production handlers
- **Never** inject a connection instead of a pool
- **Never** return raw types without `ApiResponse` wrapper from backend
- **Never** call API directly from mobile views — use Controller → Service

## SUBPROJECT AGENTS.md

- [Admin](admin/AGENTS.md) — Vue 3 + Element Plus dashboard
- [Backend](backend/AGENTS.md) — Rust/Salvo REST API
- [Mobile](mobile/AGENTS.md) — Flutter/GetX learner app
- [Contracts](contracts/AGENTS.md) — OpenAPI specs & state machines

## COMMANDS

```bash
# Backend
cd backend && cargo run              # Start server
cd backend && cargo test             # Run tests
cd backend && cargo clippy           # Lint

# Admin
cd admin && npm run dev              # Dev server (localhost:3000)
cd admin && npm run build            # Production build
cd admin && npm run lint             # ESLint

# Mobile
cd mobile && flutter pub get         # Install dependencies
cd mobile && flutter run             # Run app
cd mobile && flutter build apk       # Build APK
```

## NOTES

- No CI/CD configured — builds and tests run locally
- `Cargo.lock` is gitignored (non-standard for applications)
- `.sisyphus/` contains internal planning artifacts
- Backend has 29 Salvo skill files in `.opencode/skills/salvo-*/`
- Mobile uses `ui-ux-pro-max` skill for design guidance

## NOTES

- No CI/CD configured — builds and tests run locally
- `Cargo.lock` is gitignored (non-standard for applications)
- `.sisyphus/` contains internal planning artifacts
- Backend has 29 Salvo skill files in `.opencode/skills/salvo-*/`
- Mobile uses `ui-ux-pro-max` skill for design guidance
