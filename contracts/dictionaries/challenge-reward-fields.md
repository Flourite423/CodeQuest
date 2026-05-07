# Challenge & Reward Field Dictionary

## Scope

本文件定义闯关、每日挑战与奖励相关领域契约字段，服务于 learner 端展示、admin 端配置与后端结算实现。

## Challenge

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 关卡主标识 |
| `challenge_code` | `string` | Y | 稳定业务编码，用于跨系统引用 |
| `title` | `string` | Y | 关卡标题 |
| `summary` | `string` | Y | 关卡摘要说明 |
| `related_course_id` | `string(uuid)` | N | 关联课程 ID，可为空 |
| `difficulty` | `string(enum)` | Y | 难度，`easy/medium/hard` |
| `reward_xp` | `integer` | Y | 完成关卡发放的经验值 |
| `status` | `string(enum)` | Y | 配置状态，`draft/published/archived` |
| `sort_order` | `integer` | Y | 地图排序权重 |
| `content_version` | `integer` | Y | 关卡内容版本 |
| `created_at` | `string(date-time)` | Y | 创建时间，UTC RFC3339 |
| `updated_at` | `string(date-time)` | Y | 更新时间，UTC RFC3339 |

## ChallengeStage

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 子关卡主标识 |
| `challenge_id` | `string(uuid)` | Y | 所属关卡 ID |
| `exercise_id` | `string(uuid)` | Y | 关联练习 ID |
| `order_index` | `integer` | Y | 子关卡顺序，从 1 开始 |
| `star_rule_json` | `object` | Y | 星级结算规则配置 |
| `unlock_rule_json` | `object` | Y | 解锁条件规则配置 |
| `rule_version` | `integer` | Y | 规则版本，奖励结算必须记录对应版本 |

## ChallengeAttempt

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 挑战尝试记录 ID |
| `challenge_id` | `string(uuid)` | Y | 关联关卡 |
| `learner_id` | `string(uuid)` | Y | 学习者 ID |
| `best_star` | `integer` | Y | 最佳星级，范围 `0..3` |
| `status` | `string(enum)` | Y | 状态，`locked/unlocked/in_progress/completed` |
| `started_at` | `string(date-time)` | N | 开始时间 |
| `completed_at` | `string(date-time)` | N | 完成时间 |
| `reward_claimed_at` | `string(date-time)` | N | 奖励结算或领取时间，必须保留 |
| `updated_at` | `string(date-time)` | Y | 最近更新时间 |

## DailyChallenge

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 每日挑战主标识 |
| `challenge_date` | `string(date)` | Y | 生效日期 |
| `title` | `string` | Y | 标题 |
| `exercise_id` | `string(uuid)` | Y | 关联练习 ID |
| `difficulty` | `string(enum)` | Y | 难度，`easy/medium/hard` |
| `time_limit_seconds` | `integer` | Y | 限时秒数 |
| `reward_xp` | `integer` | Y | 完成奖励经验值 |
| `status` | `string(enum)` | Y | 发布状态，`scheduled/active/closed` |
| `published_at` | `string(date-time)` | Y | 发布时间 |

## DailyChallengeRecord

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 参与记录 ID |
| `daily_challenge_id` | `string(uuid)` | Y | 每日挑战 ID |
| `learner_id` | `string(uuid)` | Y | 学习者 ID |
| `status` | `string(enum)` | Y | 状态，`not_started/passed/failed/expired` |
| `score` | `integer` | Y | 提交分数 |
| `elapsed_seconds` | `integer` | N | 实际用时 |
| `streak_after_completion` | `integer` | Y | 完成后的连续天数 |
| `completed_at` | `string(date-time)` | N | 完成时间 |

## XpLedger

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | XP 流水主标识 |
| `learner_id` | `string(uuid)` | Y | 学习者 ID |
| `source_type` | `string(enum)` | Y | 来源类型，`chapter/exercise/challenge/daily/admin_adjustment` |
| `source_id` | `string(uuid)` | Y | 来源业务主标识 |
| `delta_xp` | `integer` | Y | 本次增减值，可正可负 |
| `balance_after` | `integer` | Y | 变更后 XP 余额 |
| `created_at` | `string(date-time)` | Y | 流水创建时间 |

## Badge

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 徽章主标识 |
| `badge_code` | `string` | Y | 稳定业务编码 |
| `name` | `string` | Y | 徽章名称 |
| `description` | `string` | Y | 徽章说明 |
| `icon_url` | `string(uri)` | N | 图标地址 |
| `rule_type` | `string(enum)` | Y | 规则类型，`streak/course/challenge/manual` |
| `rule_config_json` | `object` | Y | 规则配置 |
| `status` | `string(enum)` | Y | 状态，`draft/published/archived` |
| `created_at` | `string(date-time)` | Y | 创建时间 |
| `updated_at` | `string(date-time)` | Y | 更新时间 |

## LearnerBadge

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | 授予记录主标识 |
| `learner_id` | `string(uuid)` | Y | 学习者 ID |
| `badge_id` | `string(uuid)` | Y | 徽章 ID |
| `award_source_type` | `string(enum)` | Y | 授予来源，`system/manual` |
| `award_source_id` | `string(uuid)` | N | 来源业务 ID，可为空 |
| `awarded_at` | `string(date-time)` | Y | 授予时间 |

## Challenge Status Machine

状态流转固定为：`locked -> unlocked -> in_progress -> completed`

- `locked`：尚未满足解锁条件，不允许开始挑战。
- `unlocked`：已满足解锁条件，但尚未正式开始。
- `in_progress`：已开始挑战，尚未完成所有要求。
- `completed`：已完成挑战，可进入奖励结算或领奖阶段。

约束：

- 不允许从 `completed` 回退到较早状态覆盖历史结果。
- `reward_claimed_at` 只能在挑战已完成后产生。
- 星级判定与解锁判定必须和 `rule_version` 对齐。

## DailyChallengeRecord Status Machine

状态流转固定为：`not_started -> passed/failed/expired`

- `not_started`：当天挑战存在，但 learner 尚未完成一次有效提交。
- `passed`：在有效时间内达到通过条件。
- `failed`：已提交但未达到通过条件。
- `expired`：超过挑战有效时间窗口，未再允许结算。

约束：

- `passed`、`failed`、`expired` 为终态。
- 只有 `passed` 可以触发每日挑战奖励 XP 发放。
- `streak_after_completion` 只在有效完成结算后更新。

## Reward Source-of-Truth Rules

- `XpLedger` 是经验值奖励真相源。任何 XP 余额、累计经验、奖励明细都必须从流水归集，不得直接以排行榜结果反推。
- `LearnerBadge` 是徽章授予真相源。learner 是否拥有某枚徽章，以授予记录是否存在为准。
- `LeaderboardSnapshot` 是派生读模型，只用于展示排名，不得直接作为奖励发放依据。
- `Badge` 是规则定义，不代表授予结果；真实授予结果必须落在 `LearnerBadge`。
- `ChallengeAttempt.reward_claimed_at` 是挑战奖励完成结算时间，不得省略。
