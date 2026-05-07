# 三端分离独立开发契约优先方案

## TL;DR
> **Summary**: 采用单后端服务 + 两套前端契约视图的 contract-first 架构，以一份 OpenAPI 作为唯一真源，先定义统一字段规范、角色模型、领域实体、状态机与错误模型，再按 learner/admin 两个 audience 输出稳定接口，保证后端、Flutter 学习端、Vue 管理后台可以并行开发并最终无缝对接。
> **Deliverables**:
> - 单一 OpenAPI 规范与 audience/tag 规则
> - 统一账号/JWT/RBAC 契约
> - 全局字段、错误、分页、审计、版本规范
> - 全量模块字段字典与状态机
> - learner/admin API 视图矩阵与 mock/fixture 规范
> **Effort**: Large
> **Parallel**: YES - 3 waves
> **Critical Path**: T1 契约基线 → T2 认证与全局规范 → T3-T6 领域契约 → T7-T8 管理与读模型 → T9 联调资产 → Final Verification Wave

## Context
### Original Request
用户希望三端分离独立开发，并要求给出一个精确到字段的设计方案，以保证后端 API、学习者移动端、运营管理后台在彼此独立开发后能够稳定对接。

### Interview Summary
- 三端已确认：`后端 API + 学习者移动端 + 运营管理后台`
- 契约真源已确认：`OpenAPI 唯一真源`
- 认证模型已确认：`统一账号底座 + 角色区分 + 不同登录入口`
- 覆盖范围已确认：`覆盖当前文档中全部已写模块，而不仅是 MVP 核心闭环`
- 既有技术栈约束已确认：`Salvo + SQLx + PostgreSQL` / `Flutter + GetX` / `Vue 3 + Element Plus + Pinia + TypeScript + Vite`

### Metis Review (gaps addressed)
- 已显式区分三层对象：`Canonical Domain Entity` / `API DTO` / `Persistence Model`
- 已补充高风险域要求：课程、题目、挑战、每日挑战、奖励、公告、审核、账号状态必须定义状态机
- 已补充全局契约要求：错误信封、分页/过滤/排序、ID/时间、审计字段、幂等与版本兼容
- 已补充派生域口径：排行榜、统计、奖励、AI 调用记录全部与交易真相源分离，不允许直接把读模型当业务真相

## Work Objectives
### Core Objective
产出一份可直接指导执行代理落地的三端分离契约优先方案：实现者无需再做接口边界、字段命名、状态含义、角色可见性、错误返回格式、分页规则、版本策略等判断。

### Deliverables
- `contracts/openapi/openapi.yaml` 的设计蓝图（单一真源）
- `contracts/dictionaries/*.md` 的字段字典蓝图
- `contracts/state-machines/*.md` 的状态机蓝图
- learner/admin audience 视图规则
- 全量核心实体字段定义与读写边界
- 三端 mock/fixture 与联调顺序

### Definition of Done (verifiable conditions with commands)
- `grep -n "^## Contract Baseline$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^### OpenAPI SSOT Organization$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^### Global Envelope and Field Standards$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^### Canonical Domain Entities$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^### Audience-specific DTO Views$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^### State Machines$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^## TODOs$" .sisyphus/plans/three-end-contract-first-integration.md`
- `grep -n "^## Final Verification Wave \(MANDATORY — after ALL implementation tasks\)$" .sisyphus/plans/three-end-contract-first-integration.md`

### Must Have
- 一份总 OpenAPI，使用 tag + `x-audience` 标注 learner/admin/internal，不拆成多份真源
- learner/admin 使用同一账号底座，但登录入口、令牌声明、可见字段、可操作资源分离
- 所有对外接口统一使用 `data/meta` 成功信封、统一错误信封
- 全部 ID 使用 UUID；全部时间使用 UTC RFC3339；枚举使用 lower_snake_case 字符串
- 统计、排行榜、勋章、经验值全部基于交易真相源派生
- 历史提交与后台内容编辑必须通过 `content_version` / `rule_version` 锁定版本

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- 不得把数据库字段直接暴露给前端作为最终 DTO
- 不得为未出现在现有需求中的模块发明新域：如支付、直播、私信、商城、推荐系统
- 不得把 learner/admin 页面结构或视觉稿混入本方案主体
- 不得把本方案扩张为 SQL 索引、部署编排、CI/CD、容器镜像细节
- 不得使用“接口合理”“字段完整”这类不可机检的模糊验收语句

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: tests-after + contract validation（OpenAPI lint、schema diff、example validation、mock server verification）
- QA policy: 每个任务必须同时包含“契约产物检查 + 示例请求/响应检查 + audience 边界检查”
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Contract Baseline
### OpenAPI SSOT Organization
- 单一真源文件：`contracts/openapi/openapi.yaml`
- 顶层 tags：
  - `auth`
  - `learner-account`
  - `learner-course`
  - `learner-practice`
  - `learner-challenge`
  - `learner-daily`
  - `learner-ai`
  - `learner-social`
  - `learner-reward`
  - `learner-profile`
  - `admin-course`
  - `admin-practice`
  - `admin-challenge`
  - `admin-user`
  - `admin-moderation`
  - `admin-announcement`
  - `admin-stats`
  - `admin-config`
  - `internal`
- 每个 path / schema 必带扩展字段：
  - `x-audience: learner | admin | shared | internal`
  - `x-permission: <resource.action>`
  - `x-idempotent: true|false`
