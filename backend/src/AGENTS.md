# Models — Agent Knowledge Base

**Scope:** Domain types and API envelope structures  
**Pattern:** `#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]`

## Current Types

| Type | Purpose | DB Table |
|------|---------|----------|
| `Account` | User accounts (phone login) | `accounts` |
| `LearnerProfile` | XP, level, streak | `learner_profiles` |
| `Course` | Learning content | `courses` |
| `Challenge` | Gamified tasks | `challenges` |
| `ApiResponse<T>` | Success envelope | — |
| `ApiError` | Error envelope | — |

## Envelope Format

Success:
```json
{
  "data": { ... },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

Error:
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "details": null
  },
  "meta": { ... }
}
```

## Adding a Model

1. Add struct with derives: `Debug, Serialize, Deserialize, sqlx::FromRow`
2. Use `Uuid` for IDs, `DateTime<Utc>` for timestamps
3. Use `Option<T>` for nullable fields
4. Add to `ApiResponse` return type in handlers

## Anti-Patterns

- **Never** use `String` for enums — create a Rust enum + `sqlx::Type`
- **Never** expose internal IDs to clients — use UUIDs
- **Never** skip `serde` derives — handlers need serialization
