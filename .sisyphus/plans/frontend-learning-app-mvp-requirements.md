# Frontend Beginner Mobile Learning App MVP Requirements Document Plan

## TL;DR
> **Summary**: 生成一份面向全新项目的正式需求分析文档，覆盖学习者端移动 APP 与统一 Web 管理后台的 MVP 核心需求，并明确 AI、社交、闯关、课程与后台能力的边界。
> **Deliverables**:
> - `.sisyphus/drafts/frontend-learning-app-requirements-doc.md` 需求分析文档初稿
> - 角色权限矩阵
> - MVP / 非 MVP 边界表
> - 核心业务流程与异常场景清单
> **Effort**: Medium
> **Parallel**: YES - 3 waves
> **Critical Path**: 1 → 2/3/4 → 5/6/7/8 → 9

## Context
### Original Request
用户给出一个“面向前端初学者的移动学习 APP”粗略描述，希望将其细化。核心能力包括 HTML/CSS/JavaScript 学习、每日挑战、答题闯关、实践编码任务、AI 辅助（实时代码检查、个性化推荐、智能提示）以及社交互动与组队挑战。

### Interview Summary
- 输出形式固定为：**需求分析文档版**。
- 当前范围固定为：**先只做产品与功能需求**，不展开文献综述、行业现状、环保与可持续发展论文内容。
- 参考策略固定为：**按全新项目撰写**，不以任何既有实现为基线。
- 角色范围更新为：**学习者端移动 APP + 统一管理后台**。
- 复杂度固定为：**MVP 核心版**，以毕业设计可实现为上限。
- 平台形态更新为：**学习者端仅移动 APP；管理端为 Web**。
- 后台角色更新为：**统一后台角色**，不拆分教师端、运营端、管理员三套独立系统。

### Metis Review (gaps addressed)
- 后台角色已收敛为统一后台，计划中保留权限边界说明，但不再扩展为多后台系统。
- AI、社交、团队挑战是三大高风险膨胀点，计划中强制拆分为“必须有 / 可延后 / 明确不做”。
- 需求文档不得滑向论文、竞品分析或工业级全平台方案，计划中加入明确“禁止产出”与“非 MVP 清单”。
- 文档验收不得使用“看起来完整”这类人工判断，计划中所有验收项都改为可检索的章节覆盖、矩阵覆盖和边缘场景覆盖。

## Work Objectives
### Core Objective
产出一份正式、可执行、边界清晰的需求分析文档，供后续设计与开发阶段直接使用；文档必须完整定义学习者端移动 APP 与统一 Web 管理后台的产品目标、用户角色、模块结构、功能需求、非功能需求、MVP 边界、非 MVP 清单与异常场景。

### Deliverables
- 一份结构完整的需求分析文档，文件路径固定为：`.sisyphus/drafts/frontend-learning-app-requirements-doc.md`
- 一份角色权限矩阵（嵌入需求文档）
- 一份 MVP / 非 MVP 边界表（嵌入需求文档）
- 一份核心业务流程与异常场景清单（嵌入需求文档）

### Definition of Done (verifiable conditions with commands)
- `test -f .sisyphus/drafts/frontend-learning-app-requirements-doc.md`
- `grep -n "^# " .sisyphus/drafts/frontend-learning-app-requirements-doc.md`
- `grep -n "^## " .sisyphus/drafts/frontend-learning-app-requirements-doc.md`
- `grep -n "学习者端\|管理端\|管理后台" .sisyphus/drafts/frontend-learning-app-requirements-doc.md`
- `grep -n "MVP\|非MVP\|角色权限矩阵\|异常场景\|AI能力边界\|社交边界\|后台功能" .sisyphus/drafts/frontend-learning-app-requirements-doc.md`

### Must Have
- 学习者端限定为**移动端 APP**
- 管理端限定为**Web 管理后台**
- 同时覆盖**学习者端**与**统一管理后台**
- 所有需求按 **MVP 核心版**裁剪
- 清晰定义课程、闯关、每日挑战、代码练习、AI 提示、社交协作之间的关系
- 明确学习者端与后台端职责边界
- 明确 AI、社交、团队挑战的最小可行范围
- 明确异常场景与业务规则

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- 不得写成论文文献综述
- 不得写竞品分析基线
- 不得默认依赖既有项目实现
- 不得扩展到 Web/H5/小程序/PC 学员端
- 不得加入支付、直播、招聘、完整社区、实时协作编辑等非 MVP 能力
- 不得重新拆分出教师端、运营端、管理员三套独立系统

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: none + 文档覆盖校验（grep/read）
- QA policy: Every task has agent-executed scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: 1 文档骨架；2 产品目标与用户场景；3 两端角色边界与权限矩阵；4 学习内容与任务模型