- 版本策略：URL 固定前缀 `/api/v1`；新增字段只允许向后兼容追加；删除字段仅允许在 `v2`；枚举值仅允许追加不可重定义

### Global Envelope and Field Standards
#### Success Envelope
```json
{
  "data": {},
  "meta": {
    "request_id": "uuid",
    "server_time": "2026-05-07T10:00:00Z",
    "page": 1,
    "page_size": 20,
    "total": 100,
    "has_more": true
  }
}
```

#### Error Envelope
```json
{
  "error": {
    "code": "exercise_not_passed",
    "message": "exercise submission did not pass all checks",
    "field_errors": [
      { "field": "source_code", "code": "required", "message": "source_code is required" }
    ],
    "details": {},
    "retryable": false
  },
  "meta": {
    "request_id": "uuid",
    "server_time": "2026-05-07T10:00:00Z"
  }
}
```

#### Shared Field Rules
- `id`: `string(uuid)`，所有主键与外部引用统一格式
- `created_at` / `updated_at` / `published_at` / `completed_at`: `string(date-time, UTC)`
- `deleted_at`: 仅 persistence 层允许；对外 DTO 不暴露
- `version`: `integer`，用于乐观锁/内容版本
- `status`: `string(enum)`，统一 lower_snake_case
- `sort_order`: `integer`
- `is_*`: `boolean`
- `_count` / `_days` / `_minutes`: `integer`
- `*_url`: `string(uri)`
- `*_json`: 仅 internal 或 admin 配置 DTO 可用；learner DTO 禁止泛型 JSON 泄漏

#### Pagination / Filter / Sort
- 请求参数统一：
  - `page: integer >= 1`
  - `page_size: integer 1..100`
  - `sort_by: string`
  - `sort_order: asc | desc`
  - `keyword: string?`
  - `status: string?`
  - `date_from/date_to: string(date)?`
- 列表响应统一放入 `data.items[]`，分页元信息放入 `meta`

#### JWT Claims
- `sub: string(uuid)` account_id
- `role: learner | admin`
- `session_id: string(uuid)`
- `device_id: string`
- `scope: string[]`
- `token_version: integer`
- `exp/iat/nbf`: standard JWT timestamps

### Canonical Domain Entities
> 下列为领域真相源；DTO 可裁剪字段，持久化可拆表，但语义必须完全保持一致。

#### 1) Account
| 字段 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
|---|---|---:|---|---|---|---|
| id | uuid | Y | 账号ID | Y | Y | system |
| email | string(email) | Y | 唯一登录邮箱 | Y | Y | self/admin |
| password_hash | string | Y | 密码哈希，仅持久化 | N | N | system |
| default_role | enum(learner/admin) | Y | 默认登录角色 | Y | Y | admin |
| account_status | enum(active/suspended/closed) | Y | 账号状态 | Y | Y | admin/system |
| last_login_at | datetime | N | 最近登录时间 | Y | Y | system |
| created_at | datetime | Y | 创建时间 | Y | Y | system |
| updated_at | datetime | Y | 更新时间 | Y | Y | system |

#### 2) AccountRole
| 字段 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
|---|---|---:|---|---|---|---|
| id | uuid | Y | 角色记录ID | N | Y | system |
| account_id | uuid | Y | 账号ID | N | Y | system |
| role | enum(learner/admin) | Y | 角色类型 | Y | Y | admin |
| role_status | enum(enabled/disabled) | Y | 角色可用状态 | N | Y | admin |
| granted_at | datetime | Y | 授权时间 | N | Y | admin/system |
| revoked_at | datetime | N | 撤销时间 | N | Y | admin |

#### 3) LearnerProfile
| 字段 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
|---|---|---:|---|---|---|---|
| account_id | uuid | Y | 对应账号 | Y | Y | system |
| nickname | string(2..24) | Y | 昵称 | Y | Y | self/admin |
| avatar_url | string(uri) | N | 头像地址 | Y | Y | self/admin |
| bio | string(0..160) | N | 个人简介 | Y | Y | self |
| theme_mode | enum(system/light/dark) | Y | 主题模式 | Y | N | self |
| daily_goal_minutes | integer | Y | 每日学习目标分钟数 | Y | Y | self/admin |
| streak_days | integer | Y | 连续学习天数 | Y | Y | system |
| total_xp | integer | Y | 总经验值 | Y | Y | system |
| current_level | integer | Y | 当前等级 | Y | Y | system |
| friend_count | integer | Y | 好友数量 | Y | Y | system |
| ai_daily_limit | integer | Y | 每日 AI 配额 | Y | Y | admin/system |
| created_at | datetime | Y | 创建时间 | Y | Y | system |
| updated_at | datetime | Y | 更新时间 | Y | Y | system |

#### 4) AdminProfile
| 字段 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
|---|---|---:|---|---|---|---|
| account_id | uuid | Y | 对应账号 | N | Y | system |
| display_name | string(2..32) | Y | 后台显示名称 | N | Y | self/admin |
| avatar_url | string(uri) | N | 头像地址 | N | Y | self/admin |
| admin_status | enum(active/disabled) | Y | 后台使用状态 | N | Y | admin |
| last_active_at | datetime | N | 最近后台活跃时间 | N | Y | system |
| created_at | datetime | Y | 创建时间 | N | Y | system |
| updated_at | datetime | Y | 更新时间 | N | Y | system |

