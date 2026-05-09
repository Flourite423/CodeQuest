# Admin端页面设计方案

## TL;DR
> **Summary**: 基于Vue 3 + Element Plus + Pinia技术栈，对admin分支管理后台进行全面页面设计，包含中文界面、视觉重设计、交互优化和功能增强。严格对齐OpenAPI契约中的admin tags，重组为8个核心页面：登录、数据看板、课程管理、题目管理、挑战管理、用户管理、内容审核、公告与配置。
> **Deliverables**:
> - 全局布局与主题设计（侧边栏、顶部栏、面包屑）
> - 8个核心页面的完整Vue组件设计
> - 中文界面与术语统一
> - 状态机可视化与交互流程
> - 空数据、加载、错误等边界状态处理
> **Effort**: Medium-Large
> **Parallel**: YES - 3 waves
> **Critical Path**: 全局布局 → 登录页 → 数据看板 → 业务页面并行 → 联调整合

## Context
### Original Request
用户希望在admin分支单独开发admin端管理后台，要求中文界面，使用Element Plus组件库，进行全面页面设计。

### Interview Summary
- **设计范围**: 全面重新设计（视觉+交互+功能增强）
- **语言**: 全中文界面
- **主题**: 仅浅色模式，不需要深色模式
- **响应式**: 不需要，仅桌面端（1920x1080+）
- **页面架构**: 完全按契约重组，严格对齐admin tags
- **Leaderboard**: 移除，功能并入Dashboard
- **技术栈**: Vue 3 + Element Plus + Pinia + TypeScript + Vite（已有基础）

### Metis Review (gaps addressed)
- 已确认页面架构重组方案，对齐OpenAPI admin tags
- 已明确8个核心页面及其契约对应关系
- 已确定术语统一规范，避免混用
- 已规划状态矩阵（loading/success/empty/error/forbidden/session-expired）
- 已定义验收标准，全部可自动化验证

## Work Objectives
### Core Objective
产出可直接指导实现代理落地的admin端页面设计方案，实现者无需再做页面结构、组件选择、状态处理、中文文案等判断。

### Deliverables
- `admin/src/layouts/default.vue` - 全局布局重设计
- `admin/src/views/login/index.vue` - 登录页重设计
- `admin/src/views/dashboard/index.vue` - 数据看板重设计
- `admin/src/views/courses/index.vue` - 课程管理重设计
- `admin/src/views/practice/index.vue` - 题目管理（新增）
- `admin/src/views/challenges/index.vue` - 挑战管理重设计
- `admin/src/views/users/index.vue` - 用户管理重设计
- `admin/src/views/moderation/index.vue` - 内容审核重设计
- `admin/src/views/announcements/index.vue` - 公告与配置（新增）
- `admin/src/router/index.ts` - 路由更新
- `admin/src/styles/` - 主题与样式变量

### Definition of Done (verifiable conditions with commands)
- `npm --prefix admin run build` 成功退出，无TypeScript/Vue编译错误
- `grep -r "Dashboard\|Login\|Logout\|Courses\|Users" admin/src/views/ admin/src/layouts/ admin/src/router/` 无英文界面文本残留
- Playwright验证所有路由可访问且显示中文
- 每个页面包含loading、empty、error状态处理

### Must Have
- 全中文界面，包括菜单、按钮、标签、提示、空状态
- 严格对齐OpenAPI契约中的admin tags和字段定义
- 每个页面包含6类状态：loading、success、empty、error、forbidden、session-expired
- 状态机可视化（课程/挑战/公告的状态流转）
- 空数据、加载中、错误提示等边界状态处理
- 表单验证、操作确认、成功/失败反馈
- 面包屑导航、页面标题、操作按钮规范

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- 不得引入深色模式、响应式布局、国际化框架
- 不得引入额外UI库（如Ant Design、Vuetify）
- 不得发明契约外字段、筛选器、按钮权限
- 不得把Leaderboard作为独立页面保留
- 不得使用"页面美观""风格统一"等不可机检验收语句
- 不得只验收happy path，必须覆盖空数据、接口4xx/5xx、会话过期

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: tests-after + Playwright UI验证
- QA policy: 每个页面包含自动化验收场景
- Evidence: `.sisyphus/evidence/admin-design-task-{N}-{slug}.{ext}`

