# Account State Machine

## States

| State | Description |
|-------|-------------|
| `active` | Account is active and fully functional |
| `suspended` | Account is temporarily suspended |
| `closed` | Account is permanently closed |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `active` | `suspended` | Admin suspends account (violation, abuse, etc.) |
| `suspended` | `active` | Admin reinstates account |
| `active` | `closed` | User requests account closure or admin closes account |

## Rules

- `closed` is irreversible
- Historical learning and audit data must be retained after closure
- No transitions from `closed` to any other state