Wave 2: 5 学习者端功能需求；6 Web 管理后台功能需求；7 AI 能力边界；8 社交协作与异常场景

Wave 3: 9 非功能需求、MVP/非MVP、验收标准与全文整合

### Dependency Matrix (full, all tasks)
| Task | Depends On | Blocks |
|---|---|---|
| 1 | None | 2,3,4,5,6,7,8,9 |
| 2 | 1 | 5,9 |
| 3 | 1 | 6,9 |
| 4 | 1 | 5,7,8,9 |
| 5 | 1,2,4 | 9 |
| 6 | 1,3,4 | 9 |
| 7 | 1,4 | 9 |
| 8 | 1,3,4 | 9 |
| 9 | 2,3,4,5,6,7,8 | F1-F4 |

### Agent Dispatch Summary (wave → task count → categories)
| Wave | Task Count | Categories |
|---|---:|---|
| Wave 1 | 4 | writing, unspecified-low |
| Wave 2 | 4 | writing, deep |
| Wave 3 | 1 | writing |

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. 建立需求文档骨架与固定章节

  **What to do**: 在 `.sisyphus/drafts/frontend-learning-app-requirements-doc.md` 创建正式需求分析文档骨架，章节必须至少包含：项目概述、建设目标、目标用户、使用场景、系统范围、角色定义、角色权限矩阵、信息架构、学习内容结构、学习者端功能需求、管理后台功能需求、AI 能力边界、社交功能边界、非功能需求、MVP 范围、非 MVP 范围、异常场景、验收标准。
  **Must NOT do**: 不得写论文综述；不得加入技术选型实现细节；不得预设不存在的既有系统。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 这是结构化需求文档骨架搭建任务。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['frontend-design']` - 当前不是界面设计任务。

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [2,3,4,5,6,7,8,9] | Blocked By: []

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:3` - 已确认范围、边界、平台与交付形式。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:32` - 工作目标与必备章节方向。

  **Acceptance Criteria** (agent-executable only):
  - [ ] `.sisyphus/drafts/frontend-learning-app-requirements-doc.md` 已创建。
  - [ ] `grep -n "^## " .sisyphus/drafts/frontend-learning-app-requirements-doc.md` 可检索出所有预定二级章节。
  - [ ] 文档中出现“学习者端”“管理后台”“MVP”“非MVP”“异常场景”“角色权限矩阵”章节标题。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 文档骨架完整生成
    Tool: Bash
    Steps: 运行 `test -f .sisyphus/drafts/frontend-learning-app-requirements-doc.md && grep -n "^## " .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-1-doc-skeleton.txt`
    Expected: 文件存在，且 evidence 中包含预期章节标题列表
    Evidence: .sisyphus/evidence/task-1-doc-skeleton.txt

  Scenario: 禁止章节未被误加入
    Tool: Bash
    Steps: 运行 `! grep -n "文献综述\|竞品分析\|技术实现细节" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-1-doc-skeleton-error.txt`
    Expected: 未检索到禁用内容
    Evidence: .sisyphus/evidence/task-1-doc-skeleton-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): add requirements skeleton` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 2. 定义产品目标、目标用户与核心使用场景

  **What to do**: 在需求文档中写清产品定位、目标问题、目标用户画像、使用场景与核心价值闭环；重点说明为什么前端初学者需要“学—练—闯关—反馈—激励”的产品机制。
  **Must NOT do**: 不得写市场调研史；不得扩展到企业培训、招聘平台、直播课堂等非本题范围。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要清晰定义产品语义与用户场景。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['docx']` - 当前不是 Word 成品导出。

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5,9] | Blocked By: [1]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:4` - 原始需求范围与功能方向。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:14` - 原始请求摘要。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档中存在“产品目标”“目标用户”“使用场景”三级内容。
  - [ ] 至少定义 3 类目标用户特征与 4 个核心使用场景。
  - [ ] 场景描述明确出现“学习”“练习”“闯关”“反馈/奖励”闭环。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 用户与场景章节完整
    Tool: Bash
    Steps: 运行 `grep -n "产品目标\|目标用户\|使用场景\|学习\|练习\|闯关\|奖励" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-2-user-scenarios.txt`
    Expected: evidence 中可检索到相关章节与关键词
    Evidence: .sisyphus/evidence/task-2-user-scenarios.txt

  Scenario: 非目标领域未混入
    Tool: Bash
    Steps: 运行 `! grep -n "招聘\|企业内训\|直播课堂\|支付订阅" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-2-user-scenarios-error.txt`
    Expected: 未出现非目标领域描述
    Evidence: .sisyphus/evidence/task-2-user-scenarios-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define goals and scenarios` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 3. 定义学习者端与统一管理后台的角色边界及权限矩阵

  **What to do**: 明确仅有两端：学习者端（移动 APP）与统一管理后台（Web）；写出各自目标、可执行操作、不可执行操作，并给出权限矩阵，说明后台统一承担课程、题目、用户、挑战、内容与统计管理职责。
  **Must NOT do**: 不得拆出教师端、运营端、管理员三套独立系统；不得把后台权限写成无限制超级系统而没有边界。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要高精度边界定义。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['drawio']` - 当前不要求绘图。

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [6,8,9] | Blocked By: [1]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:15` - 已确认统一后台角色与平台边界。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:49` - Must Have 中的两端要求。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档明确写出学习者端与管理后台两类角色。
  - [ ] 角色权限矩阵至少包含“课程内容、题目任务、用户数据、挑战配置、数据统计、系统配置”6 类对象。
  - [ ] 文档明确写出后台不等于独立教师/运营/管理员三系统。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 角色边界与权限矩阵存在
    Tool: Bash
    Steps: 运行 `grep -n "学习者端\|管理后台\|角色权限矩阵\|课程内容\|题目任务\|用户数据\|挑战配置\|数据统计\|系统配置" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-3-role-matrix.txt`
    Expected: evidence 中出现两端定义及矩阵关键项
    Evidence: .sisyphus/evidence/task-3-role-matrix.txt

  Scenario: 多后台角色未被重新引入
    Tool: Bash
    Steps: 运行 `! grep -n "教师端\|运营端\|管理员端（独立）" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-3-role-matrix-error.txt`
    Expected: 未出现重新拆分后台系统的描述
    Evidence: .sisyphus/evidence/task-3-role-matrix-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define role boundaries` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 4. 定义学习内容结构、任务模型与闯关关系

  **What to do**: 说明 HTML、CSS、JavaScript 三大内容域如何组织成课程单元、章节、练习、测验、每日挑战与闯关任务，并写出它们之间的前后置关系、解锁条件与最小评分/完成规则。
  **Must NOT do**: 不得直接设计过多具体题库内容；不得把课程体系扩展到 React/Vue 等进阶主题。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要将教学内容与游戏机制建模。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['frontend-design']` - 当前不是页面设计。

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5,7,8,9] | Blocked By: [1]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:4` - 核心知识域与任务方向。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:53` - 需定义课程、闯关、每日挑战、代码练习、AI、社交关系。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档中存在“学习内容结构”与“任务模型”章节。
  - [ ] 明确写出课程单元、章节、练习、测验、每日挑战、闯关任务 6 类对象。
  - [ ] 每类对象均包含输入、输出或触发条件说明。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 内容与任务模型完整
    Tool: Bash
    Steps: 运行 `grep -n "学习内容结构\|任务模型\|课程单元\|章节\|练习\|测验\|每日挑战\|闯关任务\|解锁条件" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-4-content-model.txt`
    Expected: evidence 中出现完整对象与规则术语
    Evidence: .sisyphus/evidence/task-4-content-model.txt

  Scenario: 进阶框架未混入 MVP
    Tool: Bash
    Steps: 运行 `! grep -n "React课程\|Vue课程\|工程化进阶" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-4-content-model-error.txt`
    Expected: 未出现超出 MVP 的课程范围
    Evidence: .sisyphus/evidence/task-4-content-model-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define content and task model` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 5. 细化学习者端移动 APP 功能需求

  **What to do**: 按模块细化学习者端功能需求，至少覆盖账户与档案、课程学习、代码练习、测验闯关、每日挑战、奖励成长、AI 提示、好友互动/组队、学习进度与个人中心；每个模块都写明功能说明、输入输出、业务规则、优先级与最小异常处理。
  **Must NOT do**: 不得加入直播、商城、证书、支付、论坛、实时多人协作编辑等非 MVP 能力；不得把 AI 写成必须全程自动代答。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 这是主体需求章节编写任务。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['playwright']` - 当前不是浏览器交互任务。

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [9] | Blocked By: [1,2,4]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:4` - 用户原始功能诉求。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:49` - Must Have 中的核心能力。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 学习者端章节至少包含 8 个子模块。
  - [ ] 每个子模块均含“功能说明、业务规则、优先级、异常处理”四类信息。
  - [ ] 至少覆盖 AI 提示、每日挑战、闯关奖励、好友协作四项核心能力。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 学习者端功能模块覆盖完整
    Tool: Bash
    Steps: 运行 `grep -n "账户\|课程学习\|代码练习\|测验闯关\|每日挑战\|奖励成长\|AI 提示\|好友互动\|组队\|个人中心\|业务规则\|优先级\|异常处理" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-5-learner-features.txt`
    Expected: evidence 中出现所有核心模块与规则字段
    Evidence: .sisyphus/evidence/task-5-learner-features.txt

  Scenario: 非MVP能力未混入学习者端
    Tool: Bash
    Steps: 运行 `! grep -n "支付\|直播\|证书商城\|论坛\|实时协作编辑" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-5-learner-features-error.txt`
    Expected: 未出现明确排除项
    Evidence: .sisyphus/evidence/task-5-learner-features-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define learner app requirements` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 6. 细化统一 Web 管理后台功能需求

  **What to do**: 细化统一管理后台的功能范围，至少覆盖课程/章节管理、题目与挑战管理、用户与学习记录管理、内容审核、公告/运营配置、数据统计看板、系统基础配置；写明后台仅为管理用途，不承担学员学习主流程。
  **Must NOT do**: 不得拆分成教师后台、运营后台、管理员后台三个独立端；不得把后台写成需要移动端适配的产品主体。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要定义后台 MVP 能力边界。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['frontend-design']` - 当前不是后台 UI 设计。

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [9] | Blocked By: [1,3,4]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:15` - 后台端形态与统一角色已锁定。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:50` - 管理端限定为 Web 管理后台。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 管理后台章节至少包含 6 个子模块。
  - [ ] 文档明确说明后台为 Web，且不承担学员学习主流程。
  - [ ] 文档明确说明后台为统一角色，不拆分多套系统。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 管理后台功能覆盖完整
    Tool: Bash
    Steps: 运行 `grep -n "管理后台\|课程管理\|题目管理\|挑战管理\|用户管理\|学习记录\|内容审核\|公告\|数据统计\|系统配置\|Web" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-6-admin-features.txt`
    Expected: evidence 中出现后台所有核心管理模块
    Evidence: .sisyphus/evidence/task-6-admin-features.txt

  Scenario: 多后台或移动后台未被引入
    Tool: Bash
    Steps: 运行 `! grep -n "教师后台\|运营后台\|管理员后台\|移动后台" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-6-admin-features-error.txt`
    Expected: 未出现被排除的后台形态
    Evidence: .sisyphus/evidence/task-6-admin-features-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define admin requirements` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 7. 定义 AI 能力边界与降级方案

  **What to do**: 将 AI 能力限定在 MVP 可控范围内，至少区分：实时代码检查、错误解释、智能提示、个性化任务推荐；同时写出无大模型时的降级方案（规则校验/模板提示/基于学习记录的推荐）与有模型时的增强方案。
  **Must NOT do**: 不得把 AI 写成必须具备开放式对话教学、全自动代码生成、完整个性化教学代理；不得假设无限制大模型调用。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要对高风险创新能力做边界压缩。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['oracle']` - 当前只需文档边界，不做架构推演。

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [9] | Blocked By: [1,4]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:6` - 用户明确提出的 AI 诉求。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:28` - Metis 已指出 AI 是高风险膨胀点。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档中有“AI能力边界”章节。
  - [ ] 明确列出 4 类 MVP AI 能力及其输入输出。
  - [ ] 同时存在“无模型降级方案”与“有模型增强方案”两部分。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: AI能力边界完整
    Tool: Bash
    Steps: 运行 `grep -n "AI能力边界\|实时代码检查\|错误解释\|智能提示\|个性化任务推荐\|降级方案\|增强方案" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-7-ai-boundary.txt`
    Expected: evidence 中出现 AI MVP 能力及两类方案
    Evidence: .sisyphus/evidence/task-7-ai-boundary.txt

  Scenario: 过度智能体能力未被写入 MVP
    Tool: Bash
    Steps: 运行 `! grep -n "全自动写代码\|开放式万能导师\|无限上下文对话代理" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-7-ai-boundary-error.txt`
    Expected: 未出现超出 MVP 的 AI 描述
    Evidence: .sisyphus/evidence/task-7-ai-boundary-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define ai boundaries` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 8. 定义社交协作边界与异常场景清单

  **What to do**: 将社交能力压缩为 MVP 最小闭环，明确好友、组队挑战、成果分享、排行榜的边界；同时列出至少 6 类异常场景，覆盖账号、任务提交、挑战结算、组队协作、内容审核、权限控制。
  **Must NOT do**: 不得扩展为论坛、私聊、群聊、动态社区、复杂UGC平台；不得遗漏作弊、断网、重复提交、跨天挑战结算等异常处理。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 需要同时定义边界和风控/异常场景。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['playwright']` - 当前不是执行交互验证。

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: [9] | Blocked By: [1,3,4]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:7` - 原始社交互动与组队挑战诉求。
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:28` - 社交与团队挑战是高风险膨胀点。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档中明确列出好友、组队挑战、成果分享、排行榜四类社交能力。
  - [ ] 文档中明确说明论坛/私聊/群聊/复杂社区不在 MVP。
  - [ ] 异常场景至少覆盖 6 类，并写出预期系统处理方式。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 社交与异常场景覆盖完整
    Tool: Bash
    Steps: 运行 `grep -n "好友\|组队挑战\|成果分享\|排行榜\|异常场景\|断网\|重复提交\|作弊\|跨天\|内容审核\|权限控制" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-8-social-edgecases.txt`
    Expected: evidence 中出现社交边界与异常场景关键词
    Evidence: .sisyphus/evidence/task-8-social-edgecases.txt

  Scenario: 社区化功能未越界
    Tool: Bash
    Steps: 运行 `! grep -n "论坛\|私聊\|群聊\|动态广场\|开放社区" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-8-social-edgecases-error.txt`
    Expected: 未出现超出 MVP 的社区能力
    Evidence: .sisyphus/evidence/task-8-social-edgecases-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): define social boundaries and edge cases` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