## Design System
### 主题色
- 主色: `#409EFF` (Element Plus默认蓝色)
- 成功: `#67C23A`
- 警告: `#E6A23C`
- 危险: `#F56C6C`
- 信息: `#909399`
- 背景: `#f0f2f5`
- 侧边栏: `#304156`
- 文字主色: `#303133`
- 文字次要: `#606266`
- 边框: `#DCDFE6`

### 布局规范
- 侧边栏宽度: 220px
- 顶部栏高度: 60px
- 内容区padding: 24px
- 卡片间距: 20px
- 表格行高: 48px
- 按钮尺寸: 默认small（表格内）/ default（页面操作）

### 术语统一
| 英文 | 中文 | 说明 |
|------|------|------|
| Dashboard | 数据看板 | 运营数据总览 |
| Course | 课程 | 学习单元 |
| Chapter | 章节 | 课程内单元 |
| Exercise | 题目 | 练习题/编码题 |
| Challenge | 挑战/关卡 | 闯关任务 |
| User | 用户 | 学习者账号 |
| Moderation | 内容审核 | 昵称/头像/反馈审核 |
| Announcement | 公告 | 运营公告 |
| Config | 系统配置 | 规则/参数配置 |
| Status | 状态 | 实体状态 |
| Action | 操作 | 按钮操作 |
| Search | 搜索 | 查询操作 |
| Filter | 筛选 | 条件过滤 |
| Export | 导出 | 数据导出 |

## Page Designs

### 1. 全局布局 (Global Layout)
**File**: `admin/src/layouts/default.vue`

**Structure**:
```
┌─────────────────────────────────────────┐
│  Logo          │  面包屑          用户下拉  │  ← Header (60px)
├────────────────┼──────────────────────────┤
│                │                          │
│  数据看板       │                          │
│  课程管理       │      页面内容区域          │
│  题目管理       │                          │
│  挑战管理       │                          │
│  用户管理       │                          │
│  内容审核       │                          │
│  公告与配置     │                          │
│                │                          │
└────────────────┴──────────────────────────┘
     Sidebar (220px)      Main Content
```

**Components**:
- `el-container` - 外层容器
- `el-aside` - 侧边栏
- `el-header` - 顶部栏
- `el-main` - 内容区
- `el-menu` - 侧边菜单
- `el-breadcrumb` - 面包屑
- `el-dropdown` - 用户下拉

**Menu Items** (中文):
1. 数据看板 (Odometer)
2. 课程管理 (Reading)
3. 题目管理 (EditPen)
4. 挑战管理 (Trophy)
5. 用户管理 (User)
6. 内容审核 (Warning)
7. 公告与配置 (Bell)

**States**:
- Loading: 菜单加载中显示骨架屏
- Collapsed: 侧边栏可折叠（保留功能，默认展开）
- Active: 当前路由高亮

---

### 2. 登录页 (Login)
**File**: `admin/src/views/login/index.vue`

**Layout**:
- 居中卡片，宽度400px
- 背景渐变或纯色（#f0f2f5）
- Logo + 系统名称 + 登录表单

**Form Fields**:
- 邮箱 (email): 输入框，必填，邮箱格式验证
- 密码 (password): 密码框，必填，最少6位
- 记住我 (remember): 复选框

**Buttons**:
- 登录: 主按钮，全宽，loading状态

**States**:
- Loading: 按钮显示loading，禁用输入
- Error: 邮箱或密码错误，显示"邮箱或密码错误"
- Success: 登录成功，跳转数据看板
- Validation: 表单校验失败，字段级错误提示

**Chinese Text**:
- 系统名称: "前端学习平台 - 管理后台"
- 标题: "管理员登录"
- 邮箱标签: "邮箱地址"
- 密码标签: "登录密码"
- 记住我: "记住登录状态"
- 登录按钮: "登录"
- 错误提示: "邮箱或密码错误，请重试"

---

### 3. 数据看板 (Dashboard)
**File**: `admin/src/views/dashboard/index.vue`
**Contract**: `admin-stats`

