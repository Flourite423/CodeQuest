# CodeQuest 多代理并行开发计划

**制定日期：** 2026-05-21  
**目标：** 利用多子代理 + git worktree 加速完成剩余开发任务  
**预计总工期：** 3-4 天（并行后压缩至 1-2 天）

---

## 一、项目现状速览

| 端 | 进度 | 核心缺口 |
|---|---|---|
| **Backend** | ~75% | AI Help exercise_prompt 硬编码、无代码判题、XP 未自动计算 |
| **Admin** | ~75% | 缺反馈管理页、系统配置静态未对接、所有列表无分页 |
| **Mobile** | ~85-90% | 语法高亮基础实现待增强、WebView 预览待完善、AI 兜底逻辑待补 |

**好消息：** AI Service (`backend/src/services/ai_service.rs`) 已完整实现 DeepSeek API 调用 + 三级提示策略；Mobile 语法高亮和 WebView 已有基础文件。

---

## 二、任务清单与依赖关系

### 任务总览图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Wave 1: 完全并行（无依赖）                            │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────────────────┤
│  A1         │  A2         │  A3         │  A4         │  A5 / A6            │
│  Backend    │  Backend    │  Admin      │  Admin      │  Mobile             │
│  AI Help    │  代码判题   │  反馈管理页 │  系统配置   │  语法高亮+WebView   │
│  Handler    │  系统       │             │  对接       │                     │
│  完善       │             │             │             │                     │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────────────┘
       │             │             │             │             │
       ▼             ▼             ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Wave 2: 依赖 Wave 1 Backend AI                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  B1: Mobile AI 帮助兜底逻辑（需要 Backend AI 接口返回稳定 JSON 结构）         │
└─────────────────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Wave 3: 独立优化（可部分并行）                        │
├─────────────┬─────────────┬─────────────────────────────────────────────────┤
│  C1         │  C2         │  C3                                             │
│  Admin      │  Backend    │  Backend                                        │
│  列表分页   │  XP/等级    │  排行榜                                         │
│  (所有页)   │  自动计算   │  实时更新                                       │
└─────────────┴─────────────┴─────────────────────────────────────────────────┘
```

### 详细任务说明

#### Wave 1 — 完全并行（6 个任务可同时启动）

| 任务 | 子项目 | 说明 | 预计工时 | 修改文件 |
|------|--------|------|----------|----------|
| **A1** | Backend | AI Help Handler 完善：从数据库获取真实练习数据替换硬编码 `exercise_prompt`；完善 `request_type` 三级映射；记录真实 `token_usage` 和 `latency_ms` | 0.5-1 天 | `handlers/ai_help.rs`, `services/ai_service.rs` |
| **A2** | Backend | 代码判题系统：创建 `services/judge_service.rs`，实现提交后异步判题逻辑（HTML/CSS 用例匹配），更新 `handlers/submission.rs` 创建提交时触发判题 | 1-1.5 天 | `services/judge_service.rs`(新), `handlers/submission.rs`, `models.rs` |
| **A3** | Admin | 反馈管理页面：创建 `views/feedback/index.vue`，对接 `feedbackApi.list()` 和 `feedbackApi.reply()`，参考其他管理页面风格 | 0.5 天 | `views/feedback/index.vue`(新), `router/index.ts` |
| **A4** | Admin | 系统配置对接：将 `announcements/index.vue` 中"系统配置"Tab 的静态表单改为调用 `configApi.list()` 和 `configApi.update()` | 0.5 天 | `views/announcements/index.vue` |
| **A5** | Mobile | 语法高亮增强：增强 `widgets/syntax_highlighter.dart`，添加 CSS 属性高亮（绿色）、行号显示、注释高亮 | 0.5-1 天 | `widgets/syntax_highlighter.dart` |
| **A6** | Mobile | WebView 预览增强：增强 `widgets/code_preview_webview.dart`，支持同时渲染 HTML+CSS、添加 CSP 安全头、处理加载错误 | 0.5-1 天 | `widgets/code_preview_webview.dart` |

#### Wave 2 — 依赖 Wave 1 完成

| 任务 | 子项目 | 说明 | 预计工时 | 修改文件 |
|------|--------|------|----------|----------|
| **B1** | Mobile | AI 帮助兜底逻辑：在 `ai_help_sheet.dart` 中添加客户端降级逻辑，当服务端 AI 不可用或超时时，根据测试用例结果生成本地安全提示 | 0.5 天 | `views/exercise/widgets/ai_help_sheet.dart` |

#### Wave 3 — 独立优化（可与 Wave 2 部分并行）

| 任务 | 子项目 | 说明 | 预计工时 | 修改文件 |
|------|--------|------|----------|----------|
| **C1** | Admin | 所有列表页分页：为 courses/practice/challenges/users/moderation/announcements/feedback 添加分页组件，对接 `PaginationMeta` | 1 天 | 所有列表视图 + `types/index.ts` |
| **C2** | Backend | XP/等级自动计算：提交通过后自动计算 XP、更新等级、发放徽章，创建 `services/xp_service.rs` | 1 天 | `services/xp_service.rs`(新), `handlers/submission.rs` |
| **C3** | Backend | 排行榜实时更新：提交/挑战完成后刷新排行榜快照，或改为实时查询 | 0.5 天 | `handlers/leaderboard.rs`, `models.rs` |

---

## 三、子代理分配与 Worktree 策略

### 3.1 Worktree 隔离方案

由于 Backend、Admin、Mobile 是不同子目录，大部分任务天然不会文件冲突。使用 `worktree: true` 为每个子代理创建独立工作区，确保：
- 各代理互不干扰
- 可独立编译/测试
- 失败不互相影响
- 完成后合并回主分支

### 3.2 代理分组

```
Wave 1（同时启动 6 个代理）
┌────────────────────────────────────────────────────────────┐
│ 代理-1 (Backend-AI)     │ worktree: wt-ai-help              │
│ 任务: A1                │ 修改: backend/src/handlers/       │
│                         │       backend/src/services/       │
├────────────────────────────────────────────────────────────┤
│ 代理-2 (Backend-Judge)  │ worktree: wt-judge                │
│ 任务: A2                │ 修改: backend/src/services/       │
│                         │       backend/src/handlers/       │
├────────────────────────────────────────────────────────────┤
│ 代理-3 (Admin-Page)     │ worktree: wt-admin-pages          │
│ 任务: A3 + A4           │ 修改: admin/src/views/            │
│                         │       admin/src/router/           │
├────────────────────────────────────────────────────────────┤
│ 代理-4 (Mobile-Editor)  │ worktree: wt-mobile-editor        │
│ 任务: A5 + A6           │ 修改: mobile/lib/widgets/         │
│                         │       mobile/lib/views/exercise/  │
└────────────────────────────────────────────────────────────┘