- [x] 9. 整合非功能需求、MVP/非MVP边界与文档验收标准

  **What to do**: 收束全文，补齐非功能需求（易用性、性能、安全性、可扩展性、可维护性）、MVP 范围、非 MVP 范围、交付边界与最终验收标准；确保所有章节术语一致、边界一致，不再出现未确认角色或平台。
  **Must NOT do**: 不得新引入技术实现路线、数据库细节、部署架构；不得回滚到“全角色全移动端”旧范围。

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: 这是最终整编与一致性收束任务。
  - Skills: `[]` - 无需额外技能。
  - Omitted: `['docx']` - 当前不是成品导出格式转换。

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [F1,F2,F3,F4] | Blocked By: [2,3,4,5,6,7,8]

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `.sisyphus/plans/frontend-learning-app-mvp-requirements.md:42` - 文档完成定义与验证命令。
  - Pattern: `.sisyphus/drafts/frontend-learning-app-refinement.md:15` - 最终范围边界已确定。

  **Acceptance Criteria** (agent-executable only):
  - [ ] 文档中存在“非功能需求”“MVP范围”“非MVP范围”“验收标准”章节。
  - [ ] 文档全文仅出现“学习者端移动APP”和“Web管理后台”两端定义。
  - [ ] 文档中不存在教师端/运营端/全移动后台等过期范围。

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: 收尾章节完整且范围一致
    Tool: Bash
    Steps: 运行 `grep -n "非功能需求\|MVP范围\|非MVP范围\|验收标准\|学习者端移动APP\|Web管理后台" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-9-finalize.txt`
    Expected: evidence 中出现所有收尾章节与最终端定义
    Evidence: .sisyphus/evidence/task-9-finalize.txt

  Scenario: 过期范围已清除
    Tool: Bash
    Steps: 运行 `! grep -n "教师端\|运营端\|全移动端后台\|H5学员端\|小程序端" .sisyphus/drafts/frontend-learning-app-requirements-doc.md > .sisyphus/evidence/task-9-finalize-error.txt`
    Expected: 未出现旧范围或越界端形态
    Evidence: .sisyphus/evidence/task-9-finalize-error.txt
  ```

  **Commit**: NO | Message: `docs(requirements): finalize MVP requirements` | Files: [.sisyphus/drafts/frontend-learning-app-requirements-doc.md]

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle
- [x] F2. Code Quality Review — unspecified-high
- [x] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [x] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit: NO
- Rationale: 当前阶段只产出规划/需求文档，不进行代码实现或仓库提交。

## Success Criteria
- 需求分析文档存在且章节完整
- 学习者端与管理后台全部覆盖，并有清晰边界
- 学习路径、闯关、AI、社交、后台管理流程均有明确业务规则
- 明确列出 MVP 与非 MVP，且无范围漂移
- 至少六类异常场景被写入并可检索
