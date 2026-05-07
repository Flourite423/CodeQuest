# Friend Relation State Machine

## States

| State | Description |
|-------|-------------|
| `pending` | Friend request has been sent but not yet responded to |
| `accepted` | Friend request has been accepted |
| `rejected` | Friend request has been rejected |
| `blocked` | One user has blocked the other |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `pending` | `accepted` | Recipient accepts the friend request |
| `pending` | `rejected` | Recipient rejects the friend request |
| `accepted` | `blocked` | Either user blocks the other |

## Rules

- A rejected request may allow re-sending (implementation-dependent)
- Blocking is one-directional and prevents further interaction
