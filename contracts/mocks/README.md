# Mock 资产说明

`contracts/mocks/` 目录保存三端联调与前端独立开发阶段使用的 mock 契约资产。

## 使用方式

- **前端独立开发**：当后端接口尚未实现时，Flutter 与后台前端可使用 mock 资产模拟 API 响应。
- **联调阶段**：三端约定 mock 数据格式，确保前端在对接真实接口前已完成数据结构与 UI 适配。
- **自动化测试**：mock 资产可作为 contract tests 的输入，验证后端实现与契约一致性。

## 生成规则

1. **来源唯一**：所有 mock 数据必须从 `contracts/openapi/openapi.yaml` 中的 schema 生成，禁止手写与 OpenAPI 定义不一致的字段。
2. **字段完整**：mock 响应必须包含该 schema 中所有 `required` 字段，且数据类型符合定义。
3. **枚举合规**：枚举值必须使用 `lower_snake_case`，且必须是 OpenAPI 中已定义的枚举值之一。
4. **ID 与时间**：所有 ID 使用 UUID；所有时间使用 UTC RFC3339 格式。
5. **角色隔离**：
   - `learner/` 目录仅存放 `x-audience: learner` 或 `x-audience: shared` 的接口 mock。
   - `admin/` 目录仅存放 `x-audience: admin` 或 `x-audience: shared` 的接口 mock。
   - `shared/` 目录存放两端共用的 mock，如认证、公共配置等。

## 更新流程

1. **契约变更驱动**：当 `contracts/openapi/openapi.yaml` 发生变更时，必须同步更新对应的 mock 资产。
2. **校验前置**：更新 mock 前，先运行 schema 校验工具确认新 mock 与 OpenAPI 定义一致。
3. **版本对齐**：mock 资产中的 path 与版本前缀必须与 OpenAPI 保持一致，当前为 `/api/v1`。
4. **禁止私有字段**：不得允许移动端或后台在 mock 中添加 OpenAPI 未定义的私有字段。

## 目录结构

```
contracts/mocks/
  README.md           # 本说明文件
  learner/            # 学习者移动端专用 mock
  admin/              # 运营管理后台专用 mock
  shared/             # 两端共用 mock
```

## 命名规范

mock 文件命名与 `contracts/examples/` 保持一致：

```
{audience}-{resource}-{action}.json
```

- `audience`：`learner`、`admin` 或 `shared`
- `resource`：领域资源名
- `action`：操作语义

## 示例

```json
{
  "path": "/api/v1/learner/courses",
  "method": "GET",
  "response": {
    "status": 200,
    "body": {
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
        "request_id": "uuid",
        "server_time": "2026-05-07T10:00:00Z"
      }
    }
  }
}
```
