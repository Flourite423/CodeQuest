# Course State Machine

## States

| State | Description |
|-------|-------------|
| `draft` | Content is being prepared, visible only to admin |
| `published` | Content is live and visible to learners |
| `archived` | Content is retired, no new enrollments allowed |

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| `draft` | `published` | Admin publishes the course |
| `published` | `archived` | Admin archives the course |

## Rules

- `draft` is only visible to admin
- `published` is visible to learners
- `archived`: learners cannot newly enroll, but historical records remain readable
- Applies to: Course, Chapter, Exercise, Challenge, Badge, Announcement
