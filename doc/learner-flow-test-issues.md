# CodeQuest 学习者流程测试 — 问题报告

> 测试时间：2026-05-25  
> 测试范围：学习者端全部 7 个核心流程的端到端测试  
> 测试工具：Playwright CLI (Chromium 无头模式)  
> 前端：Flutter Web (CanvasKit 渲染器) @ localhost:8088  
> 后端：Rust + Salvo @ localhost:3001  
> 测试账号：flowtest@example.com / TestFlow123

---

## 🔴 严重问题（阻塞用户核心流程）

### 问题 1：章节页面加载失败 — `course-1` 硬编码 ID

**严重程度**：🔴 阻塞  
**影响流程**：流程 2（课程→章节学习）、流程 3（练习完成后返回章节）

**现象**：  
导航到任意章节页面（如 `/chapter/00000000-0000-0000-0000-000000000201`），页面显示：
> "出了点问题 — 加载章节失败，请重试。"

**根因**：  
浏览器控制台报错：
```
Failed to load resource: the server responded with a status of 400 (Bad Request)
@ http://localhost:3001/api/v1/learner/courses/course-1
```
前端章节页面向后端发起了 `/api/v1/learner/courses/course-1` 请求，`course-1` 是无效的 UUID 格式。后端参数校验返回 400。

**推测根因**：  
前端章节页（`chapter_view.dart`）中使用了硬编码字符串 `"course-1"` 或变量未正确赋值为课程 UUID。

**复现步骤**：
1. 登录系统
2. 通过 URL 直接访问 `/#/chapter/00000000-0000-0000-0000-000000000201`
3. 观察页面显示错误信息

**修复建议**：  
- 检查 `chapter_view.dart` 中课程 ID 的获取逻辑
- 从路由参数或状态管理（GetX Controller）中获取正确的课程 UUID
- 添加课程 ID 的 UUID 格式校验

---

### 问题 2：每日挑战无数据，点击无响应

**严重程度**：🔴 阻塞  
**影响流程**：流程 5（每日挑战）

**现象**：  
每日挑战页面（`/#/daily-challenge`）显示正常，但点击"开始每日挑战"按钮后页面无任何变化，状态始终为"未尝试"。

**API 返回**：
```json
{
  "data": {
    "daily_challenge": null,
    "learner_record": null
  }
}
```
`daily_challenge` 和 `learner_record` 均为 `null`。

**根因**：  
后端没有为今天（2026-05-25）创建每日挑战记录。数据库 `daily_challenges` 表中没有当天的数据。

**额外问题**：  
页面显示"时间限制：0 分钟"令人困惑——0 分钟意味着无限制还是未配置？

**复现步骤**：
1. 登录系统，进入每日挑战页
2. 点击"开始每日挑战"
3. 观察无任何变化

**修复建议**：
- 确保种子数据包含每日挑战，或实现自动创建逻辑
- 如果今日无挑战，前端应显示"今日暂无挑战"而非可点击按钮
- 时间限制为 0 时应显示"无时间限制"或隐藏该字段

---

### 问题 3：排行榜用户名全部显示为 "?"

**严重程度**：🔴 严重  
**影响流程**：流程 6（社交 → 排行榜）

**现象**：  
社交中心 → 排行榜 Tab 中，所有用户排名条目显示为：
```
? Level 1 4150 XP
? Level 1 3200 XP
? Level 1 2850 XP
...
```
用户名（昵称）字段统一显示为 `?`，而非实际用户昵称。

**根因**：  
排行榜 API 返回的数据中用户信息字段为空或前端适配代码与返回结构不匹配。可能是 API 返回的 `LearnerRankItem` 中 profile/account 字段未关联或前端渲染逻辑错误。

**复现步骤**：
1. 登录系统
2. 导航到社交中心 → 排行榜 Tab
3. 查看排行榜用户名列均显示为 "?"

**修复建议**：
- 检查 `/learner/leaderboards` API 返回的 `items[].nickname` 字段是否正确填充
- 检查前端 `LearnerRankItem` 模型和渲染逻辑
- 考虑关联 `learner_profiles.nickname` 到排行榜查询

---

### 问题 4：好友搜索 API 端点不存在 (404)

**严重程度**：🔴 严重  
**影响流程**：流程 6（社交 → 添加好友）

**现象**：  
在添加好友页面搜索"Bob"或"bob"时，始终显示"未找到用户"。

**API 情况**：  
前端发起 `/api/v1/learner/friends/search?q=Bob` 请求，后端返回 404 Not Found。

**OpenAPI 检查**：  
OpenAPI 规范中没有 `/learner/friends/search` 端点。现有端点仅包括：
- `GET /learner/friends` — 好友列表
- `POST /learner/friends/requests` — 发送好友申请
- `PATCH /learner/friends/requests/{request_id}` — 处理好友申请