#### 5) Session
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 会话ID |
| account_id | uuid | Y | 账号ID |
| role | enum(learner/admin) | Y | 当前令牌角色 |
| device_id | string | Y | 设备标识 |
| device_name | string | N | 设备名称 |
| platform | enum(ios/android/web) | Y | 登录平台 |
| ip_address | string | N | 最近IP |
| user_agent | string | N | 最近UA |
| refresh_expires_at | datetime | Y | 刷新令牌过期时间 |
| revoked_at | datetime | N | 吊销时间 |
| last_seen_at | datetime | Y | 最近活跃时间 |
| created_at | datetime | Y | 创建时间 |

#### 6) Course
| 字段 | 类型 | 必填 | 说明 | learner可见 | admin可见 | 可写方 |
|---|---|---:|---|---|---|---|
| id | uuid | Y | 课程ID | Y | Y | system |
| course_code | string | Y | 稳定业务编码 | N | Y | admin |
| title | string(1..100) | Y | 课程标题 | Y | Y | admin |
| summary | string(0..300) | Y | 摘要 | Y | Y | admin |
| description | string | N | 详细描述 | Y | Y | admin |
| cover_image_url | string(uri) | N | 封面图 | Y | Y | admin |
| difficulty | enum(beginner/intermediate) | Y | 难度 | Y | Y | admin |
| estimated_minutes | integer | Y | 预计总时长 | Y | Y | admin |
| status | enum(draft/published/archived) | Y | 发布状态 | Y(仅published) | Y | admin |
| sort_order | integer | Y | 排序 | Y | Y | admin |
| content_version | integer | Y | 内容版本 | N | Y | system/admin |
| created_by | uuid | Y | 创建管理员 | N | Y | system |
| published_at | datetime | N | 发布时间 | Y | Y | system/admin |
| created_at | datetime | Y | 创建时间 | Y | Y | system |
| updated_at | datetime | Y | 更新时间 | Y | Y | system |

#### 7) Chapter
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 章节ID |
| course_id | uuid | Y | 所属课程 |
| chapter_code | string | Y | 稳定业务编码 |
| title | string | Y | 标题 |
| summary | string | Y | 摘要 |
| learning_content_markdown | string | Y | 图文内容主文稿 |
| sample_code | string | N | 示例代码 |
| estimated_minutes | integer | Y | 预计时长 |
| order_index | integer | Y | 顺序 |
| unlock_rule | enum(free/after_previous_completed) | Y | 解锁规则 |
| status | enum(draft/published/archived) | Y | 状态 |
| content_version | integer | Y | 内容版本 |
| created_at | datetime | Y | 创建时间 |
| updated_at | datetime | Y | 更新时间 |

#### 8) Exercise
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 练习ID |
| chapter_id | uuid | Y | 关联章节 |
| exercise_code | string | Y | 稳定业务编码 |
| title | string | Y | 标题 |
| prompt | string | Y | 题目说明 |
| exercise_type | enum(single_choice/coding) | Y | 题型 |
| starter_code | string | N | 初始代码 |
| language | enum(html_css) | Y | 代码语言 |
| difficulty | enum(easy/medium/hard) | Y | 难度 |
| pass_score | integer | Y | 通过阈值 |
| max_attempts_per_day | integer | N | 每日尝试限制，null 表示无限 |
| status | enum(draft/published/archived) | Y | 状态 |
| content_version | integer | Y | 内容版本 |
| created_at | datetime | Y | 创建时间 |
| updated_at | datetime | Y | 更新时间 |

#### 9) ExerciseOption
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 选项ID |
| exercise_id | uuid | Y | 所属练习 |
| option_key | string | Y | A/B/C/D |
| option_text | string | Y | 选项文本 |
| is_correct | boolean | Y | 正确答案，仅admin/internal可见 |
| order_index | integer | Y | 顺序 |

#### 10) ExerciseTestCase
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 测试用例ID |
| exercise_id | uuid | Y | 所属练习 |
| case_name | string | Y | 名称 |
| case_type | enum(dom_snapshot/css_assert/text_match) | Y | 用例类型 |
| input_payload_json | object | N | 输入配置 |
| expected_payload_json | object | Y | 预期配置 |
| weight | integer | Y | 分值权重 |
| is_hidden | boolean | Y | 是否隐藏用例 |
| order_index | integer | Y | 顺序 |
| rule_version | integer | Y | 规则版本 |

#### 11) Submission
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 提交ID |
| exercise_id | uuid | Y | 练习ID |
| learner_id | uuid | Y | 学习者账号ID |
| chapter_id | uuid | Y | 冗余章节ID，用于查询 |
| attempt_no | integer | Y | 第几次提交 |
| source_code | string | Y | 提交代码 |
| judge_status | enum(pending/running/passed/failed/error) | Y | 评测状态 |
| score | integer | Y | 得分 |
| passed_case_count | integer | Y | 通过用例数 |
| total_case_count | integer | Y | 总用例数 |
| error_summary | string | N | 错误摘要 |
| runtime_ms | integer | N | 评测耗时 |
| content_version | integer | Y | 对应题目版本 |
| rule_version | integer | Y | 对应用例版本 |
| submitted_at | datetime | Y | 提交时间 |
| completed_at | datetime | N | 评测完成时间 |

#### 12) CourseProgress
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 进度记录ID |
| learner_id | uuid | Y | 学习者 |
| course_id | uuid | Y | 课程 |
| completed_chapter_count | integer | Y | 已完成章节数 |
| total_chapter_count | integer | Y | 总章节数 |
| completed_exercise_count | integer | Y | 已完成练习数 |
| progress_percent | integer | Y | 百分比 0..100 |
| last_studied_chapter_id | uuid | N | 最近学习章节 |
| status | enum(not_started/in_progress/completed) | Y | 状态 |
| started_at | datetime | N | 开始时间 |
| completed_at | datetime | N | 完成时间 |
| updated_at | datetime | Y | 更新时间 |

