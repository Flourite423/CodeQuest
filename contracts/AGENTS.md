# Contracts — 契约层开发指南

> 面向 AI Agent 的契约层规范。根目录规范见 [../AGENTS.md](../AGENTS.md)。

---

## 1. 核心原则

**Contract-first 开发**：任何 API 变更必须**先**更新 `openapi/openapi.yaml`，再实现后端和前端。

这是项目的第一铁律，确保三端始终对齐。

---

## 2. 目录结构

```
contracts/
├── openapi/
│   └── openapi.yaml         # OpenAPI 3.0 规范（唯一数据源）
├── state-machines/
│   └── ...                  # 业务状态机定义
├── dictionaries/
│   └── ...                  # 枚举/字典值定义
└── examples/
    └── ...                  # 请求/响应示例
```

---

## 3. OpenAPI 规范约定

### 3.1 响应信封格式

所有响应必须使用统一信封：

```yaml
responses:
  '200':
    description: OK
    content:
      application/json:
        schema:
          type: object
          properties:
            data:
              $ref: '#/components/schemas/SomeModel'
            message:
              type: string
              example: ok
```

后端返回：

```json
{
  "data": { ... },
  "message": "ok"
}
```

### 3.2 错误响应

```yaml
components:
  schemas:
    ApiError:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
```

### 3.3 路径命名

```yaml
# ✅ 正确：复数名词，kebab-case
/learner/courses
/learner/courses/{course-id}/chapters
/learner/daily-challenges/today

# ❌ 错误
/learner/course/list
/learner/getCourse
```

### 3.4 认证

使用 Bearer Token（JWT）：

```yaml
security:
  - bearerAuth: []

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## 4. 修改 API 的步骤

1. **编辑 `contracts/openapi/openapi.yaml`**
   - 添加/修改路径
   - 添加/修改 schemas
   - 添加/修改参数/响应

2. **通知相关端实现**
   - Backend：更新 Handler + Model
   - Mobile：更新 ApiService 调用 + Model
   - Admin：更新 Axios 调用

3. **验证对齐**
   - 确保三端的字段名、类型、必填属性一致

---

## 5. 验证工具

```bash
# 使用 swagger-cli 验证规范
cd contracts
swagger-cli validate openapi/openapi.yaml

# 或使用 openapi-generator 生成客户端代码
openapi-generator-cli generate \
  -i openapi/openapi.yaml \
  -g dart \
  -o ../mobile/lib/generated_api
```

---

## 6. 目录结构

```
contracts/
├── openapi/
│   └── openapi.yaml         # OpenAPI 3.0.3 规范（唯一数据源，5800+ 行）
├── state-machines/
│   └── ...                  # 业务状态机定义
├── dictionaries/
│   └── ...                  # 枚举/字典值定义
├── examples/
│   └── ...                  # 请求/响应示例（52 个文件）
└── mocks/
    ├── learner/             # 学习者移动端专用 mock（12 个文件）
    ├── admin/               # 运营管理后台专用 mock（9 个文件）
    └── shared/              # 两端共用 mock（5 个文件）
```

---

## 7. 三端使用流程

1. **后端实现**：以后端路由、鉴权与响应实现对齐 `contracts/openapi/openapi.yaml`，不得让代码实现先于契约漂移。
2. **Flutter 学习者移动端**：从同一份 OpenAPI 生成客户端模型、请求封装或校验代码；生成前先确认 `x-audience` 为 `learner` 或 `shared`。
3. **运营管理后台**：从同一份 OpenAPI 生成管理端接口类型、SDK 或 mock；生成前先确认 `x-audience` 为 `admin` 或 `shared`。

---

## 8. 版本兼容规则

- `v1` 内只允许向后兼容变更：新增可选字段、追加不改变旧语义的 path、追加枚举值。
- `v1` 内禁止删除字段、修改字段语义、改变响应包络结构、重定义已有枚举值。
- 删除字段、移除 path、改变必填约束或调整鉴权语义等 breaking change，只能进入 `/api/v2`。

---

## 9. 三端联调顺序

所有端点必须按以下顺序推进，禁止跳过任何阶段：

1. **OpenAPI**：在 `contracts/openapi/openapi.yaml` 中定义或更新 path、schema、example。
2. **mock/examples**：根据 OpenAPI 生成或更新 mock 资产和请求/响应示例。
3. **backend impl**：后端实现路由、鉴权与响应，严格对齐契约。
4. **frontend adapters**：Flutter 与后台根据契约生成客户端模型、请求封装和校验代码。
5. **contract tests**：运行 schema 校验与 example 校验，确保实现与契约一致。
6. **end-to-end verify**：三端联调，端到端验证完整流程。

完整顺序: OpenAPI → mock/examples → backend impl → frontend adapters → contract tests → end-to-end verify

---

## 10. Mock 资产目录结构

```
contracts/
  mocks/
    README.md           # mock 资产使用说明
    learner/            # 学习者移动端专用 mock
    admin/              # 运营管理后台专用 mock
    shared/             # 两端共用 mock
```

- 每个 mock 文件必须与 `contracts/openapi/openapi.yaml` 中的 schema 保持一致。
- 禁止移动端或后台维护私有 mock 字段；所有字段必须来自 OpenAPI 定义。

---

## 11. Example 命名规范

示例文件统一放在 `contracts/examples/` 目录下，命名格式为：

```
{audience}-{resource}-{action}.json
```

- `audience`：`learner`、`admin` 或 `shared`。
- `resource`：领域资源名，如 `course`、`chapter`、`exercise`。
- `action`：操作语义，如 `list`、`create`、`detail`、`submit`。

示例：
- `learner-course-list.json`：学习者获取课程列表
- `admin-course-create.json`：管理员创建课程
- `shared-auth-login.json`：共用登录接口
