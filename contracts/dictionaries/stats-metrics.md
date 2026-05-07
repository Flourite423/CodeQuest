# Stats Metrics Dictionary

## stats scope

本字典定义统计、排行、奖励派生读模型的统一口径。关键统计值由服务端按真相源派生，客户端只消费结果，不得自行推导关键统计值。

## 指标口径定义

| 指标 | 定义口径 | 来源 | 计算方式 | 备注 |
|---|---|---|---|---|
| 学习时长 | 单次课程进度有效学习时长 | CourseProgress | `updated_at - started_at`，按分钟向下取整后聚合 | 仅统计已开始且未撤销的进度记录 |
| 课程完成率 | 已完成课程进度占总课程进度的比例 | CourseProgress | `status = completed / total` | 分母为统计窗口内进入课程的学习者课程进度总数 |
| 挑战完成率 | 已完成挑战尝试占总挑战尝试的比例 | ChallengeAttempt | `status = completed / total` | 分母包含已发起的挑战尝试 |
| AI 使用次数 | 学习者或平台在窗口内发起 AI 请求的次数 | AIHelpRequest | `count(*)` | 一次请求记一次，不按 token 或响应长度折算 |
| 日活学习者数 | 当日产生有效活跃会话的学习者去重数 | Session | `distinct learner where last_seen_at = today` | 以 UTC 自然日计算 |
| XP 累计值 | 统计窗口内 XP 流水累加净值 | XpLedger | `sum(delta_xp)` | 负向调整保留符号，不做绝对值处理 |
| 勋章获得数 | 学习者在窗口内新增获得的勋章数量 | LearnerBadge | `count(*)` | 以 `awarded_at` 计入窗口 |

## 真相源与派生关系

| 类型 | 名称 | 角色 | 说明 |
|---|---|---|---|
| 真相源 | XpLedger | reward ledger | XP 余额与累计奖励的唯一真相源 |
| 真相源 | LearnerBadge | reward ownership | 勋章归属与发放结果的唯一真相源 |
| 真相源 | Submission | practice outcome | 练习提交与评测结果真相源，可派生学习活跃与通过统计 |
| 真相源 | AIHelpRequest | ai usage | AI 请求次数与最近使用时间真相源 |
| 真相源 | Session | activity presence | 活跃会话、DAU/WAU 与最近活跃时间真相源 |
| 派生读模型 | LeaderboardSnapshot | ranking snapshot | 用于排行展示的不可变快照，绝不是奖励发放真相源 |
| 派生读模型 | AdminDashboardStats | admin read model | 聚合平台级统计口径，用于管理看板 |
| 派生读模型 | LearnerPersonalStats | learner read model | 聚合个人学习、奖励与排行上下文 |

## 刷新策略

| 数据对象 | 刷新策略 | 说明 |
|---|---|---|
| LearnerPersonalStats | 实时 | 个人页读取时直接从最新真相源聚合，保证当前 XP、AI 次数和个人进度准确 |
| AdminUserActivityStats | 准实时 | 以分钟级增量任务或流式聚合刷新，兼顾后台可读性与成本 |
| AdminCourseStats | 准实时 | 课程维度统计适合按 5~15 分钟窗口刷新 |
| AdminDashboardStats | 准实时 | 看板汇总依赖多源聚合，建议分钟级缓存刷新 |
| LeaderboardSnapshot | 定时批量 | 由定时任务按 daily/weekly/total 周期生成快照，不承担奖励发放职责 |

## admin stats DTO 与 learner rank DTO 字段差异

| 维度 | Admin stats DTO | Learner rank DTO |
|---|---|---|
| 视角 | 平台/课程/活跃度聚合 | 单榜单个人排行项 |
| 主键 | `generated_at` 或 `course_id` | `id` + `board_type` + `period_key` |
| 指标类型 | 完成率、活跃人数、平均学习时长、AI 次数 | `score`、`rank_position`、`current_xp_balance`、`badge_count` |
| 个人标识 | 可不暴露具体 learner 明细 | 必须包含 `learner_profile` 与 `learner_id` |
| 奖励关系 | 只消费奖励真相源派生后的聚合值 | 展示奖励投影字段，但不作为奖励真相源 |

## 派生约束

- 排行榜快照仅用于展示，不得作为奖励发放真相源。
- 关键统计值必须由服务端统一派生，客户端不得自行推导课程完成率、挑战完成率、DAU、XP 等口径。
- 统计时间字段统一使用 UTC RFC3339；标识字段统一使用 UUID；枚举统一使用 lower_snake_case。
