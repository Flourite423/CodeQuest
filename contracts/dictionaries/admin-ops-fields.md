# Admin Operations Field Dictionary

## Scope

本文件定义后台运营域的 canonical entity、admin DTO、状态机与审计规则，覆盖用户管理、反馈工单、内容审核、公告发布与系统配置管理。

## FeedbackTicket

| 字段名 | 类型 | 必填 | admin可见 | learner可见 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | Y | N | 反馈工单主标识 |
| `learner_id` | `string(uuid)` | Y | Y | N | 提交反馈的 learner 账号标识 |
| `category` | `string(enum)` | Y | Y | N | 反馈类型，仅允许 `content` / `problem` / `bug` / `account` / `other` |
| `content` | `string` | Y | Y | N | 反馈正文 |
| `screenshot_urls` | `array(string(uri))` | N | Y | N | 截图地址列表 |
| `status` | `string(enum)` | Y | Y | N | 工单状态，见下方状态机 |
| `admin_reply` | `string` | N | Y | N | 管理员回复文本 |
| `replied_at` | `string(date-time)` | N | Y | N | 首次或最近一次后台回复时间，UTC RFC3339 |
| `created_at` | `string(date-time)` | Y | Y | N | 创建时间，UTC RFC3339 |

## ModerationCase

| 字段名 | 类型 | 必填 | admin可见 | learner可见 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | Y | N | 审核单主标识 |
| `case_type` | `string(enum)` | Y | Y | N | 审核类型，仅允许 `nickname` / `avatar` / `feedback` |
| `target_id` | `string(uuid)` | Y | Y | N | 被审核目标主标识 |
| `target_snapshot_json` | `object` | Y | Y | N | 提审快照；审核时必须保留，不得在后续编辑中丢失 |
| `status` | `string(enum)` | Y | Y | N | 审核状态，见下方状态机 |
| `decision_reason` | `string` | N | Y | N | 审核决策原因 |
| `reviewed_by` | `string(uuid)` | N | Y | N | 审核操作人 |
| `reviewed_at` | `string(date-time)` | N | Y | N | 审核完成时间，UTC RFC3339 |
| `created_at` | `string(date-time)` | Y | Y | N | 创建时间，UTC RFC3339 |

## Announcement

| 字段名 | 类型 | 必填 | admin可见 | learner可见 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | Y | N（本任务范围） | 公告主标识 |
| `title` | `string` | Y | Y | N（本任务范围） | 公告标题 |
| `body_markdown` | `string` | Y | Y | N（本任务范围） | Markdown 正文 |
| `audience` | `string(enum)` | Y | Y | N（本任务范围） | 面向对象，仅允许 `all_learners` / `all_admins` / `all` |
| `status` | `string(enum)` | Y | Y | N（本任务范围） | 公告状态，见下方状态机 |
| `published_at` | `string(date-time)` | N | Y | N（本任务范围） | 发布时间，UTC RFC3339 |
| `expires_at` | `string(date-time)` | N | Y | N（本任务范围） | 过期时间，UTC RFC3339 |
| `created_by` | `string(uuid)` | Y | Y | N | 创建公告的管理员 |
| `created_at` | `string(date-time)` | Y | Y | N | 创建时间，UTC RFC3339 |
| `updated_at` | `string(date-time)` | Y | Y | N | 更新时间，UTC RFC3339 |

## SystemConfig

| 字段名 | 类型 | 必填 | admin可见 | learner可见 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | Y | N | 配置主标识 |
| `config_key` | `string` | Y | Y | N | 稳定配置键 |
| `config_scope` | `string(enum)` | Y | Y | N | 配置范围，仅允许 `system` / `ai` / `challenge` / `reward` |
| `value_json` | `object` | Y | Y | N | 后台内部配置 JSON；绝不下发给 learner |
| `status` | `string(enum)` | Y | Y | N | 配置启用状态，仅允许 `active` / `inactive` |
| `updated_by` | `string(uuid)` | Y | Y | N | 最近一次更新操作人 |
| `updated_at` | `string(date-time)` | Y | Y | N | 最近一次更新时间，UTC RFC3339 |

## Admin DTO Views

### AdminUserListItem

- 用于后台用户列表，返回 `account_status`、`roles`、`profile_summary` 与 `last_login_at`。
- `profile_summary.display_name` 是统一展示名：对 learner 通常取昵称，对 admin 通常取后台显示名。
- 可用于封禁、恢复与人工核验列表，不承载完整角色详情。

### AdminUserDetail

- 由 `account`、`roles`、`learner_profile`、`admin_profile` 组成。
- 同一账号若同时拥有 learner/admin 两种角色，可同时返回两份 profile。
- 角色授予列表以 `AccountRole[]` 为准，详情页用于审计和客服排障。

### AdminFeedbackListItem

- 在 `FeedbackTicket` 基础上增加 `learner_profile` 摘要，便于后台列表直接识别提交人。

### AdminModerationListItem

- 在 `ModerationCase` 基础上增加 `target_summary` 与 `reviewer_profile`，用于审核队列快速判读。

## 反馈状态机

```text
open -> in_progress -> resolved -> closed
```

- `open`：用户刚提交，尚未被后台接手。
- `in_progress`：已有运营/客服介入处理中。
- `resolved`：问题已处理并给出结果或回复。
- `closed`：工单关闭，不再继续跟进。
- 若需重新处理，应新建流程或由实现层定义 reopen 规则；当前 v1 契约不显式开放回退流转。

## 审核状态机

```text
pending -> approved / rejected
```

- `pending`：等待审核。
- `approved`：审核通过。
- `rejected`：审核拒绝。
- 做出 `approved` / `rejected` 决策时，应同步写入 `reviewed_by`、`reviewed_at`，并尽量补充 `decision_reason`。

## 公告状态机

```text
draft -> published -> expired
```

- `draft`：草稿，仅后台可见和编辑。
- `published`：已发布，允许按 `audience` 下发到对应受众。
- `expired`：已过期，不再继续展示。
- `published_at` 与 `expires_at` 均使用 UTC RFC3339；若未发布，可为 `null`。

## 审计字段规则

- `created_by`：记录创建公告等内容实体的后台操作人；创建后不可被前端直接篡改。
- `reviewed_by`：记录审核动作执行人；只有审核完成时才应出现。
- `updated_by`：记录系统配置最后一次修改人；每次配置变更都必须更新。
- `reviewed_at` / `updated_at` / `created_at` 必须使用 UTC RFC3339。
- 审计字段仅允许 admin 或系统内部流程读取；learner DTO 禁止暴露这些后台运营字段。
- `target_snapshot_json`、`value_json` 属于后台真相源字段，必须保留在 admin 契约中，但不得向 learner audience 泄露。