**Layout**:
- 顶部统计卡片行（4列）
- 中部图表区域（2列）
- 底部最近活动/待处理事项

**Statistics Cards**:
1. 总用户数 (User) - 蓝色
2. 总课程数 (Reading) - 绿色
3. 今日活跃 (View) - 橙色
4. 待审核数 (Warning) - 红色

**Charts** (使用Element Plus或简单CSS):
- 用户增长趋势（近7天）
- 课程完成率分布

**Recent Activities**:
- 最近用户注册
- 最近课程完成
- 最近审核申请

**States**:
- Loading: 卡片显示骨架屏，图表显示加载中
- Empty: 无数据时显示"暂无数据"提示
- Error: 数据加载失败，显示错误提示和重试按钮

**Chinese Text**:
- 页面标题: "数据看板"
- 统计卡片: "总用户数", "总课程数", "今日活跃", "待审核数"
- 图表标题: "用户增长趋势", "课程完成率"
- 活动标题: "最近动态"
- 空状态: "暂无数据"

---

### 4. 课程管理 (Courses)
**File**: `admin/src/views/courses/index.vue`
**Contract**: `admin-course`

**Layout**:
- 顶部操作栏：标题 + 搜索 + 新建按钮
- 中部表格：课程列表
- 底部分页

**Table Columns**:
| 列名 | 字段 | 说明 |
|------|------|------|
| 课程名称 | title | 课程标题 |
| 难度 | difficulty | beginner/intermediate |
| 状态 | status | draft/published/archived |
| 学员数 | students | 学习人数 |
| 创建时间 | created_at | 格式化显示 |
| 操作 | actions | 编辑/下架/删除 |

**Status Tags**:
- draft: 灰色标签 "草稿"
- published: 绿色标签 "已发布"
- archived: 橙色标签 "已归档"

**Actions**:
- 新建课程: 打开抽屉/对话框
- 编辑: 打开编辑抽屉
- 下架: 确认对话框，published→archived
- 删除: 确认对话框，仅草稿可删除

**Form Fields** (新建/编辑):
- 课程名称*: 输入框，1-100字符
- 课程简介: 文本域，0-300字符
- 详细描述: 富文本或文本域
- 难度*: 选择器（入门/进阶）
- 预计时长*: 数字输入框（分钟）
- 封面图: 上传组件
- 排序: 数字输入框

**States**:
- Loading: 表格显示骨架屏
- Empty: 无课程时显示"暂无课程，点击新建"
- Error: 加载失败，显示错误提示
- Forbidden: 无权限时显示"无权访问"

**State Machine Visualization**:
```
草稿 → [发布] → 已发布 → [归档] → 已归档
```
- 已归档不可恢复为已发布
- 已发布不可直接删除，需先归档

**Chinese Text**:
- 页面标题: "课程管理"
- 搜索占位: "搜索课程名称..."
- 新建按钮: "新建课程"
- 表格列: "课程名称", "难度", "状态", "学员数", "创建时间", "操作"
- 状态标签: "草稿", "已发布", "已归档"
- 操作按钮: "编辑", "下架", "删除"
- 确认对话框: "确定要下架该课程吗？", "确定要删除该课程吗？"
- 空状态: "暂无课程数据"

---

### 5. 题目管理 (Practice)
**File**: `admin/src/views/practice/index.vue` (新增)
**Contract**: `admin-practice`

**Layout**:
- 顶部操作栏：标题 + 搜索 + 筛选（类型/难度） + 新建按钮
- 中部表格：题目列表
- 底部分页

**Table Columns**:
| 列名 | 字段 | 说明 |
|------|------|------|
| 题目标题 | title | 题目名称 |
| 类型 | exercise_type | single_choice/coding |
| 难度 | difficulty | easy/medium/hard |
| 关联章节 | chapter_id | 所属章节 |
| 状态 | status | draft/published/archived |
| 操作 | actions | 编辑/预览/删除 |

**Status Tags**:
- draft: "草稿"
- published: "已发布"
- archived: "已归档"

**Actions**:
- 新建题目: 打开抽屉
- 编辑: 打开编辑抽屉
- 预览: 查看题目详情
- 删除: 确认对话框

