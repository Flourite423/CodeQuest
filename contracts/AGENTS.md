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
