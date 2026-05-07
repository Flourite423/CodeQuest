# Daily Challenge State Machine

## States

| State | Description |
|-------|-------------|
| `not_started` | Daily challenge has not been attempted yet |
| `passed` | User successfully completed the daily challenge |
| `failed` | User attempted but did not pass the daily challenge |
| `expired` | Daily challenge time window has expired |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `not_started` | `passed` | User submits and passes the challenge |
| `not_started` | `failed` | User submits but fails the challenge |
| `not_started` | `expired` | Daily challenge time window expires |

## Rules

- Once a state is reached (`passed`, `failed`, or `expired`), it is final for that day
- A new daily challenge resets the state to `not_started`