**Form Fields**:
- 题目标题*: 输入框
- 题目说明*: 文本域
- 类型*: 选择器（单选题/编码题）
- 难度*: 选择器（简单/中等/困难）
- 关联章节: 选择器
- 初始代码: 代码编辑器（编码题）
- 选项配置: 动态表单（单选题）
- 测试用例: 动态表单（编码题）
- 通过阈值: 数字输入框

**States**:
- Loading, Empty, Error, Forbidden

**Chinese Text**:
- 页面标题: "题目管理"
- 搜索占位: "搜索题目标题..."
- 筛选: "题目类型", "难度"
- 新建按钮: "新建题目"
- 表格列: "题目标题", "类型", "难度", "关联章节", "状态", "操作"
- 类型标签: "单选题", "编码题"
- 难度标签: "简单", "中等", "困难"

---

### 6. 挑战管理 (Challenges)
**File**: `admin/src/views/challenges/index.vue`
**Contract**: `admin-challenge`

**Layout**:
- 顶部操作栏：标题 + 搜索 + 新建按钮
- 中部表格：挑战列表
- 底部分页

**Table Columns**:
| 列名 | 字段 | 说明 |
|------|------|------|
| 挑战名称 | title | 关卡名称 |
| 难度 | difficulty | easy/medium/hard |
| 奖励经验 | reward_xp | XP数值 |
| 关联课程 | related_course_id | 所属课程 |
| 状态 | status | draft/published/archived |
| 操作 | actions | 编辑/配置/删除 |

**Actions**:
- 新建挑战: 打开抽屉
- 编辑: 打开编辑抽屉
- 配置关卡: 配置子关卡和星级规则
- 删除: 确认对话框

**Form Fields**:
- 挑战名称*: 输入框
- 摘要: 文本域
- 关联课程: 选择器
- 难度*: 选择器
- 奖励经验*: 数字输入框
- 排序: 数字输入框

**States**:
- Loading, Empty, Error, Forbidden

**State Machine**:
```
草稿 → [发布] → 已发布 → [归档] → 已归档
```

**Chinese Text**:
- 页面标题: "挑战管理"
- 搜索占位: "搜索挑战名称..."
- 新建按钮: "新建挑战"
- 表格列: "挑战名称", "难度", "奖励经验", "关联课程", "状态", "操作"
- 操作按钮: "编辑", "配置关卡", "删除"

---

### 7. 用户管理 (Users)
**File**: `admin/src/views/users/index.vue`
**Contract**: `admin-user`

**Layout**:
- 顶部操作栏：标题 + 搜索 + 筛选（状态/角色） + 导出按钮
- 中部表格：用户列表
- 底部分页

**Table Columns**:
| 列名 | 字段 | 说明 |
|------|------|------|
| 用户ID | id | UUID缩写 |
| 昵称 | nickname | 显示名称 |
| 邮箱 | email | 登录邮箱 |
| 角色 | role | learner/admin |
| 账号状态 | account_status | active/suspended/closed |
| 注册时间 | created_at | 格式化 |
| 操作 | actions | 查看/禁用/启用 |

**Status Tags**:
- active: 绿色 "正常"
- suspended: 橙色 "已禁用"
- closed: 红色 "已关闭"

**Actions**:
- 查看详情: 打开用户详情抽屉
- 禁用: 确认对话框，active→suspended
- 启用: 确认对话框，suspended→active

**User Detail Drawer**:
- 基本信息：昵称、邮箱、角色、注册时间
- 学习进度：课程完成数、挑战完成数、经验值
- 账号状态：当前状态、操作记录

**States**:
- Loading, Empty, Error, Forbidden

**State Machine**:
```
正常 → [禁用] → 已禁用 → [启用] → 正常
正常 → [关闭] → 已关闭（不可逆）
```

**Chinese Text**:
- 页面标题: "用户管理"
- 搜索占位: "搜索昵称或邮箱..."
- 筛选: "账号状态", "用户角色"
- 导出按钮: "导出数据"
- 表格列: "用户ID", "昵称", "邮箱", "角色", "账号状态", "注册时间", "操作"
- 状态标签: "正常", "已禁用", "已关闭"
- 操作按钮: "查看", "禁用", "启用"
- 确认对话框: "确定要禁用该用户吗？", "确定要启用该用户吗？"

