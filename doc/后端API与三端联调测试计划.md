# 后端 API 与三端联调测试计划

## 1. 文档目的

本文档用于指导 CodeQuest 项目的后端 API 测试、管理后台联调测试、移动端联调测试与关键跨端烟雾测试，作为测试执行、缺陷跟踪与阶段验收的依据。

本文档重点解决以下问题：

- 后端实现是否与 `contracts/openapi/openapi.yaml` 保持一致。
- 管理后台与移动端是否能够正确消费后端接口。
- learner/admin 两类身份在鉴权、权限与错误场景下是否行为正确。
- 离线缓存、部分失败、未接线能力等高风险项是否被明确识别，而不是被误判为“已联调通过”。

---

## 2. 测试范围

### 2.1 后端 API

覆盖以下接口域：

- 认证：register、learner login、admin login、refresh、logout、me
- learner：profile、courses、exercises、submissions、challenges、daily-challenges、friends、activities、leaderboards、stats、rewards、progress
- admin：stats、courses、challenges、exercises、chapters、users、moderation、feedback、announcements、configs、daily-challenges

### 2.2 管理后台联调

覆盖以下真实接入点：

- `/auth/admin/login`
- `/admin/courses`
- `/admin/challenges`
- `/admin/exercises`
- `/admin/users`
- `/admin/stats/dashboard`
- `/admin/moderation`
- `/admin/feedback`
- `/admin/announcements`
- `/admin/configs`

### 2.3 移动端联调

覆盖以下真实接入点：

- `/auth/register`
- `/auth/learner/login`
- `/me`
- `/learner/profile`
- `/learner/courses`
- `/learner/exercises/{id}`
- `/learner/submissions`
- `/learner/challenges`
- `/learner/daily-challenges/today`
- `/learner/activities`
- `/learner/friends`
- `/learner/leaderboards`
- `/learner/stats/personal`
- `/learner/rewards`

### 2.4 不在本轮通过范围内的内容

以下内容可以测试现状，但不得在报告中宣称“联调通过”：

- 管理后台未接线或后端未提供的能力
- 移动端本地队列被清空但未真正同步到后端的能力
- 仅有 UI 壳、无真实请求链路的页面能力

---

## 3. 测试目标

1. 验证后端 API 与 OpenAPI 契约一致。
2. 验证核心业务流在真实 PostgreSQL 环境下可正确执行。
3. 验证 Admin 与 Mobile 对接口的请求、鉴权、响应解包与异常处理符合预期。
4. 验证关键跨端链路可打通，并能明确识别当前断点。

---

## 4. 测试策略

本项目采用四层测试策略，按以下顺序建立信心：

1. **契约层**：先确认实现是否符合 OpenAPI。
2. **后端集成层**：再验证真实数据库下的业务正确性。
3. **客户端服务层联调**：验证 Admin 与 Mobile 对接口的真实消费是否成立。
4. **跨端烟雾层**：仅保留少量高价值端到端链路，不以大面积 UI 自动化作为主要质量依据。

### 4.1 契约层

验证项：

- path 与 method 存在
- 状态码符合定义
- 成功响应包含 `data`
- 错误响应结构稳定
- `x-audience` 对应的鉴权与权限边界正确

通过标准：契约测试全部通过，新增或变更接口必须同步更新契约。

### 4.2 后端集成层

验证项：

- JWT 鉴权与 learner/admin 权限分流
- 写接口执行后的数据库状态
- 关键状态流转与幂等行为
- 400、401、403、404、500 等错误语义

通过标准：核心接口在真实 PostgreSQL 下可重复执行、结果稳定、数据可校验。

### 4.3 客户端服务层联调

验证项：

- 请求路径、参数、Header、Token 注入
- 成功/失败响应解包
- 401/403/404/500 等异常处理
- 并发请求、部分失败与超时
- 缓存、离线、回退与重试

通过标准：客户端不会因接口形状、权限边界或异常响应而产生错误成功判断。

### 4.4 跨端烟雾层

