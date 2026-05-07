# Course and Chapter Field Dictionary

## Scope

本文件定义 Course / Chapter 领域的 canonical entity 字段字典，以及 learner/admin 两侧的可见性、写入边界、状态机与内容版本规则。

## Course Fields

| 字段名 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 课程主标识 | Y | Y | system |
| `course_code` | `string` | Y | 稳定业务编码 | N | Y | admin |
| `title` | `string(1..100)` | Y | 课程标题 | Y | Y | admin |
| `summary` | `string(0..300)` | Y | 课程摘要 | Y | Y | admin |
| `description` | `string` | N | 课程详细描述 | Y | Y | admin |
| `cover_image_url` | `string(uri)` | N | 课程封面图地址 | Y | Y | admin |
| `difficulty` | `string(enum)` | Y | 难度，仅允许 `beginner` / `intermediate` | Y | Y | admin |
| `estimated_minutes` | `integer` | Y | 预计总时长（分钟） | Y | Y | admin |
| `status` | `string(enum)` | Y | 发布状态，仅允许 `draft` / `published` / `archived` | Y（仅 `published`） | Y | admin |
| `sort_order` | `integer` | Y | 课程排序权重 | Y | Y | admin |
| `content_version` | `integer` | Y | 内容版本号，随课程内容变更递增 | N | Y | system/admin |
| `created_by` | `string(uuid)` | Y | 创建课程的管理员 ID | N | Y | system |
| `published_at` | `string(date-time)` | N | 发布时间，UTC RFC3339 | Y | Y | system/admin |
| `created_at` | `string(date-time)` | Y | 创建时间，UTC RFC3339 | Y | Y | system |
| `updated_at` | `string(date-time)` | Y | 更新时间，UTC RFC3339 | Y | Y | system |

## Chapter Fields

| 字段名 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 章节主标识 | Y | Y | system |
| `course_id` | `string(uuid)` | Y | 所属课程 ID | N | Y | system/admin |
| `chapter_code` | `string` | Y | 稳定业务编码 | N | Y | admin |
| `title` | `string` | Y | 章节标题 | Y | Y | admin |
| `summary` | `string` | Y | 章节摘要 | Y | Y | admin |
| `learning_content_markdown` | `string` | Y | 图文主文稿，Markdown 格式 | Y（仅 `published`） | Y | admin |
| `sample_code` | `string` | N | 示例代码 | Y（仅 `published`） | Y | admin |
| `estimated_minutes` | `integer` | Y | 预计时长（分钟） | Y | Y | admin |
| `order_index` | `integer` | Y | 章节顺序 | Y | Y | admin |
| `unlock_rule` | `string(enum)` | Y | 解锁规则，仅允许 `free` / `after_previous_completed` | Y | Y | admin |
| `status` | `string(enum)` | Y | 发布状态，仅允许 `draft` / `published` / `archived` | Y（仅 `published`） | Y | admin |
| `content_version` | `integer` | Y | 内容版本号，随章节内容变更递增 | N | Y | system/admin |
| `created_at` | `string(date-time)` | Y | 创建时间，UTC RFC3339 | N | Y | system |
| `updated_at` | `string(date-time)` | Y | 更新时间，UTC RFC3339 | Y | Y | system |

## Learner/Admin DTO Boundary

- `Course` / `Chapter` 是 canonical entity schema，面向契约真源与 admin 全量读模型。
- learner DTO 只能使用裁剪后的 `LearnerCourseListItem` / `LearnerCourseDetail`。
- learner 不得读取 `course_code`、`chapter_code`、`created_by`、`content_version` 等管理/审计字段。
- learner 不得读取 `draft` 或 `archived` 状态的课程与章节内容。
- 富文本学习内容与后台内部配置不得混入同一个 DTO；当前 learner DTO 仅包含学习展示所需字段。

## Course Status Machine

```text
draft -> published -> archived
```

规则：

- 新建课程默认应从 `draft` 开始。
- `published` 表示可对 learner 发布。
- `archived` 表示仅后台保留记录，不再对 learner 暴露。
- 不允许将 `draft`、`archived` 内容下发给 learner。
- 不允许从 `archived` 回退到 `published` 或 `draft`。

## Unlock Rule

| 值 | 说明 |
| --- | --- |
| `free` | learner 无需前置条件即可查看该章节 |
| `after_previous_completed` | learner 需先完成上一章节，当前章节才解锁 |

补充规则：

- 解锁规则只影响 learner 侧可访问性，不影响 admin 侧编辑与预览权限。
- 若章节本身不是 `published`，即使解锁规则满足，也不能对 learner 可见。

## Content Version Rule

- `content_version` 是课程与章节的内容版本号，必须保留在 canonical schema 中。
- 初始版本从 `1` 开始。
- 任何会影响 learner 展示、学习内容、顺序或解锁逻辑的变更，都应递增 `content_version`。
- 仅后台与系统流程可写入 `content_version`；learner 不可见，也不可提交。
- `content_version` 用于客户端缓存失效、兼容性判断与内容发布审计。