#### 13) Challenge
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 关卡ID |
| challenge_code | string | Y | 稳定业务编码 |
| title | string | Y | 标题 |
| summary | string | Y | 摘要 |
| related_course_id | uuid | N | 关联课程 |
| difficulty | enum(easy/medium/hard) | Y | 难度 |
| reward_xp | integer | Y | 通关经验值 |
| status | enum(draft/published/archived) | Y | 状态 |
| sort_order | integer | Y | 排序 |
| content_version | integer | Y | 内容版本 |
| created_at | datetime | Y | 创建时间 |
| updated_at | datetime | Y | 更新时间 |

#### 14) ChallengeStage
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 子关卡ID |
| challenge_id | uuid | Y | 关卡ID |
| exercise_id | uuid | Y | 关联练习 |
| order_index | integer | Y | 顺序 |
| star_rule_json | object | Y | 星级规则 |
| unlock_rule_json | object | Y | 解锁规则 |
| rule_version | integer | Y | 规则版本 |

#### 15) ChallengeAttempt
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 挑战记录ID |
| challenge_id | uuid | Y | 关卡 |
| learner_id | uuid | Y | 学习者 |
| best_star | integer | Y | 最佳星级 0..3 |
| status | enum(locked/unlocked/in_progress/completed) | Y | 状态 |
| started_at | datetime | N | 开始时间 |
| completed_at | datetime | N | 完成时间 |
| reward_claimed_at | datetime | N | 奖励领取时间 |
| updated_at | datetime | Y | 更新时间 |

#### 16) DailyChallenge
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 每日挑战ID |
| challenge_date | date | Y | 生效日期 |
| title | string | Y | 标题 |
| exercise_id | uuid | Y | 关联练习 |
| difficulty | enum(easy/medium/hard) | Y | 难度 |
| time_limit_seconds | integer | Y | 限时 |
| reward_xp | integer | Y | 奖励经验值 |
| status | enum(scheduled/active/closed) | Y | 状态 |
| published_at | datetime | Y | 发布时间 |

#### 17) DailyChallengeRecord
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 参与记录ID |
| daily_challenge_id | uuid | Y | 每日挑战 |
| learner_id | uuid | Y | 学习者 |
| status | enum(not_started/passed/failed/expired) | Y | 结果状态 |
| score | integer | Y | 分数 |
| elapsed_seconds | integer | N | 用时 |
| streak_after_completion | integer | Y | 完成后连续天数 |
| completed_at | datetime | N | 完成时间 |

#### 18) AIHelpRequest
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | AI请求ID |
| learner_id | uuid | Y | 学习者 |
| exercise_id | uuid | N | 关联练习 |
| submission_id | uuid | N | 关联提交 |
| request_type | enum(error_explanation/hint) | Y | 请求类型 |
| source_code | string | N | 上下文代码 |
| error_context_json | object | N | 错误上下文 |
| response_text | string | N | AI回复文本 |
| response_structured_json | object | N | 结构化建议 |
| provider_name | string | Y | 第三方提供商 |
| token_usage | integer | N | token消耗 |
| latency_ms | integer | N | 耗时 |
| status | enum(pending/succeeded/failed/rate_limited) | Y | 处理状态 |
| created_at | datetime | Y | 创建时间 |

#### 19) FriendRelation
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 关系ID |
| requester_id | uuid | Y | 发起人 |
| addressee_id | uuid | Y | 被申请人 |
| status | enum(pending/accepted/rejected/blocked) | Y | 状态 |
| created_at | datetime | Y | 申请时间 |
| responded_at | datetime | N | 响应时间 |

#### 20) SocialActivity
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 动态ID |
| learner_id | uuid | Y | 发布者 |
| activity_type | enum(challenge_completed/badge_earned/streak_reached/course_completed) | Y | 动态类型 |
| visibility | enum(friends_only/public_in_app/private) | Y | 可见范围 |
| payload_json | object | Y | 结构化动态负载 |
| created_at | datetime | Y | 创建时间 |

#### 21) LeaderboardSnapshot
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 榜单记录ID |
| board_type | enum(daily/weekly/total) | Y | 榜单类型 |
| period_key | string | Y | 周期键，例如 2026-W19 |
| learner_id | uuid | Y | 学习者 |
| score | integer | Y | 榜单分值 |
| rank_position | integer | Y | 排名 |
| generated_at | datetime | Y | 生成时间 |

#### 22) XpLedger
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 流水ID |
| learner_id | uuid | Y | 学习者 |
| source_type | enum(chapter/exercise/challenge/daily/admin_adjustment) | Y | 来源类型 |
| source_id | uuid | Y | 来源ID |
| delta_xp | integer | Y | 增减值 |
| balance_after | integer | Y | 变更后余额 |
| created_at | datetime | Y | 创建时间 |

#### 23) Badge
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 徽章ID |
| badge_code | string | Y | 稳定编码 |
| name | string | Y | 名称 |
| description | string | Y | 描述 |
| icon_url | string(uri) | N | 图标 |
| rule_type | enum(streak/course/challenge/manual) | Y | 触发规则类型 |
| rule_config_json | object | Y | 规则配置 |
| status | enum(draft/published/archived) | Y | 状态 |
| created_at | datetime | Y | 创建时间 |
| updated_at | datetime | Y | 更新时间 |