保留以下关键链路：

- Admin 创建内容后，Mobile 可见
- Learner 产生学习行为后，后端状态正确更新
- Token 失效后，Admin 与 Mobile 均进入正确的失效处理流程

通过标准：关键业务链路打通，且失败时能快速定位断点位于哪一层。

---

## 5. 测试环境与数据准备

### 5.1 环境组成

- Backend：本地或测试环境实例
- DB：独立 PostgreSQL 测试库
- Contract：固定使用 `contracts/openapi/openapi.yaml`
- Admin：开发环境，指向测试后端
- Mobile：开发环境，指向测试后端

### 5.2 环境要求

- 测试数据库必须与开发数据库隔离。
- 每轮执行前应清理测试数据并重新注入种子。
- learner 与 admin 测试账号必须分别准备。
- 时间相关测试应尽量使用固定时间或可控时间窗口。

### 5.3 基础种子数据

至少准备：

- 1 个 admin 账号
- 2 个 learner 账号
- 2 门课程：`draft`、`published`
- 1 个 challenge
- 1 个 daily challenge
- 1 组 friends / activities / leaderboard 数据
- 1 组 rewards / xp / progress 数据

### 5.4 数据管理原则

- 用例之间相互隔离
- 关键 ID 固定，便于复测和日志定位
- 所有写操作均可被回读验证

---

## 6. 测试入口与执行方式

### 6.1 后端测试入口

优先复用后端现有 Rust 集成测试体系：

- 真实 PostgreSQL
- Salvo `TestClient`
- 已有认证辅助能力
- 已有契约测试基础

### 6.2 Admin 联调入口

- 通过 `admin/src/api/*` 发起真实请求
- 重点验证登录、路由守卫、接口消费与异常处理
- 页面级验证以高价值管理流程为主

### 6.3 Mobile 联调入口

- 通过 `mobile/lib/services/api_service.dart` 及各控制器发起真实请求
- 重点验证 Dashboard 并发请求、练习提交、挑战流程、资料编辑、缓存与离线回退

---

## 7. 后端 API 测试用例

### 7.1 认证与权限

| 编号 | 用例名称 | 前置条件 | 步骤 | 预期结果 | 优先级 |
|------|----------|----------|------|----------|--------|
| A1 | learner 注册成功 | 无 | 调用 `POST /auth/register` | 返回成功状态，包含 `data.access_token` | P0 |
| A2 | learner 登录成功 | 已存在 learner 账号 | 调用 `POST /auth/learner/login` | 返回成功状态，可获得有效 token | P0 |
| A3 | admin 登录成功 | 已存在 admin 账号 | 调用 `POST /auth/admin/login` | 返回成功状态，可获得有效 token | P0 |
| A4 | 错误密码登录失败 | 已存在账号 | 使用错误密码登录 | 返回 401 | P0 |
| A5 | refresh 成功 | 已登录且有 refresh token | 调用 `POST /auth/refresh` | 返回新的 access token | P1 |
| A6 | logout 后会话失效 | 已登录 | 登出后访问受保护接口 | 返回 401 或会话失效响应 | P1 |
| A7 | learner 访问 admin 接口 | learner token | 调用 `/admin/users` | 返回 403 | P0 |
| A8 | 无 token 访问 learner 接口 | 无 | 调用 `/learner/profile` | 返回 401 | P0 |

