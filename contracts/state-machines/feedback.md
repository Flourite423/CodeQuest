# Feedback Ticket State Machine

## States

| State | Description |
|-------|-------------|
| `open` | Ticket has been created and is awaiting handling |
| `in_progress` | Ticket is being actively worked on |
| `resolved` | Issue has been resolved, awaiting closure |
| `closed` | Ticket is closed and archived |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `open` | `in_progress` | Support staff starts working on the ticket |
| `in_progress` | `resolved` | Issue is fixed or answered |
| `resolved` | `closed` | User confirms resolution or auto-closed after timeout |

## Rules

- Tickets should auto-transition from `resolved` to `closed` after a grace period if no user response
- Reopening a closed ticket may create a new ticket or revert to `open` (implementation-dependent)