Wave 2（Wave 1 完成后启动 1 个代理）
┌────────────────────────────────────────────────────────────┐
│ 代理-5 (Mobile-AI)      │ worktree: wt-mobile-ai            │
│ 任务: B1                │ 修改: mobile/lib/views/exercise/  │
└────────────────────────────────────────────────────────────┘

Wave 3（可与 Wave 2 并行启动 3 个代理）
┌────────────────────────────────────────────────────────────┐
│ 代理-6 (Admin-UX)       │ worktree: wt-admin-ux             │
│ 任务: C1                │ 修改: admin/src/views/*/          │
├────────────────────────────────────────────────────────────┤
│ 代理-7 (Backend-Reward) │ worktree: wt-backend-reward       │
│ 任务: C2 + C3           │ 修改: backend/src/services/       │
│                         │       backend/src/handlers/       │
└────────────────────────────────────────────────────────────┘
```

### 3.3 冲突预防

| 潜在冲突 | 预防措施 |
|---------|---------|
| A1 和 A2 都改 `backend/src/services/mod.rs` | 两个代理各自在 worktree 中修改，主分支合并时由人工解决 |
| A3 和 C1 都改 Admin 视图 | 分波次执行：A3 在 Wave 1，C1 在 Wave 3 |
| A5/A6 和 B1 都改 exercise 相关文件 | A5/A6 改 `widgets/`，B1 改 `views/exercise/widgets/`，目录不同 |

---

## 四、执行命令参考

### Wave 1 并行启动（4 组代理）

```bash
# 注意：执行前需确保 git 状态 clean，或先提交当前修改
cd /home/ltc/CodeQuest

# 组 1: Backend AI Help 完善
pi subagent --agent delegate --task "完善 Backend AI Help Handler" \
  --worktree --task-file PLAN_A1.md

# 组 2: Backend 代码判题系统
pi subagent --agent delegate --task "实现 Backend 代码判题系统" \
  --worktree --task-file PLAN_A2.md

# 组 3: Admin 反馈页 + 配置对接
pi subagent --agent delegate --task "Admin 反馈管理页和系统配置对接" \
  --worktree --task-file PLAN_A3A4.md

# 组 4: Mobile 语法高亮 + WebView
pi subagent --agent delegate --task "Mobile 语法高亮和 WebView 预览增强" \
  --worktree --task-file PLAN_A5A6.md
```

### Wave 2 启动

```bash
# Mobile AI 兜底逻辑（需 Wave 1 的 Backend AI 返回稳定）
pi subagent --agent delegate --task "Mobile AI 帮助兜底逻辑" \
  --worktree --task-file PLAN_B1.md
```

### Wave 3 并行启动

```bash
# Admin 分页
pi subagent --agent delegate --task "Admin 所有列表页添加分页" \
  --worktree --task-file PLAN_C1.md

# Backend XP/等级 + 排行榜
pi subagent --agent delegate --task "Backend XP等级自动计算和排行榜更新" \
  --worktree --task-file PLAN_C2C3.md
```

---

## 五、验收标准

### A1: Backend AI Help 完善
- [ ] `exercise_prompt` 从数据库 `exercises` 表获取真实题目数据
- [ ] `request_type` 正确映射三级提示：`error_location` → `correction_hint` → `operation_suggestion`
- [ ] 真实记录 `token_usage`（从 DeepSeek 响应解析 `usage.total_tokens`）
- [ ] 真实记录 `latency_ms`（请求前后计时）
- [ ] Mock 模式仍可用（无 API Key 时自动降级）

### A2: 代码判题系统
- [ ] 创建 `services/judge_service.rs`
- [ ] 支持 HTML/CSS 练习的可见/隐藏测试用例匹配
- [ ] 提交创建后自动触发判题（`judge_status` 从 `pending` → `passed`/`failed`）
- [ ] 判题结果正确写入 `score`, `passed_case_count`, `total_case_count`, `error_summary`

### A3: Admin 反馈管理页
- [ ] 新建 `/feedback` 路由和页面
- [ ] 列表展示反馈内容、状态、提交者
- [ ] 支持回复反馈（调用 `feedbackApi.reply`）
- [ ] 状态筛选（待处理/已处理）

### A4: Admin 系统配置对接
- [ ] 系统配置 Tab 加载时调用 `configApi.list()`
- [ ] 保存时调用 `configApi.update()`
- [ ] 保存成功/失败有 `ElMessage` 提示

### A5: Mobile 语法高亮增强
- [ ] HTML 标签高亮（蓝色，已有）
- [ ] CSS 属性高亮（绿色）
- [ ] 字符串高亮（已有绿色，保持不变）
- [ ] 注释高亮（灰色）
- [ ] 行号显示
- [ ] 与现有符号快捷输入面板兼容

### A6: Mobile WebView 预览增强
- [ ] 支持同时传入 HTML 和 CSS 代码
- [ ] 正确渲染组合后的页面
- [ ] 添加基础 CSP 防止 XSS
- [ ] 加载错误状态处理
- [ ] 与练习页面集成（编辑区旁边显示预览）

### B1: Mobile AI 兜底逻辑
- [ ] 服务端返回 5xx 或超时时，客户端生成基于测试用例的本地提示
- [ ] 兜底提示分三级（与 Backend 对应）
- [ ] UI 正常展示，用户感知不到降级

### C1: Admin 列表分页
- [ ] 所有列表页（课程/题目/挑战/用户/审核/公告/反馈）支持分页
- [ ] 分页参数正确传递给后端 API
- [ ] 页码切换正常

### C2: Backend XP/等级自动计算
- [ ] 提交通过后自动增加 XP
- [ ] 达到升级阈值时自动提升等级
- [ ] 首次获得条件时自动发放徽章
- [ ] 更新 `learner_progress` 和 `xp_ledgers`

### C3: Backend 排行榜实时更新
- [ ] 提交/挑战完成后排行榜数据刷新
- [ ] 好友排行榜正确过滤好友关系
- [ ] 课程排行榜正确按课程过滤

---

## 六、风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| DeepSeek API 不可用 | A1 阻塞 | Mock 模式作为兜底，确保功能可用 |
| 判题系统复杂度高 | A2 延期 | 先实现最简版本（字符串匹配），后续迭代 |
| Worktree 合并冲突 | 代码合并困难 | 每个 worktree 独立分支，合并时人工 review |
| Git 状态不 clean | Worktree 无法创建 | 执行前先 `git stash` 或 `git commit` 当前修改 |
| 子代理代码质量不一致 | 引入 Bug | 每个 wave 结束后由 reviewer 代理统一 review |

---

## 七、建议执行顺序

```
Day 1 (Wave 1):
  上午: 提交当前 git 修改 → 启动 4 组并行代理 (A1, A2, A3+A4, A5+A6)
  下午: 监控各代理进度，处理阻塞问题
  傍晚: 合并 Wave 1 成果，运行测试

Day 2 (Wave 2 + Wave 3):
  上午: 启动 B1 (Mobile AI 兜底) + C1 (Admin 分页) + C2+C3 (Backend 奖励)
  下午: 监控进度，合并成果
  傍晚: 全端联调测试

Day 3:
  全天: 修复联调 Bug、补充测试、论文差异复查
```

**通过并行，预计将原本 8-10 天的串行工作压缩至 2-3 天完成。**