### 7.2 learner 核心业务

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| B1 | 获取 learner profile | `GET /learner/profile` | 返回 200，资料字段完整 | P0 |
| B2 | 更新 learner profile | `PATCH /learner/profile` 后回读 | 变更字段持久化成功 | P0 |
| B3 | 课程列表只展示 learner 可见内容 | `GET /learner/courses` | draft/archived 不出现在列表 | P0 |
| B4 | 获取课程详情 | `GET /learner/courses/{id}` | 返回章节结构与课程信息 | P0 |
| B5 | 获取练习详情 | `GET /learner/exercises/{id}` | 返回题目内容与必要字段 | P1 |
| B6 | 提交练习成功 | `POST /learner/submissions` | 返回评分/结果，数据结构正确 | P0 |
| B7 | 挑战尝试成功 | `POST /learner/challenges/{id}/attempts` | 星级、奖励、状态更新正确 | P0 |
| B8 | 获取今日挑战 | `GET /learner/daily-challenges/today` | 返回当天 challenge 数据 | P1 |
| B9 | 提交今日挑战 | `POST /learner/daily-challenges/{id}/submit` | 返回成功并更新尝试状态 | P1 |
| B10 | 好友搜索 | `GET /learner/friends?q=...` | 返回匹配结果 | P2 |
| B11 | 发起好友请求 | `POST /learner/friends/requests` | 请求创建成功 | P2 |
| B12 | 获取统计/排行榜/奖励 | 调用 stats、leaderboards、rewards | 数据结构与数值合法 | P1 |

### 7.3 admin 核心业务

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| C1 | 获取 dashboard 统计 | `GET /admin/stats/dashboard` | 返回统计数据，字段完整 | P0 |
| C2 | 创建课程 | `POST /admin/courses` | 创建成功，列表可见 | P0 |
| C3 | 更新课程状态 | `PATCH /admin/courses/{id}` | draft → published → archived 状态合法流转 | P0 |
| C4 | 删除课程 | `DELETE /admin/courses/{id}` | 删除后回读不存在 | P1 |
| C5 | 创建挑战 | `POST /admin/challenges` | 创建成功 | P1 |
| C6 | 更新挑战 | `PATCH /admin/challenges/{id}` | 更新成功 | P1 |
| C7 | 用户列表与详情 | `GET /admin/users` / `{id}` | 返回结构满足前端依赖 | P0 |
| C8 | 用户封禁/解封 | `PATCH /admin/users/{id}/status` | 状态切换成功 | P0 |
| C9 | 审核单处理 | `PATCH /admin/moderation/{id}` | 审核状态更新成功 | P1 |
| C10 | 反馈处理 | `PATCH /admin/feedback/{id}` | 回复成功，状态变化正确 | P1 |
| C11 | 公告 CRUD | 对 announcements 进行增删改查 | 全流程成功 | P1 |
| C12 | 配置读取与更新 | `GET/PATCH /admin/configs` | 配置更新成功 | P1 |

---

## 8. Admin 联调测试用例

### 8.1 登录与鉴权

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| D1 | 管理员登录成功 | 在登录页提交正确账号密码 | token 被保存，进入受保护页面 | P0 |
| D2 | 未登录访问受保护页面 | 直接访问 `/dashboard` | 被重定向到 `/login` | P0 |
| D3 | token 过期处理 | 用失效 token 访问任意管理接口 | 清 token，跳回登录页 | P0 |
| D4 | 非 admin token 访问管理页 | 使用 learner token 请求 admin API | 前端显示无权限或禁止访问 | P1 |

### 8.2 页面与接口联动

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| E1 | 课程列表加载 | 打开课程管理页 | 列表正确展示 | P0 |
| E2 | 新建课程 | 创建课程后刷新列表 | 新课程出现在列表中 | P0 |
| E3 | 编辑课程 | 修改课程后重新查询 | 字段变化正确 | P0 |
| E4 | 删除课程 | 删除课程后回读列表 | 数据已移除 | P1 |
| E5 | 挑战管理 CRUD | 完成挑战创建、编辑、删除 | 全流程成功 | P1 |
| E6 | 用户搜索与状态更新 | 搜索用户并执行封禁/解封 | 列表与详情状态一致 | P0 |
| E7 | 审核流转 | 处理 moderation case | 状态更新正确 | P1 |
| E8 | 反馈回复 | 回复 feedback ticket | 状态与内容更新正确 | P1 |

### 8.3 Admin 已知风险项

以下项必须独立记录测试结果，不得并入“通过项”：

