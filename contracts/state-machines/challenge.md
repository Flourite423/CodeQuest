# Challenge State Machine

## States

| State | Description |
|-------|-------------|
| `locked` | Challenge is locked and not yet available to the user |
| `unlocked` | Challenge is unlocked and available to start |
| `in_progress` | User has started the challenge |
| `completed` | User has completed the challenge |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `locked` | `unlocked` | Prerequisites met (e.g., previous challenge completed) |
| `unlocked` | `in_progress` | User starts the challenge |
| `in_progress` | `completed` | User successfully completes the challenge |

## Rules

- A challenge must be `unlocked` before it can be started
- Once `completed`, the challenge cannot revert to previous states
