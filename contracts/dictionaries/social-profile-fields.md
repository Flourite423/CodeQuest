# Social / Profile 字段字典

## FriendRelation

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 好友关系记录 ID。 |
| requester_id | uuid | Y | 发起好友申请的 learner 账号 ID。 |
| addressee_id | uuid | Y | 接收好友申请的 learner 账号 ID。 |
| status | enum(pending/accepted/rejected/blocked) | Y | 好友关系状态，统一使用 lower_snake_case。 |
| created_at | datetime | Y | 申请创建时间，UTC RFC3339。 |
| responded_at | datetime | N | 对申请做出接受、拒绝或拉黑动作的时间，UTC RFC3339。 |

## SocialActivity

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 动态记录 ID。 |
| learner_id | uuid | Y | 发布该动态的 learner 账号 ID。 |
| activity_type | enum(challenge_completed/badge_earned/streak_reached/course_completed) | Y | 站内学习动态类型。 |
| visibility | enum(friends_only/public_in_app/private) | Y | 平台内动态可见范围。 |
| payload_json | object | Y | 结构化动态负载，用于承载挑战、徽章、连击、课程等上下文。 |
| created_at | datetime | Y | 动态创建时间，UTC RFC3339。 |

## LeaderboardSnapshot

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 榜单快照记录 ID。 |
| board_type | enum(daily/weekly/total) | Y | 榜单类型。 |
| period_key | string | Y | 周期键，例如 `2026-W19`。 |
| learner_id | uuid | Y | 被排名 learner 的账号 ID。 |
| score | integer | Y | 榜单分值。 |
| rank_position | integer | Y | 当前排名，最小值为 1。 |
| generated_at | datetime | Y | 榜单生成时间，UTC RFC3339。 |

## 好友关系状态机

`pending -> accepted / rejected / blocked`

- `pending`：申请已创建，等待接收方处理。
- `accepted`：双方建立平台内好友关系。
- `rejected`：申请被拒绝，不建立好友关系。
- `blocked`：接收方或后续处理将对方加入屏蔽态，优先级高于普通拒绝。

约束：

- 初始状态只能是 `pending`。
- `accepted`、`rejected`、`blocked` 为终态，终态转换由服务端按业务规则控制。
- 所有状态值统一使用 lower_snake_case。

## 动态可见性规则

- `friends_only`：仅申请双方已建立好友关系的 learner 可见。
- `public_in_app`：平台内已登录 learner 可见，但不允许站外分享。
- `private`：仅动态发布者本人可见，用于个人成长记录。

## 平台内社交边界说明

- 社交能力仅限平台内好友关系、动态流和排行榜展示。
- 不涉及站外分享能力。
- 不涉及私信能力。
- 不涉及实时聊天能力。
- learner 个人中心仅承载个人资料与主题偏好，不承载 admin 配置字段。