---

### 8. 内容审核 (Moderation)
**File**: `admin/src/views/moderation/index.vue`
**Contract**: `admin-moderation`

**Layout**:
- 顶部Tab切换：待处理 / 已处理
- 中部表格：审核列表
- 底部分页

**Table Columns** (待处理):
| 列名 | 字段 | 说明 |
|------|------|------|
| 审核类型 | case_type | nickname/avatar/feedback |
| 目标用户 | target_id | 关联用户 |
| 提交内容 | target_snapshot_json | 快照预览 |
| 提交时间 | created_at | 格式化 |
| 操作 | actions | 通过/拒绝 |

**Table Columns** (已处理):
| 列名 | 字段 | 说明 |
|------|------|------|
| 审核类型 | case_type | 类型 |
| 目标用户 | target_id | 关联用户 |
| 处理结果 | status | approved/rejected |
| 处理人 | reviewed_by | 管理员 |
| 处理时间 | reviewed_at | 格式化 |
| 原因 | decision_reason | 决策原因 |

**Actions**:
- 通过: 打开对话框，填写原因（可选），确认
- 拒绝: 打开对话框，填写原因（必填），确认

**States**:
- Loading, Empty, Error, Forbidden

**State Machine**:
```
待处理 → [通过] → 已通过
待处理 → [拒绝] → 已拒绝
```

**Chinese Text**:
- 页面标题: "内容审核"
- Tab: "待处理", "已处理"
- 表格列: "审核类型", "目标用户", "提交内容", "提交时间", "操作"
- 审核类型: "昵称审核", "头像审核", "反馈审核"
- 操作按钮: "通过", "拒绝"
- 对话框标题: "审核处理"
- 原因标签: "处理原因"
- 空状态: "暂无待处理审核"

---

### 9. 公告与配置 (Announcements & Config)
**File**: `admin/src/views/announcements/index.vue` (新增)
**Contract**: `admin-announcement`, `admin-config`

**Layout**:
- 顶部Tab切换：公告管理 / 系统配置
- 公告Tab：操作栏 + 表格 + 分页
- 配置Tab：表单列表

**Announcements Table Columns**:
| 列名 | 字段 | 说明 |
|------|------|------|
| 公告标题 | title | 标题 |
| 面向对象 | audience | all_learners/all_admins/all |
| 状态 | status | draft/published/expired |
| 发布时间 | published_at | 格式化 |
| 过期时间 | expires_at | 格式化 |
| 操作 | actions | 编辑/发布/删除 |

**Status Tags**:
- draft: "草稿"
- published: "已发布"
- expired: "已过期"

**Actions**:
- 新建公告: 打开抽屉
- 编辑: 打开编辑抽屉
- 发布: draft→published
- 删除: 确认对话框

**Announcement Form**:
- 标题*: 输入框
- 正文*: 富文本编辑器或文本域
- 面向对象*: 选择器
- 发布时间: 日期时间选择器
- 过期时间: 日期时间选择器

**Config Form**:
- AI配置：每日调用上限、提示规则
- 积分规则：经验值计算规则
- 徽章配置：徽章定义列表
- 系统参数：维护模式、注册开关

**States**:
- Loading, Empty, Error, Forbidden

**State Machine** (Announcement):
```
草稿 → [发布] → 已发布 → [过期] → 已过期
```

**Chinese Text**:
- 页面标题: "公告与配置"
- Tab: "公告管理", "系统配置"
- 搜索占位: "搜索公告标题..."
- 新建按钮: "新建公告"
- 表格列: "公告标题", "面向对象", "状态", "发布时间", "过期时间", "操作"
- 面向对象: "全部学员", "全部管理员", "全部用户"
- 状态标签: "草稿", "已发布", "已过期"
- 配置标签: "AI配置", "积分规则", "徽章配置", "系统参数"

## Execution Strategy
### Parallel Execution Waves

