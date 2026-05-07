# Global Field Standards

## Scope

本文件定义三端共享契约中的统一字段命名、数据类型、JWT Claims、分页排序过滤参数，以及必填性与可见性标记规则。

## JWT Claims

| Claim | Type | Required | Description |
| --- | --- | --- | --- |
| `sub` | `string(uuid)` | Y | 账户主标识，对应 `account_id` |
| `role` | `string(enum)` | Y | 当前活跃角色，仅允许 `learner` 或 `admin` |
| `session_id` | `string(uuid)` | Y | 当前访问令牌绑定的会话标识 |
| `device_id` | `string` | Y | 登录设备唯一标识 |
| `scope` | `string[]` | Y | 已授予的权限范围列表，值使用 lower_snake_case |
| `token_version` | `integer` | Y | 令牌版本号，用于强制失效与批量轮换 |
| `exp` | `integer` | Y | JWT 过期时间，Unix timestamp seconds |
| `iat` | `integer` | Y | JWT 签发时间，Unix timestamp seconds |
| `nbf` | `integer` | N | JWT 生效时间，Unix timestamp seconds |

规则补充：

- `sub` 必须使用 UUID 字符串，不允许复用邮箱或数据库自增 ID。
- `role` 仅表达当前令牌上下文，不替代账户全部角色集合。
- `scope` 用于细粒度权限判定，命名采用 lower_snake_case 或 lower_snake_case dot path。
- `token_version` 变化时，旧令牌必须整体失效。
- `exp`、`iat`、`nbf` 一律使用标准 JWT NumericDate。

## Global Naming Rules

| Pattern | Type | Required Marker | Rule |
| --- | --- | --- | --- |
| `id` | `string(uuid)` | context driven | 所有主键与外部引用统一使用 UUID |
| `created_at` | `string(date-time)` | context driven | UTC RFC3339 时间 |
| `updated_at` | `string(date-time)` | context driven | UTC RFC3339 时间 |
| `deleted_at` | `string(date-time)` | N | 仅 persistence/internal 使用，对外 DTO 默认禁止暴露 |
| `version` | `integer` | N | 乐观锁或内容版本字段 |
| `status` | `string(enum)` | context driven | 枚举值统一 lower_snake_case |
| `sort_order` | `integer` or `string(enum)` | N | 排序权重字段用整数；请求参数用 `asc`/`desc` |
| `is_*` | `boolean` | context driven | 布尔字段统一 `is_` 前缀 |
| `*_count` | `integer` | N | 聚合数量字段 |
| `*_days` | `integer` | N | 天数累计字段 |
| `*_minutes` | `integer` | N | 分钟累计字段 |
| `*_url` | `string(uri)` | N | 可公开访问的 URI |
| `*_json` | `object` | N | 仅 internal 或 admin 配置 DTO 可用，learner DTO 禁止泛型 JSON 泄漏 |

补充命名要求：

- 字段名统一使用 `lower_snake_case`。
- Schema 名使用业务语义名，如 `LearnerProfile`、`AdminProfile`，不得直接复用数据库表名。
- 密码类输入仅允许使用 `password`，不得暴露 `password_hash`、`salt` 等持久化字段。

## Pagination, Sorting, and Filtering Parameters

| Name | Type | Required | Rule |
| --- | --- | --- | --- |
| `page` | `integer` | N | 从 1 开始 |
| `page_size` | `integer` | N | 取值范围 `1..100` |
| `sort_by` | `string` | N | 指向可排序字段名，使用 lower_snake_case |
| `sort_order` | `string(enum)` | N | 仅允许 `asc` 或 `desc` |
| `keyword` | `string` | N | 模糊搜索关键词 |
| `status` | `string(enum)` | N | 按业务状态过滤，枚举值 lower_snake_case |
| `date_from` | `string(date)` | N | 日期范围起点，闭区间下界 |
| `date_to` | `string(date)` | N | 日期范围终点，闭区间上界 |

列表响应统一约定：

- 列表数据放在 `data.items[]`。
- 分页元信息放在 `meta.page`、`meta.page_size`、`meta.total`、`meta.has_more`。

## Data Type Standards

| Logical Type | OpenAPI Type | Rule |
| --- | --- | --- |
| UUID | `string` + `format: uuid` | 所有 ID 与外部引用统一格式 |
| UTC RFC3339 | `string` + `format: date-time` | 所有时间字段一律使用 UTC |
| lower_snake_case enum | `string(enum)` | 禁止 mixedCase、UPPER_SNAKE_CASE |
| boolean | `boolean` | 与 `is_*` 前缀配套使用 |
| integer | `integer` | 计数、天数、分钟数、版本号优先使用 |
| string(uri) | `string` + `format: uri` | URL/URI 字段统一使用 |
| object | `object` | 仅在明确结构或受控配置场景使用 |

## Required Marker Standards

| Marker | Meaning |
| --- | --- |
| `Y` | 必填，客户端必须提交或服务端必须返回 |
| `N` | 可选，仅在有值时返回或在允许时提交 |

说明：

- 文档表格中的 `Required` 列统一使用 `Y/N`。
- 如果字段只在特定角色或特定状态下出现，也仍以 `Y/N` 表示基础契约，再在描述列补充条件。

## Visibility Marker Standards

| Marker | Meaning |
| --- | --- |
| `learner可见` | learner 客户端可读取 |
| `admin可见` | admin 客户端可读取 |
| `learner可写` | learner 客户端可提交 |
| `admin可写` | admin 客户端可提交 |
| `shared` | learner/admin 均可见或复用 |
| `internal` | 仅服务内部或持久化层使用，不对外公开 |

使用规则：

- 可见性必须和 DTO 语义一致，learner 与 admin 不得强行复用完全相同的 profile DTO。
- `*_json`、审计字段、内部控制字段默认标记为 `admin可见` 或 `internal`，不得无约束下发给 learner。
