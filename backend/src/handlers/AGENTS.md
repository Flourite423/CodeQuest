# Handlers — Agent Knowledge Base

**Scope:** HTTP request handlers by domain  
**Pattern:** `#[handler]` async fn returning `Result<Json<ApiResponse<T>>, StatusError>`

## Structure

```
handlers/
├── mod.rs       # Health check, 404 fallback
├── auth.rs      # Authentication endpoints
├── course.rs    # Course CRUD
├── challenge.rs # Challenge CRUD
└── user.rs      # User management
```

## Handler Signature

```rust
#[handler]
async fn handler_name(
    req: &mut Request,      // optional
    depot: &mut Depot,       // for DB pool
) -> Result<Json<ApiResponse<T>>, StatusError> {
    let pool = depot.obtain::<PgPool>()
        .map_err(|_| StatusError::internal_server_error())?;
    // ... query ...
    Ok(Json(ApiResponse::new(data)))
}
```

## Adding a New Handler

1. Create fn in appropriate file (or new file + `mod.rs` entry)
2. Export in `handlers/mod.rs`
3. Register in `routes.rs` with method + path

## Anti-Patterns

- **Never** use `req.param()` if you need OpenAPI docs — use `PathParam<T>` parameter instead
- **Never** return raw types without `ApiResponse` wrapper — breaks envelope contract
- **Never** use `unwrap()` on `req.parse_json()` — map to `StatusError::bad_request()`

## Related

- `../models.rs` — `ApiResponse`, `ApiError`, domain structs
- `../routes.rs` — router registration
- `../middleware/` — auth, logging, CORS
