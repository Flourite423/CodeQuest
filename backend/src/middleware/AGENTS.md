# Middleware — Agent Knowledge Base

**Scope:** Cross-cutting concerns via `hoop()`  
**Pattern:** `#[handler]` async fn calling `ctrl.call_next(...)`

## Current Middleware

- **logging.rs** — Request tracing with `tracing` + request_id injection

## Adding Middleware

```rust
#[handler]
async fn my_middleware(
    req: &mut Request,
    depot: &mut Depot,
    res: &mut Response,
    ctrl: &mut FlowCtrl,
) {
    // Before handler
    ctrl.call_next(req, depot, res).await;
    // After handler
}
```

## Execution Order (Onion Model)

```rust
Router::new()
    .hoop(outer)   // runs first, finishes last
    .hoop(inner)
    .get(handler); // runs in the middle
```

## Scoping

- Global: `.hoop()` on root router
- API only: `.hoop()` on `api/v1` router
- Specific route: `.hoop()` on leaf router

## Anti-Patterns

- **Never** forget `ctrl.call_next()` — downstream handlers won't run
- **Never** use `ctrl.skip_rest()` without setting a response status
- **Never** call `ctrl.cease()` unless you explicitly check `is_ceased()` downstream

## Related Skills

- **salvo-middleware** — Full middleware patterns, built-ins, `Depot` API
- **salvo-auth** — JWT/Basic auth as middleware
- **salvo-cors** — CORS middleware configuration
- **salvo-rate-limiter** — Rate limiting
- **salvo-compression** — Response compression