#### 24) LearnerBadge
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 授予记录ID |
| learner_id | uuid | Y | 学习者 |
| badge_id | uuid | Y | 徽章 |
| award_source_type | enum(system/manual) | Y | 授予来源 |
| award_source_id | uuid | N | 来源ID |
| awarded_at | datetime | Y | 授予时间 |

#### 25) FeedbackTicket
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 反馈ID |
| learner_id | uuid | Y | 提交人 |
| category | enum(content/problem/bug/account/other) | Y | 反馈类型 |
| content | string | Y | 反馈内容 |
| screenshot_urls | array(uri) | N | 截图列表 |
| status | enum(open/in_progress/resolved/closed) | Y | 状态 |
| admin_reply | string | N | 管理员回复 |
| replied_at | datetime | N | 回复时间 |
| created_at | datetime | Y | 创建时间 |

#### 26) ModerationCase
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 审核单ID |
| case_type | enum(nickname/avatar/feedback) | Y | 审核类型 |
| target_id | uuid | Y | 目标ID |
| target_snapshot_json | object | Y | 提审快照 |
| status | enum(pending/approved/rejected) | Y | 审核状态 |
| decision_reason | string | N | 决策原因 |
| reviewed_by | uuid | N | 审核人 |
| reviewed_at | datetime | N | 审核时间 |
| created_at | datetime | Y | 创建时间 |

#### 27) Announcement
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 公告ID |
| title | string | Y | 标题 |
| body_markdown | string | Y | 正文 |
| audience | enum(all_learners/all_admins/all) | Y | 面向对象 |
| status | enum(draft/published/expired) | Y | 状态 |
| published_at | datetime | N | 发布时间 |
| expires_at | datetime | N | 过期时间 |
| created_by | uuid | Y | 创建者 |
| created_at | datetime | Y | 创建时间 |
| updated_at | datetime | Y | 更新时间 |

#### 28) SystemConfig
| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| id | uuid | Y | 配置ID |
| config_key | string | Y | 配置键 |
| config_scope | enum(system/ai/challenge/reward) | Y | 范围 |
| value_json | object | Y | 配置值 |
| status | enum(active/inactive) | Y | 状态 |
| updated_by | uuid | Y | 更新人 |
| updated_at | datetime | Y | 更新时间 |

### Audience-specific DTO Views
#### Learner DTO Rules
- learner 永远拿不到：`password_hash`, `is_correct`, `expected_payload_json`, `target_snapshot_json`, `value_json` 中的敏感内部配置
- learner 列表 DTO 只返回当前页面需要字段，禁止返回 admin 内部审计字段
- learner 成功 DTO 命名：`Learner<Course|Chapter|Exercise|Submission...>Response`

#### Admin DTO Rules
- admin 可读取运营与审计字段：`status`, `content_version`, `rule_version`, `created_by`, `reviewed_by`, `updated_at`
- admin 可读取题目正确答案、隐藏测试用例、配置 JSON，但这些字段绝不下发到 learner audience
- admin DTO 命名：`Admin<Course|Exercise|Challenge...>Response`

#### Shared Authentication DTOs
- `POST /api/v1/auth/learner/login`
- `POST /api/v1/auth/admin/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- 登录响应统一：
  - `account_id`
  - `active_role`
  - `access_token`
  - `refresh_token`
  - `expires_in`
  - `session_id`
  - `profile`

### State Machines
#### Account Status
- `active -> suspended -> active`
- `active -> closed`
- `closed` 不可逆，需保留历史学习与审计数据

#### Course / Chapter / Exercise / Challenge / Badge / Announcement
- `draft -> published -> archived`
- `draft` 仅 admin 可见
- `published` learner 可见
- `archived` learner 不可新进入，但历史关联记录仍可读

#### Submission
- `pending -> running -> passed`
- `pending -> running -> failed`
- `pending -> running -> error`
- `error` 仅表示系统/评测故障，不等同答题失败

#### ChallengeAttempt
- `locked -> unlocked -> in_progress -> completed`

#### DailyChallengeRecord
- `not_started -> passed`
- `not_started -> failed`
- `not_started -> expired`

#### FriendRelation
- `pending -> accepted`
- `pending -> rejected`
- `accepted -> blocked`

#### FeedbackTicket
- `open -> in_progress -> resolved -> closed`

#### ModerationCase
- `pending -> approved`
- `pending -> rejected`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: T1 契约基线、T2 认证与全局规范

Wave 2: T3 学习内容域、T4 练习/提交/AI 域、T5 挑战/每日挑战/奖励域、T6 社交/个人中心域

Wave 3: T7 后台运营域、T8 统计与派生读模型、T9 三端 mock/fixture 与联调机制

### Dependency Matrix (full, all tasks)
| Task | Depends On | Blocks |
|---|---|---|
| T1 | - | T2-T9 |
| T2 | T1 | T3-T9 |
| T3 | T1,T2 | T9 |
| T4 | T1,T2 | T9 |
| T5 | T1,T2 | T9 |
| T6 | T1,T2 | T9 |
| T7 | T1,T2 | T9 |
| T8 | T3-T7 | T9 |
| T9 | T3-T8 | Final |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → deep / ultrabrain
- Wave 2 → 4 tasks → deep / unspecified-high
- Wave 3 → 3 tasks → deep / writing / unspecified-high

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. 固化 OpenAPI 单一真源与目录约定

  **What to do**: 在计划执行时先创建契约目录蓝图，确定 `contracts/openapi/openapi.yaml` 为唯一真源，定义 tag、`x-audience`、`x-permission`、`x-idempotent` 扩展规则，以及 `components/schemas`、`components/parameters`、`components/responses` 的命名规范。
  **Must NOT do**: 不得拆成 learner/admin 两份独立真源；不得把数据库表名当 schema 名；不得让实现者各自写私有接口文档。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 需要做跨三端 SSOT 设计，后续所有任务都依赖该约定
  - Skills: [`salvo-openapi`] - 需要围绕 Salvo 的 OpenAPI 产物组织后续实现
  - Omitted: [`salvo-database`] - 本任务不进入落库

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [2,3,4,5,6,7,8,9] | Blocked By: []

  **References**:
  - Pattern: `doc/技术栈选型.md:3-32` - 固定三端技术栈边界
  - Pattern: `doc/软件需求规格说明书.md:48-66` - 明确产品范围与排除项
  - Pattern: `doc/软件需求规格说明书.md:117-140` - learner/admin 模块清单

  **Acceptance Criteria** (agent-executable only):
  - [ ] 计划产物明确唯一 OpenAPI 文件路径、命名规范、audience/tag 规则
  - [ ] 计划产物给出至少 1 个 learner path 与 1 个 admin path 的 schema 命名示例
  - [ ] 计划产物给出兼容性规则：新增字段、枚举扩展、版本升级的允许/禁止事项

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: SSOT 章节存在且可机检
    Tool: Bash
    Steps: grep -n "^### OpenAPI SSOT Organization$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-1-openapi-ssot.txt

  Scenario: learner/admin audience 规则已明确
    Tool: Bash
    Steps: grep -n "x-audience" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 至少出现1次 learner、1次 admin、1次 shared
    Evidence: .sisyphus/evidence/task-1-openapi-ssot-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define openapi ssot conventions` | Files: [contracts/openapi/openapi.yaml, contracts/README.md]