| 编号 | 风险项 | 当前关注点 | 处理要求 |
|------|--------|------------|----------|
| R-A1 | `/admin/stats/activities` | 前端存在调用定义，后端未确认完整支持 | 若不可用，记为联调缺口 |
| R-A2 | 系统配置保存 | 页面存在配置表单，但可能未真正接线 | 未实际发请求时不得记为通过 |
| R-A3 | 用户详情响应形状 | 前端详情页依赖字段可能与后端返回不一致 | 字段不匹配即判为联调失败 |

---

## 9. Mobile 联调测试用例

### 9.1 登录与基础读取

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| F1 | learner 注册成功 | 调用注册流程并进入首页 | token 保存成功，进入 `/home` | P0 |
| F2 | learner 登录成功 | 使用正确账号登录 | token 保存成功，首页可访问 | P0 |
| F3 | token 过期处理 | 用失效 token 拉取受保护接口 | 返回登录页或进入 authExpired 流程 | P0 |
| F4 | 基础 profile 获取 | 打开个人相关页面 | 资料加载成功 | P1 |

### 9.2 Dashboard 并发与部分失败

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| G1 | Dashboard 全量成功加载 | 首页触发并发请求 | 页面完整展示 | P0 |
| G2 | 单接口失败降级 | 人为使某个 learner 接口失败 | 页面进入 partialData 或局部降级，不整体崩溃 | P0 |
| G3 | 多接口超时 | 多个请求超时 | 页面出现明确错误/重试状态 | P1 |
| G4 | 响应缺失 `data` 字段 | 返回异常成功响应 | 前端不得静默误判成功 | P0 |

### 9.3 学习流程

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| H1 | 课程列表读取 | 打开课程列表页 | 列表正确展示 | P0 |
| H2 | 课程详情读取 | 打开课程详情页 | 章节、进度、文案正确 | P0 |
| H3 | 章节完成后本地进度变化 | 完成章节操作 | 本地进度立即更新 | P1 |
| H4 | 练习详情与提交 | 打开练习并提交 | 返回结果成功，页面状态正确 | P0 |
| H5 | 挑战尝试与结算 | 提交 challenge attempt | 返回星级/奖励，状态正确刷新 | P0 |
| H6 | 每日挑战获取与提交 | 获取 today challenge 并提交 | 状态成功变化 | P1 |

### 9.4 资料与社交

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| I1 | profile 编辑回写 | 修改资料后重新读取 | 变更成功持久化 | P1 |
| I2 | rewards / stats / leaderboards 读取 | 打开对应页面 | 数据展示正确 | P1 |
| I3 | 好友搜索与请求 | 搜索用户并发起好友请求 | 请求成功，反馈正确 | P2 |
| I4 | activities 加载 | 打开社交页 | 动态列表加载成功 | P2 |

### 9.5 离线与缓存专项

| 编号 | 用例名称 | 步骤 | 预期结果 | 优先级 |
|------|----------|------|----------|--------|
| J1 | 在线缓存后断网回读 | 在线读取课程/资料后断网再次进入页面 | 命中缓存并展示 partialData | P0 |
| J2 | 离线完成章节/挑战 | 断网状态下执行本地学习动作 | 本地状态正确变化 | P0 |
| J3 | 恢复网络后的同步行为 | 离线积压操作后恢复网络 | 不得仅因队列清空就判定同步成功 | P0 |
| J4 | 离线提示与重试 | 断网后观察 UI 提示与重试操作 | 横幅、状态页、重试逻辑正确 | P1 |

> 说明：如 `syncPendingActions()` 仅清理本地队列但未真正提交后端，则该能力应判定为“联调未完成”，不得记为通过。

---

## 10. 关键跨端烟雾测试

### 10.1 Admin 创建课程，Mobile 可见

步骤：

1. Admin 创建课程，状态为 `draft`
2. Mobile 课程列表确认不可见
3. Admin 将课程更新为 `published`
4. Mobile 再次拉取课程列表
5. Mobile 打开课程详情

预期结果：发布前不可见，发布后可见且详情可正常打开。