Wave 1: 全局基础
- 任务1: 全局布局重设计（侧边栏、顶部栏、面包屑、主题变量）
- 任务2: 登录页重设计
- 任务3: 路由更新与页面结构调整

Wave 2: 核心业务页面（可并行）
- 任务4: 数据看板重设计
- 任务5: 课程管理重设计
- 任务6: 题目管理页面（新增）
- 任务7: 挑战管理重设计

Wave 3: 运营与配置页面（可并行）
- 任务8: 用户管理重设计
- 任务9: 内容审核重设计
- 任务10: 公告与配置页面（新增）

Wave 4: 整合与验证
- 任务11: 全局样式统一与主题微调
- 任务12: 构建验证与Playwright UI测试

### Dependency Matrix
| Task | Depends On | Blocks |
|------|-----------|--------|
| 1 (布局) | - | 2,3,4,5,6,7,8,9,10 |
| 2 (登录) | - | 12 |
| 3 (路由) | 1 | 4,5,6,7,8,9,10 |
| 4 (看板) | 1,3 | 12 |
| 5 (课程) | 1,3 | 12 |
| 6 (题目) | 1,3 | 12 |
| 7 (挑战) | 1,3 | 12 |
| 8 (用户) | 1,3 | 12 |
| 9 (审核) | 1,3 | 12 |
| 10 (公告) | 1,3 | 12 |
| 11 (样式) | 4,5,6,7,8,9,10 | 12 |
| 12 (验证) | 2,4,5,6,7,8,9,10,11 | - |

## TODOs

### Task 1: 全局布局重设计
**What to do**: 重新设计admin/src/layouts/default.vue，包含中文侧边栏菜单、面包屑导航、用户下拉、主题色应用
**Must NOT do**: 不要引入深色模式、不要改变布局结构（保持侧边栏+顶部栏）

**Recommended Agent Profile**:
- Category: `visual-engineering` - Reason: 需要前端UI/UX设计能力
- Skills: [`frontend-design`] - 需要设计全局布局

**Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [3,4,5,6,7,8,9,10] | Blocked By: []

**Acceptance Criteria**:
- [x] 侧边栏显示7个中文菜单项
- [x] 顶部栏显示面包屑和用户下拉
- [x] 菜单激活态与当前路由一致
- [x] 无英文文本残留

**QA Scenarios**:
```
Scenario: 侧边栏菜单为中文
  Tool: Playwright
  Steps: 访问 /login，登录后访问 /
  Expected: 侧边栏显示"数据看板", "课程管理"等中文菜单
  Evidence: .sisyphus/evidence/admin-design-task-1-sidebar.png

Scenario: 面包屑导航正确
  Tool: Playwright
  Steps: 访问 /courses
  Expected: 面包屑显示"首页 / 课程管理"
  Evidence: .sisyphus/evidence/admin-design-task-1-breadcrumb.png
```

### Task 2: 登录页重设计
**What to do**: 重新设计admin/src/views/login/index.vue，中文界面，表单验证，错误提示
**Must NOT do**: 不要改变登录逻辑，仅做UI和文案更新

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [12] | Blocked By: []

**Acceptance Criteria**:
- [x] 页面标题为"管理员登录"
- [x] 表单标签为中文
- [x] 错误提示为中文
- [x] 表单验证正常工作

**QA Scenarios**:
```
Scenario: 登录页中文显示
  Tool: Playwright
  Steps: 访问 /login
  Expected: 页面显示"前端学习平台 - 管理后台"和"管理员登录"
  Evidence: .sisyphus/evidence/admin-design-task-2-login.png

Scenario: 表单验证中文提示
  Tool: Playwright
  Steps: 访问 /login，点击登录按钮
  Expected: 显示"请输入邮箱地址"和"请输入登录密码"
  Evidence: .sisyphus/evidence/admin-design-task-2-validation.png
```

### Task 3: 路由更新
**What to do**: 更新admin/src/router/index.ts，调整页面结构，添加新路由，更新meta信息
**Must NOT do**: 不要改变路由守卫逻辑

**Recommended Agent Profile**:
- Category: `quick`
- Skills: []

**Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [4,5,6,7,8,9,10] | Blocked By: [1]