- [x] 2. 定义统一认证、角色与全局字段规范

  **What to do**: 定义 account/account_role/profile/session/JWT claim 契约，锁定 learner/admin 登录入口、统一 error envelope、success envelope、分页、排序、过滤、幂等键、审计字段、乐观锁版本字段。
  **Must NOT do**: 不得让 learner/admin 共用完全相同的 profile DTO；不得暴露 `password_hash`、内部刷新令牌、内部审计字段。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 该任务决定所有接口可见性与安全边界
  - Skills: [`salvo-auth`] - 需要围绕 JWT 与角色边界设计
  - Omitted: [`salvo-database`] - 不落到物理表实现

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [3,4,5,6,7,8,9] | Blocked By: [1]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:121-140` - learner/admin 核心功能边界
  - Pattern: `doc/软件需求规格说明书.md:244-260` - 注册输出字段已有用户ID/认证令牌语义
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:95-111` - 角色权限矩阵

  **Acceptance Criteria** (agent-executable only):
  - [ ] 明确 learner/admin 两个登录 path、统一刷新与登出 path
  - [ ] JWT claims 清单完整，包含 `sub role session_id device_id scope token_version`
  - [ ] 错误信封与成功信封给出 JSON 示例
  - [ ] 分页/排序/过滤参数名称与数据类型固定

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: JWT claim 清单存在
    Tool: Bash
    Steps: grep -n "^#### JWT Claims$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配且后续包含 sub、role、session_id
    Evidence: .sisyphus/evidence/task-2-auth-fields.txt

  Scenario: 错误信封已定义字段级错误
    Tool: Bash
    Steps: grep -n "field_errors" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-2-auth-fields-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define auth and global envelopes` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/global-fields.md]

- [x] 3. 定义课程与章节领域契约

  **What to do**: 输出 course/chapter 的 canonical entity、learner/admin DTO 视图、列表与详情接口、发布状态机、排序规则、内容版本规则、解锁规则。
  **Must NOT do**: 不得把 draft 内容下发给 learner；不得遗漏 `content_version`；不得把富文本内容与管理后台内部配置混为同一个 DTO。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 学习路径和内容发布是全系统主骨架
  - Skills: [`salvo-basic-app`] - 需要面向 HTTP 资源建模
  - Omitted: [`salvo-database`] - 本任务仍是契约建模

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [8,9] | Blocked By: [1,2]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:121-140` - 课程管理、课程学习功能
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:138-187` - 课程单元与章节的业务含义

  **Acceptance Criteria** (agent-executable only):
  - [ ] 定义 `GET /api/v1/learner/courses` 与 `GET /api/v1/learner/courses/{course_id}` 示例
  - [ ] 定义 `GET/POST/PATCH /api/v1/admin/courses` 与章节 CRUD 示例
  - [ ] 课程/章节字段至少覆盖标题、摘要、排序、状态、版本、发布时间、预计时长

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 课程实体字段已列出
    Tool: Bash
    Steps: grep -n "^#### 6) Course$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-3-course-contract.txt

  Scenario: 课程状态机存在
    Tool: Bash
    Steps: grep -n "draft -> published -> archived" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-3-course-contract-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define course and chapter contracts` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/course-fields.md]

