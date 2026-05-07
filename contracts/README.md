# Contracts Directory

`contracts/` 保存三端共享的契约资产，其中 `contracts/openapi/openapi.yaml` 是唯一 API 契约真源。后端 API、Flutter 学习者移动端、运营管理后台都必须从这一份定义读取或生成，禁止拆分成 learner/admin 两套独立真源。

## 目录结构

- `openapi/openapi.yaml`：后端 API / 学习者移动端 / 运营管理后台共享的 OpenAPI 单一真源。
- `dictionaries/`：跨端共享的领域词典、枚举语义说明和命名解释。
- `state-machines/`：状态流转约定，描述跨端一致的状态机。
- `examples/`：示例请求、示例响应和集成参考片段。
- `mocks/`：联调或前端开发阶段使用的 mock 契约资产。

## OpenAPI 使用规则

- 顶层版本前缀固定为 `/api/v1`。
- 所有 path 与 schema 必须显式声明 `x-audience`、`x-permission`、`x-idempotent`。
- schema 名使用领域语义命名，禁止直接使用数据库表名。
- 所有 ID 使用 UUID；所有时间使用 UTC RFC3339；所有枚举值使用 `lower_snake_case`。

## 三端使用流程

1. 后端实现：以后端路由、鉴权与响应实现对齐 `contracts/openapi/openapi.yaml`，不得让代码实现先于契约漂移。
2. Flutter 学习者移动端：从同一份 OpenAPI 生成客户端模型、请求封装或校验代码；生成前先确认 `x-audience` 为 `learner` 或 `shared`。
3. 运营管理后台：从同一份 OpenAPI 生成管理端接口类型、SDK 或 mock；生成前先确认 `x-audience` 为 `admin` 或 `shared`。

## 版本兼容规则

- `v1` 内只允许向后兼容变更：新增可选字段、追加不改变旧语义的 path、追加枚举值。
- `v1` 内禁止删除字段、修改字段语义、改变响应包络结构、重定义已有枚举值。
- 删除字段、移除 path、改变必填约束或调整鉴权语义等 breaking change，只能进入 `/api/v2`。

## 三端联调顺序

所有端点必须按以下顺序推进，禁止跳过任何阶段：

1. **OpenAPI**：在 `contracts/openapi/openapi.yaml` 中定义或更新 path、schema、example。
2. **mock/examples**：根据 OpenAPI 生成或更新 mock 资产和请求/响应示例。
3. **backend impl**：后端实现路由、鉴权与响应，严格对齐契约。
4. **frontend adapters**：Flutter 与后台根据契约生成客户端模型、请求封装和校验代码。
5. **contract tests**：运行 schema 校验与 example 校验，确保实现与契约一致。
6. **end-to-end verify**：三端联调，端到端验证完整流程。

完整顺序: OpenAPI → mock/examples → backend impl → frontend adapters → contract tests → end-to-end verify

## Mock 资产目录结构

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

## Example 命名规范

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

## Breaking Change 审核流程

1. **标记**：提交契约变更前，先在设计评审中标记是否为 breaking change。
2. **影响评估**：如果影响既有消费者，必须给出迁移方案、影响范围和时间窗口。
3. **契约更新**：评审通过后，先更新 `contracts/openapi/openapi.yaml`，再同步后端、Flutter、后台生成物。
4. **回归确认**：合并前至少完成一次消费者回归确认，确保后端 API、学习者移动端和运营管理后台均理解变更。
5. **禁止行为**：不得跳过 contract diff 审查直接改接口；不得在 v1 内删除字段、修改字段语义或重定义枚举值。

## 三端协作 Checklist

- [ ] OpenAPI 定义已更新并经过 schema 校验
- [ ] mock 资产与 example 文件已同步更新
- [ ] 后端实现已与契约对齐并通过 contract tests
- [ ] Flutter 客户端已生成模型并通过 example 校验
- [ ] 运营管理后台已生成接口类型并通过 example 校验
- [ ] 三端已完成 end-to-end 联调验证
- [ ] 如涉及 breaking change，已完成影响评估与回归确认
