# Moderation Case State Machine

## States

| State | Description |
|-------|-------------|
| `pending` | Case is awaiting moderator review |
| `approved` | Content/action has been approved |
| `rejected` | Content/action has been rejected |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `pending` | `approved` | Moderator approves the content/action |
| `pending` | `rejected` | Moderator rejects the content/action |

## Rules

- Once `approved` or `rejected`, the case is final
- Rejected content may trigger automatic removal or user notification