- [x] 4. 定义练习、提交评测与 AI 辅助契约

  **What to do**: 输出 exercise/option/test_case/submission/ai_help_request 的字段、DTO、同步/异步返回语义、隐藏用例与 learner 可见结果边界、AI 提示与错误解释请求/响应格式。
  **Must NOT do**: 不得把 `is_correct`、隐藏用例、预期断言直接返回给 learner；不得把系统评测故障与答题失败混为一谈。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 这是跨 learner、judge、AI 依赖最复杂的接口域
  - Skills: [`salvo-data-extraction`, `salvo-error-handling`] - 需要精确定义提交/错误契约
  - Omitted: [`salvo-websocket`] - 当前仅规划 REST 优先，WebSocket 为可选补充

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [8,9] | Blocked By: [1,2]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:211-236` - 编码练习、AI 辅助、后台题目管理
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:188-234` - 练习与测验业务规则
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:60-65` - AI 错误分析场景

  **Acceptance Criteria** (agent-executable only):
  - [ ] 定义 learner 题目详情、代码提交、提交详情、AI 请求四类接口示例
  - [ ] 明确 `judge_status`、`score`、`passed_case_count`、`error_summary` 字段语义
  - [ ] 明确 admin 题目管理接口可见正确答案与隐藏用例，learner 不可见

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 提交实体字段已定义
    Tool: Bash
    Steps: grep -n "^#### 11) Submission$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-4-practice-contract.txt

  Scenario: AI 仅支持错误解释与提示
    Tool: Bash
    Steps: grep -n "request_type | enum(error_explanation/hint)" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-4-practice-contract-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define exercise submission and ai contracts` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/practice-fields.md]

- [x] 5. 定义闯关、每日挑战与奖励领域契约

  **What to do**: 输出 challenge/challenge_stage/challenge_attempt/daily_challenge/daily_challenge_record/xp_ledger/badge/learner_badge 字段、版本规则、状态机与结算逻辑接口。
  **Must NOT do**: 不得让排行榜或勋章结果直接成为奖励真相源；不得遗漏 `rule_version` 与奖励结算时间。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 规则域多、派生关系强、容易出现统计与奖励口径不一致
  - Skills: [`salvo-routing`] - 需要清晰拆分资源路径
  - Omitted: [`salvo-caching`] - 当前不做性能优化方案

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [8,9] | Blocked By: [1,2]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:123-129` - 闯关、每日挑战、奖励成长功能
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:236-260` - 每日挑战规则

  **Acceptance Criteria** (agent-executable only):
  - [ ] challenge 与 daily challenge 两套状态机明确
  - [ ] XP 与徽章以流水/授予记录作为真相源，字段齐全
  - [ ] learner 接口包含关卡地图、挑战详情、奖励列表；admin 接口包含关卡与奖励规则管理

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 奖励流水字段存在
    Tool: Bash
    Steps: grep -n "^#### 22) XpLedger$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-5-challenge-reward.txt

  Scenario: 每日挑战记录状态已列出
    Tool: Bash
    Steps: grep -n "not_started -> passed" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-5-challenge-reward-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define challenge daily and reward contracts` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/challenge-reward-fields.md]

- [x] 6. 定义社交互动与个人中心契约

  **What to do**: 输出 learner_profile/friend_relation/social_activity/leaderboard_snapshot 的字段、好友关系状态、动态可见性、个人中心聚合 DTO、主题设置与学习统计摘要字段。
  **Must NOT do**: 不得引入站外分享、私信、实时聊天；不得让 admin 配置字段下发到 learner 个人中心。

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: 领域较明确，但存在可见性与隐私边界
  - Skills: [] - 纯契约规划即可
  - Omitted: [`salvo-realtime`] - 需求明确排除实时通讯

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [8,9] | Blocked By: [1,2]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:126-129` - 社交互动、个人中心、奖励成长功能
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:67-79` - 社交与个人成长场景

  **Acceptance Criteria** (agent-executable only):
  - [ ] 定义好友申请、好友列表、动态流、排行榜、我的资料、主题设置接口示例
  - [ ] 明确 `visibility`、`friend_count`、`streak_days`、`theme_mode` 等字段
  - [ ] 明确社交仅限平台内，不出现外部分享字段

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 好友关系字段存在
    Tool: Bash
    Steps: grep -n "^#### 19) FriendRelation$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-6-social-profile.txt

  Scenario: 平台内社交边界未越界
    Tool: Bash
    Steps: grep -n "不得引入站外分享、私信、实时聊天" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-6-social-profile-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define social and profile contracts` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/social-profile-fields.md]

- [x] 7. 定义后台运营、审核、公告与系统配置契约

  **What to do**: 输出 admin 的用户管理、反馈处理、审核、公告、系统配置接口与字段，明确后台可读可写范围、内部 JSON 配置可见性与审计字段。
  **Must NOT do**: 不得将后台内部配置字段暴露给 learner；不得省略审核快照字段与操作人字段。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: admin 端拥有最广的配置与审计字段边界
  - Skills: [`salvo-middleware`] - 便于后续实现权限与审计链路
  - Omitted: [`salvo-session`] - 当前优先 JWT 契约而非会话实现

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: [9] | Blocked By: [1,2]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:131-140` - 后台核心功能
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:81-86` - 管理后台内容运营场景

  **Acceptance Criteria** (agent-executable only):
  - [ ] 定义 admin 用户管理、反馈管理、审核、公告、系统配置接口示例
  - [ ] 明确 `moderation_case`, `feedback_ticket`, `announcement`, `system_config` 字段
  - [ ] 明确所有后台写接口需要 `updated_by` / `reviewed_by` / `created_by` 类审计字段

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 审核单字段存在
    Tool: Bash
    Steps: grep -n "^#### 26) ModerationCase$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-7-admin-ops.txt

  Scenario: 公告字段存在
    Tool: Bash
    Steps: grep -n "^#### 27) Announcement$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-7-admin-ops-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define admin ops and config contracts` | Files: [contracts/openapi/openapi.yaml, contracts/dictionaries/admin-ops-fields.md]