**根因**：  
前端实现了一个后端尚未开发的搜索接口。或者前端应使用其他端点实现搜索（如通过用户列表 + 本地过滤）。

**复现步骤**：
1. 登录 → 社交中心 → 好友 Tab → 添加好友
2. 输入任何昵称搜索
3. 始终显示"未找到用户"

**修复建议**：
- 方案 A：后端新增 `GET /learner/users/search?q=` 接口
- 方案 B：前端修改逻辑，使用现有用户列表 + 客户端过滤
- 尽快同步 OpenAPI 规范和实际实现

---

## 🟡 中等问题（影响用户体验）

### 问题 5：课程列表显示不全（3/5 门）

**严重程度**：🟡 中等  
**影响流程**：流程 2（课程浏览）

**现象**：  
课程列表 Tab 只显示了 3 门课程：
1. HTML语义化
2. 响应式网页设计
3. CSS布局进阶

而数据库中实际有 5 门 `published` 状态的课程，缺失：
- HTML基础入门
- CSS样式基础

**根因**：  
可能是前端分页问题（默认 page_size 较小）或 API 过滤逻辑。`GET /learner/courses` 返回的 `items` 确实包含 5 门课程，但课程列表页中只渲染了 3 个按钮。

**复现步骤**：
1. 登录 → 课程 Tab
2. 观察只有 3 门课程
3. 与数据库查询对比：应有 5 门

**修复建议**：
- 检查课程列表页的分页/滚动加载逻辑
- 确认 page_size 默认值是否足够（当前可能为 3）
- 注意：课程列表页是扁平按钮列表，非滚动列表，需要检查布局

---

### 问题 6：AI 帮助返回原始 JSON，未格式化

**严重程度**：🟡 中等  
**影响流程**：流程 3（练习 → AI 帮助）

**现象**：  
AI 帮助弹窗中的"提示内容"区域显示的是原始 JSON 字符串，例如：
```json
{ "hint_level": 2, "summary": "提交的代码中包含了...", "root_cause": {...}, ... }
```
该 JSON 包含 `summary`、`root_cause.category`、`direction`、`suggestions[]` 等结构化字段，但前端未解析渲染，而是直接 `toString()` 输出。

**影响**：  
用户看到的是一大段无格式 JSON，难以阅读和理解。AI 帮助的核心价值被严重削弱。

**复现步骤**：
1. 进入任意练习页
2. 点击"AI 帮助"按钮
3. 查看弹窗内容为原始 JSON

**修复建议**：
- 前端解析 AI 帮助 API 返回的 JSON
- 按卡片/列表格式逐步展示：摘要 → 根因分析 → 方向建议 → 具体提示
- 考虑 Markdown 渲染

---

### 问题 7：CanvasKit 渲染器无障碍树初始为空

**严重程度**：🟡 中等  
**影响流程**：全部流程（无障碍访问）

**现象**：  
Flutter Web 使用 CanvasKit 渲染时：
- 页面加载后，`flt-semantics-host` 的 `innerHTML` 为 0，子元素为 0
- 只显示一个 `[role=button, aria-label="Enable accessibility"]` 占位按钮
- 点击该按钮后，语义树才开始填充内容（4083 字符的 DOM）

**影响**：
1. 屏幕阅读器用户无法使用（初始无任何可读内容）
2. 自动化测试工具（Playwright/Selenium）无法通过常规选择器定位元素
3. 用户需要在每个会话中手动点击"Enable accessibility"

**复现步骤**：
1. 打开 Flutter Web 应用
2. 查看无障碍树为空
3. 手动点击"Enable accessibility"后恢复正常

**修复建议**：
- 检查 Flutter 构建配置，确保无障碍在应用启动时自动启用
- 考虑使用 HTML 渲染器（`--web-renderer html`）以获得原生 DOM 可访问性
- 在 `index.html` 中配置自动启用无障碍

---

### 问题 8：挑战标签错误渲染为 checkbox

**严重程度**：🟡 中等  
**影响流程**：流程 4（关卡挑战）

**现象**：  
挑战详情页中，难度标签和 XP 标签被渲染为 checkbox：
```yaml
- checkbox "中级" [ref=e76]
- checkbox "100 XP" [ref=e77]
```
这些本应是只读标签（Tag/Chip 样式），不应有勾选交互。

**复现步骤**：
1. 进入任意挑战详情页
2. 观察"中级"和"100 XP"显示为复选框而非标签

**修复建议**：
- 检查 Flutter 中该组件的 `Semantics` 配置：如果是 `FilterChip` 或 `Chip`，应设置 `excludeSemantics: true` 或使用正确的语义角色
- 为标签使用 `Semantics(container: true, label: '中级')` 而非可交互语义

---

### 问题 9：新用户首页显示课程进度提示不当

**严重程度**：🟡 中等  
**影响流程**：流程 1（登录后首页）