**Acceptance Criteria**:
- [x] 路由包含8个核心页面
- [x] 路由meta包含中文标题
- [x] 移除Leaderboard路由
- [x] 添加Practice和Announcements路由

**QA Scenarios**:
```
Scenario: 路由配置正确
  Tool: Bash
  Steps: grep -n "path:" admin/src/router/index.ts
  Expected: 包含/courses, /practice, /challenges, /users, /moderation, /announcements
  Evidence: .sisyphus/evidence/admin-design-task-3-routes.txt
```

### Task 4: 数据看板重设计
**What to do**: 重新设计admin/src/views/dashboard/index.vue，中文界面，统计卡片，图表，最近活动
**Must NOT do**: 不要引入复杂图表库，使用Element Plus组件或简单CSS

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 统计卡片显示中文标题和数值
- [x] 包含loading和empty状态
- [x] 最近活动列表为中文

**QA Scenarios**:
```
Scenario: 看板中文显示
  Tool: Playwright
  Steps: 访问 /dashboard
  Expected: 显示"数据看板"标题和"总用户数"等中文卡片
  Evidence: .sisyphus/evidence/admin-design-task-4-dashboard.png
```

### Task 5: 课程管理重设计
**What to do**: 重新设计admin/src/views/courses/index.vue，中文界面，表格，状态标签，操作按钮，表单抽屉
**Must NOT do**: 不要发明契约外字段

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 表格列名为中文
- [x] 状态标签为中文（草稿/已发布/已归档）
- [x] 包含新建/编辑抽屉
- [x] 包含操作确认对话框

**QA Scenarios**:
```
Scenario: 课程列表中文显示
  Tool: Playwright
  Steps: 访问 /courses
  Expected: 表格显示"课程名称", "难度", "状态"等中文列名
  Evidence: .sisyphus/evidence/admin-design-task-5-courses.png
```

### Task 6: 题目管理页面（新增）
**What to do**: 新建admin/src/views/practice/index.vue，包含列表、筛选、新建/编辑表单
**Must NOT do**: 不要引入代码编辑器组件，使用文本域替代

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 页面包含题目列表表格
- [x] 包含类型和难度筛选
- [x] 包含新建/编辑抽屉
- [x] 表单包含题目类型切换

**QA Scenarios**:
```
Scenario: 题目管理页面存在
  Tool: Playwright
  Steps: 访问 /practice
  Expected: 页面显示"题目管理"标题和题目列表
  Evidence: .sisyphus/evidence/admin-design-task-6-practice.png
```

### Task 7: 挑战管理重设计
**What to do**: 重新设计admin/src/views/challenges/index.vue，中文界面，表格，状态标签，操作按钮
**Must NOT do**: 不要改变现有数据结构

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 表格列名为中文
- [x] 状态标签为中文
- [x] 包含操作按钮

**QA Scenarios**:
```
Scenario: 挑战列表中文显示
  Tool: Playwright
  Steps: 访问 /challenges
  Expected: 表格显示"挑战名称", "难度", "奖励经验"等中文列名
  Evidence: .sisyphus/evidence/admin-design-task-7-challenges.png
```

### Task 8: 用户管理重设计
**What to do**: 重新设计admin/src/views/users/index.vue，中文界面，表格，筛选，用户详情抽屉
**Must NOT do**: 不要引入复杂搜索功能

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 3 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 表格列名为中文
- [x] 状态标签为中文（正常/已禁用/已关闭）
- [x] 包含用户详情抽屉
- [x] 包含禁用/启用操作

**QA Scenarios**:
```
Scenario: 用户列表中文显示
  Tool: Playwright
  Steps: 访问 /users
  Expected: 表格显示"昵称", "邮箱", "账号状态"等中文列名
  Evidence: .sisyphus/evidence/admin-design-task-8-users.png
```

### Task 9: 内容审核重设计
**What to do**: 重新设计admin/src/views/moderation/index.vue，中文界面，Tab切换，审核操作
**Must NOT do**: 不要改变审核状态机

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 3 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 包含待处理/已处理Tab
- [x] 审核类型为中文
- [x] 包含通过/拒绝操作
- [x] 包含原因输入对话框