- [x] 8. 定义统计、排行、奖励派生读模型与口径

  **What to do**: 单独定义统计与榜单为派生读模型，明确其来源表、刷新策略、字段口径、允许延迟与后台看板/用户侧排行榜 DTO；把统计口径写成固定字典，避免三端各自计算。
  **Must NOT do**: 不得把排行榜快照作为奖励发放真相源；不得让客户端自行推导关键统计值。

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: 需要统一交易真相与派生读模型，避免口径冲突
  - Skills: [] - 纯架构/契约建模
  - Omitted: [`salvo-caching`] - 不在本任务定义缓存实现

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: [9] | Blocked By: [3,4,5,6,7]

  **References**:
  - Pattern: `doc/软件需求规格说明书.md:137-140` - 数据统计与系统配置功能
  - Pattern: `.sisyphus/drafts/frontend-learning-app-requirements-doc.md:75-86` - 学习数据、后台数据统计场景

  **Acceptance Criteria** (agent-executable only):
  - [ ] 定义至少 5 个指标口径：学习时长、课程完成率、挑战完成率、AI 使用次数、日活学习者数
  - [ ] 明确 LeaderboardSnapshot/XpLedger/LearnerBadge 的来源与非来源关系
  - [ ] 明确 admin stats DTO 与 learner rank DTO 的字段差异

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 排行榜快照字段存在
    Tool: Bash
    Steps: grep -n "^#### 21) LeaderboardSnapshot$" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-8-read-models.txt

  Scenario: 奖励真相源规则已写明
    Tool: Bash
    Steps: grep -n "排行榜、统计、奖励、AI 调用记录全部与交易真相源分离" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-8-read-models-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define derived read models and metrics` | Files: [contracts/dictionaries/stats-metrics.md, contracts/openapi/openapi.yaml]

- [x] 9. 定义三端独立开发联调机制与 mock 资产

  **What to do**: 规定后端先交付 OpenAPI + examples + mock server；Flutter 与后台基于相同契约生成假数据/本地 mock；联调前先跑 schema 校验与 example 校验；定义 breaking change 审核流程。
  **Must NOT do**: 不得允许移动端或后台维护私有 mock 字段；不得跳过 contract diff 审查直接改接口。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 主要是流程、目录与协作协议落文档
  - Skills: [] - 以文档为主
  - Omitted: [`salvo-testing`] - 此处先定义 contract 验证流程，不写测试实现

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [Final] | Blocked By: [3,4,5,6,7,8]

  **References**:
  - Pattern: `doc/技术栈选型.md:3-32` - 三端技术栈固定，必须依赖同一契约协作
  - Pattern: `.sisyphus/drafts/three-end-separation-contract-design.md:1-25` - 当前规划目标就是三端字段级契约与独立开发对接

  **Acceptance Criteria** (agent-executable only):
  - [ ] 给出三端联调顺序：OpenAPI → mock/examples → backend impl → frontend adapters → contract tests → end-to-end verify
  - [ ] 给出 mock 资产目录、example 命名规范、breaking change 审核规则
  - [ ] 给出至少 1 个 learner 接口与 1 个 admin 接口的请求/响应 example 管理规则

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 联调流程已写明
    Tool: Bash
    Steps: grep -n "OpenAPI → mock/examples → backend impl → frontend adapters" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回1行匹配结果
    Evidence: .sisyphus/evidence/task-9-integration-flow.txt

  Scenario: breaking change 规则存在
    Tool: Bash
    Steps: grep -n "breaking change" .sisyphus/plans/three-end-contract-first-integration.md
    Expected: 返回至少1行匹配结果
    Evidence: .sisyphus/evidence/task-9-integration-flow-error.txt
  ```

  **Commit**: YES | Message: `docs(contract): define integration workflow and mock assets` | Files: [contracts/examples/, contracts/mocks/, contracts/README.md]

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle
- [x] F2. Code Quality Review — unspecified-high
- [x] F3. Real Manual QA — unspecified-high
- [x] F4. Scope Fidelity Check — deep

## Commit Strategy
- 提交按契约主题拆分，不混合多个域：
  - `docs(contract): define openapi ssot conventions`
  - `docs(contract): define auth and global envelopes`
  - `docs(contract): define course and chapter contracts`
  - `docs(contract): define exercise submission and ai contracts`
  - `docs(contract): define challenge daily and reward contracts`
  - `docs(contract): define social and profile contracts`
  - `docs(contract): define admin ops and config contracts`
  - `docs(contract): define derived read models and metrics`
  - `docs(contract): define integration workflow and mock assets`

## Success Criteria
- 任何一个执行代理只看该计划，即可明确三端边界、字段命名、状态含义、可见性、接口路径、错误格式与联调顺序
- learner/admin 对同一业务对象的字段视图差异是显式的、可机检的、不可误用的
- 后端实现前即可基于 OpenAPI mock 与 example 完成 Flutter 与后台的本地联调
- 后端实现后可通过 contract diff 检查判断是否存在 breaking change
- 奖励、统计、排行榜、AI 调用记录均有明确真相源与派生关系，不会在三端产生口径分歧