**现象**：  
新注册用户（flowtest，学习进度为 0）首页显示：
> "继续学习 CSS布局进阶 Flexbox基础 课程进度 0%"

一个全新的用户看到"继续学习"文案显得不合适——用户从未开始学习该课程。

**复现步骤**：
1. 注册新用户并登录
2. 查看首页"继续学习"区域
3. 显示了一个从未开始过的课程，进度 0%

**修复建议**：
- 如果用户从未开始任何课程，应显示"开始你的第一门课程"引导卡片
- 仅对已有进度的课程显示"继续学习"
- 0% 进度的课程应显示"开始学习"而非"继续学习"

---

### 问题 10：练习页和章节页控制台持续报 400 错误

**严重程度**：🟡 中等  
**影响流程**：流程 2、流程 3

**现象**：  
练习页面和章节页面加载时，控制台持续出现：
```
ERROR: Failed to load resource: the server responded with a status of 400 (Bad Request)
@ http://localhost:3001/api/v1/learner/courses/course-1
```
该错误不阻止页面主要功能但存在副作用。

**根因**：  
同问题 1，`course-1` 硬编码 ID。页面可能在某处（详情获取、课程标题显示等）尝试获取课程信息。

**修复建议**：
- 修复问题 1 可一并解决
- 全局搜索代码中 `course-1` 字符串并替换

---

## 🔵 次要问题

### 问题 11：Firebase 未配置，应用降级运行

**严重程度**：🔵 次要  
**影响**：通知推送、Firebase Analytics 等功能不可用

**控制台日志**：
```
Firebase init failed, app continues in mock mode: Null check operator used on a null value
Firebase 初始化失败，通知服务降级运行
```
启动页 splash 过程中也一路抛出 Firebase 相关错误。应用以 mock 模式继续运行。

**修复建议**：
- 配置 Firebase 项目或在无 Firebase 时静默降级（不打印错误日志）
- 确保 `Null check operator used on a null value` 不会出现在生产环境

---

### 问题 12：WebGL GPU stall 警告

**严重程度**：🔵 次要  
**影响**：CanvasKit 渲染性能

**控制台日志**：
```
WebGL: CONTEXT_LOST_WEBGL: loseContext: context lost
[WebGL] GPU stall due to ReadPixels
```

**根因**：  
Chromium 无头模式下 WebGL 软件渲染性能不足。有头浏览器中此问题可能不存在。

**修复建议**：
- 考虑在无 WebGL 支持时自动降级到 HTML 渲染器
- 监测 WebGL context lost 事件并显示友好提示

---

### 问题 13：时间限制显示 "0 分钟"

**严重程度**：🔵 次要  
**影响流程**：流程 5（每日挑战）

**现象**：  
每日挑战页面显示"时间限制：0 分钟"。0 分钟可能意味着无限制，但文案让人困惑。

**修复建议**：
- 如果时间限制为 0，显示"无时间限制"或隐藏该字段

---

## 📊 问题统计

| 严重程度 | 数量 | 说明 |
|----------|------|------|
| 🔴 阻塞/严重 | 4 | 章节加载、每日挑战、排行榜、好友搜索 |
| 🟡 中等 | 6 | 课程列表、AI帮助格式、CanvasKit无障碍、标签渲染、首页文案、400错误 |
| 🔵 次要 | 3 | Firebase、WebGL、时间限制文案 |
| **合计** | **13** | |

---

## 📸 测试截图

| 页面 | 文件 |
|------|------|
| 引导页 | `/tmp/codequest-onboarding.png` |
| 登录页 | `/tmp/codequest-login.png` |
| 首页 | `/tmp/codequest-home.png` |
| 课程列表 | `/tmp/codequest-courses.png` |
| 课程详情 | `/tmp/codequest-course-detail.png` |
| 挑战地图 | `/tmp/codequest-challenges.png` |
| 每日挑战 | `/tmp/codequest-daily-challenge.png` |
| 社交中心 | `/tmp/codequest-social.png` |
| 个人中心 | `/tmp/codequest-profile.png` |
| 学习统计 | `/tmp/codequest-stats.png` |
| 奖励中心 | `/tmp/codequest-rewards.png` |
| 设置 | `/tmp/codequest-settings.png` |
| 练习页（含代码） | `/tmp/codequest-exercise.png` |

---

## 🔧 优先修复建议

1. **立即修复**：问题 1（章节页面 course-1 硬编码）+ 问题 10（连带错误）
2. **高优先级**：问题 4（好友搜索 API 缺失）→ 实现后端接口
3. **高优先级**：问题 3（排行榜用户名为 "?"）→ 修复数据关联
4. **高优先级**：问题 2（每日挑战无数据）→ 种子数据或自动创建
5. **中等优先级**：问题 6（AI 帮助 JSON 格式化）
6. **中等优先级**：问题 7（CanvasKit 无障碍自动启用）
7. **低优先级**：问题 5, 8, 9, 11, 12, 13
