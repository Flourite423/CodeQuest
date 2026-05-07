# Practice and Submission Field Dictionary

## Scope

本文件定义练习、选项、测试用例、提交与 AI 辅助相关字段字典，约束 learner/admin 可见性边界，并补充评测状态与隐藏用例规则。

## Exercise

| Field | Type | Required | Visibility | Description |
| --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | shared | 练习主标识 |
| `chapter_id` | `string(uuid)` | Y | shared | 关联章节 |
| `exercise_code` | `string` | Y | shared | 稳定业务编码 |
| `title` | `string` | Y | shared | 标题 |
| `prompt` | `string` | Y | shared | 题目说明 |
| `exercise_type` | `string(enum)` | Y | shared | 题型，仅允许 `single_choice`、`coding` |
| `starter_code` | `string` | N | shared | 初始代码模板 |
| `language` | `string(enum)` | Y | shared | 代码语言，当前固定 `html_css` |
| `difficulty` | `string(enum)` | Y | shared | 难度，仅允许 `easy`、`medium`、`hard` |
| `pass_score` | `integer` | Y | shared | 通过阈值，建议 0..100 |
| `max_attempts_per_day` | `integer` | N | shared | 每日尝试上限，`null` 表示无限 |
| `status` | `string(enum)` | Y | admin可见 / learner按发布过滤 | 题目状态，仅允许 `draft`、`published`、`archived` |
| `content_version` | `integer` | Y | shared | 内容版本号，用于提交一致性校验 |
| `created_at` | `string(date-time)` | Y | admin可见 | UTC RFC3339 创建时间 |
| `updated_at` | `string(date-time)` | Y | admin可见 | UTC RFC3339 更新时间 |

## ExerciseOption

| Field | Type | Required | Visibility | Description |
| --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | shared | 选项主标识 |
| `exercise_id` | `string(uuid)` | Y | shared | 所属练习 |
| `option_key` | `string` | Y | shared | 选项键，如 `A/B/C/D` |
| `option_text` | `string` | Y | shared | 选项文本 |
| `is_correct` | `boolean` | Y | admin可见 | 正确答案标记，learner 永不返回 |
| `order_index` | `integer` | Y | shared | 展示顺序 |

## ExerciseTestCase

| Field | Type | Required | Visibility | Description |
| --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | shared | 测试用例主标识 |
| `exercise_id` | `string(uuid)` | Y | shared | 所属练习 |
| `case_name` | `string` | Y | shared | 用例名称 |
| `case_type` | `string(enum)` | Y | shared | 用例类型，仅允许 `dom_snapshot`、`css_assert`、`text_match` |
| `input_payload_json` | `object` | N | admin可见 / learner仅公开用例可见 | 输入配置 |
| `expected_payload_json` | `object` | Y | admin可见 | 预期断言配置，learner 永不返回 |
| `weight` | `integer` | Y | shared | 分值权重 |
| `is_hidden` | `boolean` | Y | admin可见 | 是否隐藏用例，learner 不可见该标记本身 |
| `order_index` | `integer` | Y | shared | 顺序 |
| `rule_version` | `integer` | Y | shared | 规则版本号 |

## Submission

| Field | Type | Required | Visibility | Description |
| --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | learner可见 / admin可见 | 提交主标识 |
| `exercise_id` | `string(uuid)` | Y | learner可见 / admin可见 | 关联练习 |
| `learner_id` | `string(uuid)` | Y | learner本人可见 / admin可见 | 学习者账号标识 |
| `chapter_id` | `string(uuid)` | Y | learner可见 / admin可见 | 冗余章节标识，便于查询 |
| `attempt_no` | `integer` | Y | learner可见 / admin可见 | 第几次提交，从 1 开始 |
| `source_code` | `string` | Y | learner可见 / admin可见 | 本次提交代码 |
| `judge_status` | `string(enum)` | Y | learner可见 / admin可见 | 评测状态，见下方状态机 |
| `score` | `integer` | Y | learner可见 / admin可见 | 得分 |
| `passed_case_count` | `integer` | Y | learner可见 / admin可见 | 通过用例数 |
| `total_case_count` | `integer` | Y | learner可见 / admin可见 | 总用例数 |
| `error_summary` | `string` | N | learner可见 / admin可见 | 错误摘要；`error` 时表示系统评测故障，不表示答题错误 |
| `runtime_ms` | `integer` | N | learner可见 / admin可见 | 评测耗时 |
| `content_version` | `integer` | Y | learner可见 / admin可见 | 题目内容版本 |
| `rule_version` | `integer` | Y | learner可见 / admin可见 | 评测规则版本 |
| `submitted_at` | `string(date-time)` | Y | learner可见 / admin可见 | 提交时间 |
| `completed_at` | `string(date-time)` | N | learner可见 / admin可见 | 评测完成时间 |

## AIHelpRequest

| Field | Type | Required | Visibility | Description |
| --- | --- | --- | --- | --- |
| `id` | `string(uuid)` | Y | learner本人可见 / admin可见 | AI 请求主标识 |
| `learner_id` | `string(uuid)` | Y | learner本人可见 / admin可见 | 发起学习者 |
| `exercise_id` | `string(uuid)` | N | learner本人可见 / admin可见 | 关联练习 |
| `submission_id` | `string(uuid)` | N | learner本人可见 / admin可见 | 关联提交 |
| `request_type` | `string(enum)` | Y | learner本人可见 / admin可见 | 请求类型，见下方定义 |
| `source_code` | `string` | N | learner本人可见 / admin可见 | 提供给 AI 的代码上下文 |
| `error_context_json` | `object` | N | learner本人可见 / admin可见 | 错误上下文 |
| `response_text` | `string` | N | learner本人可见 / admin可见 | AI 文本回复 |
| `response_structured_json` | `object` | N | learner本人可见 / admin可见 | 结构化建议 |
| `provider_name` | `string` | Y | learner本人可见 / admin可见 | 第三方模型提供商 |
| `token_usage` | `integer` | N | learner本人可见 / admin可见 | token 消耗 |
| `latency_ms` | `integer` | N | learner本人可见 / admin可见 | 请求耗时 |
| `status` | `string(enum)` | Y | learner本人可见 / admin可见 | 处理状态，仅允许 `pending`、`succeeded`、`failed`、`rate_limited` |
| `created_at` | `string(date-time)` | Y | learner本人可见 / admin可见 | 创建时间 |

## Judge Status State Machine

评测状态机固定为：`pending -> running -> passed/failed/error`

- `pending`：提交已入队，尚未开始评测。
- `running`：评测执行中。
- `passed`：评测完成且达到通过标准。
- `failed`：评测完成但未达到通过标准，属于答题结果。
- `error`：系统评测故障，例如沙箱异常、编排失败、依赖服务不可用；不得与 `failed` 混用。

## AI Request Types

| Type | Meaning |
| --- | --- |
| `error_explanation` | 解释已有错误信息、失败现象或报错上下文 |
| `hint` | 给出非直接答案式提示，引导 learner 自行修正 |

## Hidden Test Case Rules

- learner 题目详情接口不得返回 `is_correct`、`expected_payload_json`、隐藏用例本体，避免泄露答案与断言策略。
- 当 `ExerciseTestCase.is_hidden = true` 时，该用例只能在 admin 详情或内部系统中可见。
- learner 可见测试用例只允许返回公开提示级信息，例如 `case_name`、`case_type`、`input_payload_json`（如确有公开输入）和权重。
- learner 提交详情只返回聚合评测结果，例如 `passed_case_count`、`total_case_count`、`score`、`error_summary`，不返回隐藏断言明细。