**QA Scenarios**:
```
Scenario: 审核页面中文显示
  Tool: Playwright
  Steps: 访问 /moderation
  Expected: 显示"内容审核"标题和"待处理""已处理"Tab
  Evidence: .sisyphus/evidence/admin-design-task-9-moderation.png
```

### Task 10: 公告与配置页面（新增）
**What to do**: 新建admin/src/views/announcements/index.vue，包含公告管理和系统配置两个Tab
**Must NOT do**: 不要引入富文本编辑器，使用文本域

**Recommended Agent Profile**:
- Category: `visual-engineering`
- Skills: [`frontend-design`]

**Parallelization**: Can Parallel: YES | Wave 3 | Blocks: [12] | Blocked By: [1,3]

**Acceptance Criteria**:
- [x] 包含公告管理和系统配置Tab
- [x] 公告表格列名为中文
- [x] 配置表单标签为中文
- [x] 状态标签为中文

**QA Scenarios**:
```
Scenario: 公告与配置页面存在
  Tool: Playwright
  Steps: 访问 /announcements
  Expected: 页面显示"公告与配置"标题和Tab切换
  Evidence: .sisyphus/evidence/admin-design-task-10-announcements.png
```

### Task 11: 全局样式统一
**What to do**: 创建admin/src/styles/目录，包含主题变量、全局样式、工具类
**Must NOT do**: 不要覆盖Element Plus默认样式文件

**Recommended Agent Profile**:
- Category: `quick`
- Skills: []

**Parallelization**: Can Parallel: NO | Wave 4 | Blocks: [12] | Blocked By: [4,5,6,7,8,9,10]

**Acceptance Criteria**:
- [x] 创建variables.scss包含主题变量
- [x] 创建global.scss包含全局样式
- [x] 在main.ts中引入

**QA Scenarios**:
```
Scenario: 样式文件存在
  Tool: Bash
  Steps: ls admin/src/styles/
  Expected: 包含variables.scss和global.scss
  Evidence: .sisyphus/evidence/admin-design-task-11-styles.txt
```

### Task 12: 构建验证与UI测试
**What to do**: 运行npm run build验证无编译错误，使用Playwright验证所有页面可访问且显示中文
**Must NOT do**: 不要修改测试基础设施

**Recommended Agent Profile**:
- Category: `unspecified-high`
- Skills: [`playwright`]

**Parallelization**: Can Parallel: NO | Wave 4 | Blocks: [] | Blocked By: [2,4,5,6,7,8,9,10,11]

**Acceptance Criteria**:
- [x] npm run build成功
- [x] 所有页面可访问
- [x] 所有页面显示中文
- [x] 无英文文本残留

**QA Scenarios**:
```
Scenario: 构建成功
  Tool: Bash
  Steps: cd admin && npm run build
  Expected: 退出码0，无错误
  Evidence: .sisyphus/evidence/admin-design-task-12-build.txt

Scenario: 所有页面中文验证
  Tool: Playwright
  Steps: 遍历所有路由，检查页面文本
  Expected: 无"Dashboard", "Login", "Courses"等英文文本
  Evidence: .sisyphus/evidence/admin-design-task-12-i18n.txt
```

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- 按页面拆分提交：
  - `design(admin): redesign global layout with Chinese UI`
  - `design(admin): redesign login page with Chinese UI`
  - `design(admin): update routes and add new pages`
  - `design(admin): redesign dashboard with Chinese UI`
  - `design(admin): redesign courses management page`
  - `feat(admin): add practice management page`
  - `design(admin): redesign challenges management page`
  - `design(admin): redesign users management page`
  - `design(admin): redesign moderation page`
  - `feat(admin): add announcements and config page`
  - `style(admin): add global theme variables and styles`
  - `test(admin): verify build and Chinese UI`

## Success Criteria
- 所有页面显示中文，无英文文本残留
- 构建成功，无编译错误
- 所有页面包含loading、empty、error状态处理
- 页面布局统一，风格一致
- 严格对齐OpenAPI契约中的admin tags和字段定义
- 状态机可视化清晰，操作反馈明确