### 10.2 Admin 创建挑战，Mobile 可参与

步骤：

1. Admin 创建 challenge
2. Mobile challenge list 拉取最新数据
3. Mobile 发起 challenge attempt
4. 后端验证奖励与状态变更

预期结果：挑战可见、可参与、结果正确结算。

### 10.3 Mobile 产生学习行为，后端状态同步正确

步骤：

1. Mobile 完成练习或章节
2. 后端查询 progress / rewards / stats
3. 如管理后台存在对应观测项，则同步确认

预期结果：后端记录与客户端展示一致。

### 10.4 token 失效双端校验

步骤：

1. 构造失效 token
2. Admin 与 Mobile 分别访问受保护接口
3. 观察两端处理流程

预期结果：两端均进入正确的登录失效处理流程。

---

## 11. 执行顺序

### 第一阶段：契约与后端

1. 契约测试
2. 认证与权限测试
3. learner 核心 API
4. admin 核心 API

### 第二阶段：Admin 服务层联调

1. 登录与鉴权
2. 课程/挑战/用户/审核/反馈/公告/配置
3. 已知缺口单独记录

### 第三阶段：Mobile 服务层联调

1. 登录/注册
2. Dashboard 并发加载
3. 课程/练习/提交/挑战/每日挑战
4. 资料/社交/奖励/统计
5. 离线缓存专项

### 第四阶段：跨端烟雾测试

1. Admin 创建内容 → Mobile 消费
2. Learner 行为 → 后端状态变化
3. Token 失效双端校验

---

## 12. 通过标准与退出标准

### 12.1 通过标准

- OpenAPI 契约测试通过
- 后端核心接口测试通过
- Admin 与 Mobile 已接线能力联调通过
- 已知断点被明确记录并与“通过项”隔离

### 12.2 不得宣称通过的情况

- 页面存在 UI，但未真正发起请求
- 本地队列被清空，但没有真实落库或真实同步
- 后端接口通过，但客户端依赖的 envelope 或字段形状不匹配
- 401、403、404 等错误场景未验证

### 12.3 退出标准

本轮测试可结束的前提：

1. P0 用例全部执行完毕并完成结果记录。
2. P1 用例已覆盖核心业务链路。
3. 已知风险项均已单列记录。
4. 测试结论明确区分“已通过”“失败”“阻塞”“未接线”。

---

## 13. 当前已知高风险项

| 编号 | 风险描述 | 影响范围 | 建议测试结论方式 |
|------|----------|----------|------------------|
| K1 | Admin 可能存在 `/admin/stats/activities` 调用缺口 | 管理后台统计页扩展能力 | 记为联调缺口或阻塞 |
| K2 | Admin 系统配置保存可能未真实接线 | 管理后台配置能力 | 不得记为通过 |
| K3 | Mobile `syncPendingActions()` 可能只清队列不落后端 | 移动端离线同步 | 记为高风险未完成 |
| K4 | Mobile 对 `data` envelope 依赖强 | 所有 learner 接口 | 响应结构不符即判失败 |
| K5 | 后端已有测试不代表客户端可正确消费 | Admin + Mobile | 必须保留客户端服务层联调测试 |

---

## 14. 本轮优先执行的 8 个测试项

1. admin login / learner login / 权限隔离
2. admin 创建并发布课程 → mobile 课程列表可见
3. mobile dashboard 并发加载 + 单接口失败降级
4. mobile 提交练习 `/learner/submissions`
5. mobile challenge attempt
6. learner profile 修改与回读
7. admin 用户封禁/解封
8. mobile 离线进度队列恢复在线后的真实同步行为

---

## 15. 附录：测试结果记录建议字段

建议测试执行记录至少包含以下字段：

- 用例编号
- 用例名称
- 优先级
- 执行人
- 执行日期
- 环境信息
- 前置条件
- 实际结果
- 结论（通过 / 失败 / 阻塞 / 未执行）
- 缺陷编号
- 备注
