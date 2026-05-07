# Learning App Backend — Agent Knowledge Base

**Branch:** `backend`  
**Stack:** Salvo 0.89.3 + SQLx 0.8 + PostgreSQL + Tokio  
**Pattern:** Contract-first API with envelope responses

## Project Structure

```
backend/
├── Cargo.toml
├── src/
│   ├── main.rs          # Entry: tracing init → config → pool → router → serve
│   ├── config.rs        # AppConfig from env/files (config-rs)
│   ├── db.rs            # PgPool creation (max 20, min 5)
│   ├── models.rs        # Domain types + ApiResponse/ApiError envelopes
│   ├── routes.rs        # Router composition (api/v1/*)
│   ├── handlers/        # HTTP handlers by domain
│   │   ├── mod.rs       # health_check, not_found
│   │   ├── auth.rs      # login/logout/refresh (mock)
│   │   ├── course.rs    # CRUD stubs
│   │   ├── challenge.rs # CRUD stubs
│   │   └── user.rs      # list/get/update
│   └── middleware/
│       ├── mod.rs
│       └── logging.rs   # Request tracing with request_id
└── config/              # default.toml + local.toml (gitignored)
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add endpoint | `src/routes.rs` → `src/handlers/{domain}.rs` | Register in `create_router()` |
| Add model | `src/models.rs` | Derive `Serialize, Deserialize, sqlx::FromRow` |
| DB query | Handler file | Use `depot.obtain::<PgPool>()` |
| Auth logic | `src/handlers/auth.rs` | Replace mock tokens with JWT |
| Config key | `src/config.rs` | Prefix env vars with `APP__` |
| Middleware | `src/middleware/` | Attach in `main.rs` with `.hoop()` |

## Salvo Skills Available

All skills live in `.opencode/skills/salvo-*/SKILL.md`. Key ones for this project:

- **salvo-auth** — JWT (`jwt-auth` feature), Basic Auth, custom middleware
- **salvo-database** — SQLx pool injection via `affix_state`, transactions
- **salvo-error-handling** — `StatusError`, custom `Writer`, `Catcher`
- **salvo-middleware** — `hoop()` scoping, `FlowCtrl`, `Depot` patterns
- **salvo-openapi** — `#[endpoint]` for auto-docs, `ToSchema`, Swagger UI
- **salvo-routing** — `{id}` params, nesting, `filter_fn`
- **salvo-testing** — `TestClient`, `Service`, `take_json()`
- **salvo-cors** — `Cors::new().into_handler()` for cross-origin

## Conventions

1. **Envelope responses** — Always return `ApiResponse<T>` or `ApiError` from handlers
2. **Pool injection** — `affix_state::inject(pool)` in main, `depot.obtain::<PgPool>()` in handlers
3. **Error mapping** — `map_err(|_| StatusError::internal_server_error())` for DB errors
4. **Path params** — Use `{id}` syntax, extract with `req.param::<T>("id")`
5. **Config** — `APP__DATABASE_URL`, `APP__JWT_SECRET`, etc.

## Anti-Patterns (Forbidden Here)

- **Never** use `unwrap()` in production handlers — always map to `StatusError`
- **Never** inject a connection instead of a pool — pools are `Clone`
- **Never** use `req.param()` / `req.query()` if you want OpenAPI docs — use `PathParam`/`QueryParam` with `#[endpoint]`
- **Never** forget `.into_handler()` on `Cors` builder
- **Never** use `depot.obtain().ok_or_else()` — it returns `Result`, not `Option`

## Commands

```bash
cargo run                    # Start server
cargo test                   # Run tests
cargo check                  # Fast compile check
cargo clippy                 # Lint
sqlx migrate run             # Run DB migrations (requires sqlx-cli)
```

## Contract-First Workflow

1. Edit `contracts/openapi/openapi.yaml` first
2. Review contract changes
3. Update `src/routes.rs` and handlers
4. Regenerate client types if needed

## Gotchas

- `depot.obtain::<T>()` returns `Result<&T, _>` — use `.map_err()`, not `.ok_or_else()`
- `StatusError` has no `not_modified()` — use `res.status_code()` for 1xx-3xx
- `#[endpoint]` requires `salvo` `oapi` feature; `#[handler]` does not generate docs
- SQLx queries are checked at compile time — ensure DB is running or use `sqlx prepare`
