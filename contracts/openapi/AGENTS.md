# OpenAPI — 契约规范开发指南

> 面向 AI Agent 的 OpenAPI 契约层规范。上级规范见 [../../AGENTS.md](../../AGENTS.md) 和 [../AGENTS.md](../AGENTS.md)。

---

## 1. 文件结构

```
contracts/openapi/
└── openapi.yaml          # 唯一真源，5725行，OpenAPI 3.0.3
```

**单一文件**，不拆分为多个文件，不包含 `$ref` 外部文件引用。

---

## 2. 路径规范

### 2.1 基础路径

```yaml
servers:
  - url: /api/v1
```

所有路径均相对于 `/api/v1`。

### 2.2 受众分组

| 前缀 | 用途 |
|------|------|
| `/auth/*` | 共享认证端点 |
| `/learner/*` | 学习者端点 |
| `/admin/*` | 管理后台端点 |

### 2.3 命名约定

```yaml
# ✅ 正确
/learner/courses
/learner/courses/{course_id}/chapters
/learner/daily-challenges/today

# ❌ 错误
/learner/course/list
/learner/getCourse
```

- 复数名词
- kebab-case
- UUID 路径参数使用 snake_case：`{course_id}`

### 2.4 必需扩展

每个操作必须有三个 `x-*` 扩展：

```yaml
x-audience: learner        # learner | admin | shared
x-permission: learner.course.read
x-idempotent: false        # true | false
```

---

## 3. 响应信封

### 3.1 成功响应

```json
{
  "data": { ... },
  "meta": {
    "request_id": "uuid",
    "server_time": "2026-05-08T09:30:00Z"
  }
}
```

### 3.2 列表响应

```json
{
  "data": {
    "items": [...],
    "meta": {
      "page": 1,
      "page_size": 20,
      "total": 100,
      "has_more": true
    }
  },
  "meta": {
    "request_id": "...",
    "server_time": "..."
  }
}
```

**注意**：分页元数据在 `data.meta` 中，顶层 `meta` 始终只有 `request_id` 和 `server_time`。

### 3.3 错误响应

```json
{
  "error": {
    "code": "lower_snake_case_error_code",
    "message": "Human-readable summary",
    "field_errors": [{ "field": "...", "code": "...", "message": "..." }],
    "details": {},
    "retryable": false
  },
  "meta": { "request_id": "...", "server_time": "..." }
}
```

---

## 4. Schema 规范

### 4.1 命名约定

| 类型 | 格式 | 示例 |
|------|------|------|
| Schema | PascalCase | `LearnerProfile` |
| 字段 | lower_snake_case | `course_id` |
| 枚举值 | lower_snake_case | `in_progress` |
| ID | string + format: uuid | — |
| 时间戳 | string + format: date-time | UTC RFC3339 |
| 布尔值 | is_* 前缀 | `is_published` |
| JSON 对象 | *_json 后缀 | `expected_payload_json` |
| URI | *_url 后缀 | `avatar_url` |

### 4.2 DTO 受众隔离

学习者 DTO **从不暴露**以下字段：
- `course_code`, `chapter_code`
- `created_by`
- `content_version`
- `is_correct`
- `expected_payload_json`

### 4.3 扩展类型

```yaml
# oneOf — 多态
profile:
  oneOf:
    - $ref: '#/components/schemas/LearnerProfile'
    - $ref: '#/components/schemas/AdminProfile'

# allOf — 列表项扩展
LearnerFriendListItem:
  allOf:
    - $ref: '#/components/schemas/FriendRelation'
    - type: object
      properties:
        friend_profile: { ... }
```

---

## 5. 标准组件

### 5.1 响应组件

`Ok`, `BadRequest`, `Unauthorized`, `Forbidden`, `NotFound`, `Conflict`, `InternalServerError`

### 5.2 查询参数

`page`（默认 1）、`page_size`（默认 20，最大 100）、`sort_by`、`sort_order`、`keyword`、`status`、`date_from`、`date_to`

---

## 6. 状态机

状态机定义在 `../state-machines/` 目录中：

| 状态机 | 状态 | 关键规则 |
|--------|------|----------|
| account | active → suspended → closed | closed 不可逆 |
| course | draft → published → archived | 无 rollback |
| challenge | locked → unlocked → in_progress → completed | 完成不可逆 |
| daily-challenge | not_started → passed/failed/expired | 每日结果不可变 |
| friend-relation | pending → accepted/rejected/blocked | 封锁单向 |
| moderation | pending → approved/rejected | 最终决定 |
| feedback | open → in_progress → resolved → closed | 关闭需新工单 |

---

## 7. 已知陷阱

| 问题 | 位置 | 严重性 |
|------|------|--------|
| LearnerPersonalStats 重复字段 | 第 5548-5613 行 | **高** — 生成无效 schema |
| 缺少 securitySchemes | 整个文件 | **中** — JWT 只在 AGENTS.md 中记录 |
| 双重分页元数据 | 列表端点 | 低 — 需了解区别 |

---

## 8. 添加新端点的步骤

1. **定义路径**：在 `openapi.yaml` 中添加，带完整 `tags`、`x-audience`、`x-permission`、`x-idempotent`
2. **命名 operationId**：`{Verb}{Domain}{Resource}`，如 `listAdminCourses`
3. **使用标准响应**：`$ref: '#/components/responses/Ok'`
4. **列表使用标准参数**：`$ref: '#/components/parameters/page'`
5. **添加 Schema**：遵循命名约定和受众隔离规则
6. **更新字典**：在 `../dictionaries/` 相应文件中添加字段定义
7. **添加状态机**：如适用，在 `../state-machines/` 中添加
8. **创建示例**：在 `../examples/` 中创建 `{audience}-{resource}-{action}.json`
9. **创建 Mock**：在 `../mocks/` 中创建

---

## 9. 版本兼容规则

- **v1 内只允许向后兼容变更**：新增可选字段、追加 path、追加枚举值
- **v1 内禁止**：删除字段、修改字段语义、改变响应包络结构、重定义枚举值
- **Breaking change 必须进入 `/api/v2`**

---

## 10. 六步工作流

```
OpenAPI → mock/examples → backend impl → frontend adapters → contract tests → end-to-end verify
```

**禁止跳过任何阶段。**
