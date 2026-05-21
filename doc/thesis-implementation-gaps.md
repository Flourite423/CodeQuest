# 论文与实现差异清单及补充计划

**生成日期：** 2026-05-14
**分析范围：** 论文 `thesis/` 与实际代码 `backend/`、`mobile/`、`admin/`、`contracts/`

---

## 一、功能缺失清单

### 1. AI 辅助功能（重大缺失）

**论文描述：**
- 接入 DeepSeek API（deepseek-chat 模型）
- 三级智能提示策略：错误定位 → 修正方向 → 操作建议
- 采样温度 0.3，限制最大输出令牌数
- 根据练习信息、提交代码、错误上下文生成分层提示
- 客户端兜底逻辑：当 AI 服务不可用时生成本地安全提示

**当前实现：**
- 使用 mock provider，返回固定响应文本
- 无实际 API 调用逻辑
- 无分级提示策略
- 无客户端兜底逻辑

**影响范围：**
- `backend/src/handlers/ai_help.rs` - 需要重写
- `backend/src/config.rs` - AI 配置需要扩展
- `mobile/lib/views/exercise/widgets/ai_help_sheet.dart` - 可能需要调整

---

### 2. 代码编辑器增强（部分缺失）

**论文描述：**
- CSS 颜色高亮的基础语法标记
- WebView 加载 HTML/CSS 代码实现实时渲染预览

**当前实现：**
- 基础 TextField 编辑功能已实现
- 符号快捷输入面板已实现
- 无语法高亮
- 无 WebView 实时预览

**影响范围：**
- `mobile/lib/views/exercise/exercise_view.dart` - 需要添加语法高亮和预览功能
- 可能需要引入新的 Flutter 包（如 `flutter_highlight`、`webview_flutter`）

---

### 3. 推送通知功能（已实现，论文未提及）

**论文描述：**
- 未提及推送通知功能

**当前实现：**
- Firebase Cloud Messaging 集成
- 本地通知支持
- 权限管理和 Token 刷新

**建议：**
- 此功能已实现，无需补充
- 可考虑在论文中补充说明（如需修改论文）

---

## 二、补充优先级计划

### 优先级评估维度

| 维度 | 权重 | 说明 |
|------|------|------|
| **重要性** | 40% | 对核心学习闭环的影响程度 |
| **论文一致性** | 30% | 与论文描述的匹配程度 |
| **实现难度** | 20% | 开发工作量和技术复杂度 |
| **依赖关系** | 10% | 是否阻塞其他功能 |

---

### P0 - 高优先级（必须补充）

#### 任务 1：接入 DeepSeek API 实现 AI 辅助功能

**优先级评分：** ⭐⭐⭐⭐⭐（5/5）

| 维度 | 评分 | 说明 |
|------|------|------|
| 重要性 | 5/5 | AI 辅助是论文核心创新点之一 |
| 论文一致性 | 5/5 | 论文详细描述了三级提示策略 |
| 实现难度 | 3/5 | 中等难度，需要 API 集成和提示工程 |
| 依赖关系 | 4/5 | 影响练习模块的完整性 |

**实现步骤：**

1. **后端 - 配置扩展**（预计 0.5 天）
   - 扩展 `AiConfig` 结构体，添加 DeepSeek API 配置
   - 添加 `api_key`、`model`、`temperature`、`max_tokens` 字段
   - 更新 `config/default.toml` 和环境变量

2. **后端 - AI 服务层**（预计 1 天）
   - 创建 `backend/src/services/ai_service.rs`
   - 实现 DeepSeek API 调用逻辑
   - 实现三级提示策略的 Prompt 构建
   - 实现错误处理和重试机制

3. **后端 - Handler 重构**（预计 0.5 天）
   - 重构 `ai_help.rs`，调用真实的 AI 服务
   - 实现根据练习信息、代码、错误上下文生成提示
   - 实现请求类型分级（error_location、correction_hint、operation_suggestion）

4. **移动端 - 兜底逻辑**（预计 0.5 天）
   - 在 `ai_help_sheet.dart` 中添加客户端兜底提示
   - 当服务端 AI 服务不可用时，根据测试用例结果生成本地提示

5. **测试验证**（预计 0.5 天）
   - 测试三级提示是否正确返回
   - 测试错误场景下的降级处理
   - 测试 API 限流和超时处理

**技术参考：**
- DeepSeek API 文档：https://platform.deepseek.com/api-docs
- 论文附录 A 中的 Prompt 设计

---

### P1 - 中优先级（建议补充）

#### 任务 2：代码编辑器语法高亮

**优先级评分：** ⭐⭐⭐⭐（4/5）

| 维度 | 评分 | 说明 |
|------|------|------|
| 重要性 | 4/5 | 提升代码编辑体验 |
| 论文一致性 | 4/5 | 论文明确提及语法高亮 |
| 实现难度 | 3/5 | 中等，需要引入语法高亮库 |
| 依赖关系 | 2/5 | 独立功能，不阻塞其他模块 |

**实现步骤：**

1. **引入依赖**（预计 0.5 天）
   - 添加 `flutter_highlight` 或 `highlight` 包
   - 添加 HTML/CSS 语法定义文件

2. **实现语法高亮编辑器**（预计 1 天）
   - 创建自定义编辑器组件
   - 实现 HTML 标签高亮（蓝色）
   - 实现 CSS 属性高亮（绿色）
   - 实现字符串和注释高亮（灰色）

3. **集成到练习页面**（预计 0.5 天）
   - 替换现有 TextField 为高亮编辑器
   - 保持符号快捷输入面板功能
   - 测试不同屏幕尺寸的适配

**技术参考：**
- `flutter_highlight` 包：https://pub.dev/packages/flutter_highlight
- 支持 HTML/CSS 语法的 highlight.js 定义

---

### P2 - 低优先级（可选补充）

#### 任务 3：WebView 实时预览

**优先级评分：** ⭐⭐⭐（3/5）

| 维度 | 评分 | 说明 |
|------|------|------|
| 重要性 | 3/5 | 增强学习体验，但非核心功能 |
| 论文一致性 | 3/5 | 论文提及但非重点 |
| 实现难度 | 4/5 | 较高，涉及 WebView 集成和安全问题 |
| 依赖关系 | 2/5 | 独立功能 |

**实现步骤：**

1. **引入依赖**（预计 0.5 天）
   - 添加 `webview_flutter` 包
   - 配置 iOS/Android 平台权限

2. **实现预览组件**（预计 1.5 天）
   - 创建 HTML/CSS 预览 WebView 组件
   - 实现代码到 HTML 的转换逻辑
   - 实现实时渲染（防抖处理）
   - 处理安全问题（沙箱隔离）

3. **集成到练习页面**（预计 1 天）
   - 添加预览标签页
   - 实现代码编辑与预览的联动
   - 处理内存管理和生命周期

**技术参考：**
- `webview_flutter` 包：https://pub.dev/packages/webview_flutter
- 需要考虑的内容安全策略（CSP）

---

## 三、实施时间线

### 阶段 1：核心功能补充（第 1-2 周）

| 任务 | 优先级 | 预计工时 | 依赖 |
|------|--------|----------|------|
| 接入 DeepSeek API | P0 | 3 天 | 无 |
| AI 辅助测试验证 | P0 | 0.5 天 | DeepSeek API |

**里程碑：** AI 辅助功能完整实现，与论文描述一致

---

### 阶段 2：体验优化（第 3 周）

| 任务 | 优先级 | 预计工时 | 依赖 |
|------|--------|----------|------|
| 代码编辑器语法高亮 | P1 | 2 天 | 无 |

**里程碑：** 代码编辑体验提升，支持 HTML/CSS 语法高亮

---

### 阶段 3：可选增强（第 4 周，如时间允许）

| 任务 | 优先级 | 预计工时 | 依赖 |
|------|--------|----------|------|
| WebView 实时预览 | P2 | 3 天 | 语法高亮 |

**里程碑：** 代码编辑器功能完整，支持实时预览

---

## 四、风险评估

### 高风险项

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| DeepSeek API 访问受限 | AI 功能无法实现 | 准备备选 API（如 OpenAI） |
| API 调用成本超预算 | 持续运营困难 | 实现请求缓存和限流 |
| WebView 内存泄漏 | 移动端性能下降 | 严格管理 WebView 生命周期 |

### 中风险项

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 语法高亮库兼容性 | 编辑器功能异常 | 选择成熟稳定的库 |
| 提示工程效果不佳 | AI 帮助质量低 | 迭代优化 Prompt |

---

## 五、验收标准

### P0 任务验收

- [ ] DeepSeek API 成功调用，返回有效响应
- [ ] 三级提示策略正确实现（error_location、correction_hint、operation_suggestion）
- [ ] 错误场景下正确降级（API 超时、限流、服务不可用）
- [ ] 客户端兜底逻辑正常工作
- [ ] 帮助请求正确存储到数据库

### P1 任务验收

- [ ] HTML 标签正确高亮显示
- [ ] CSS 属性正确高亮显示
- [ ] 编辑器性能流畅，无明显卡顿
- [ ] 符号快捷输入面板功能正常

### P2 任务验收

- [ ] WebView 正确加载和渲染 HTML/CSS
- [ ] 代码编辑后预览实时更新
- [ ] 内存占用在合理范围内
- [ ] 无安全漏洞（XSS 等）

---

## 六、附录

### A. 相关文件清单

**AI 辅助功能相关：**
- `backend/src/handlers/ai_help.rs`
- `backend/src/config.rs`
- `backend/src/services/` (新建 ai_service.rs)
- `mobile/lib/views/exercise/widgets/ai_help_sheet.dart`
- `contracts/openapi/openapi.yaml`

**代码编辑器相关：**
- `mobile/lib/views/exercise/exercise_view.dart`
- `mobile/lib/views/exercise/widgets/` (新建编辑器组件)
- `mobile/pubspec.yaml`

### B. 论文参考章节

- 第 2.4 节：系统实现技术与选型权衡（代码编辑器方案）
- 第 3.3 节：功能需求分析（AI 辅助功能）
- 第 5.3 节：移动客户端模块实现（AI 辅助模块）
- 附录 A：AI 三级智能提示详细设计

### C. 配置示例

**DeepSeek API 配置（config/default.toml）：**
```toml
[ai]
provider = "deepseek"
api_key = "${APP__AI_API_KEY}"
model = "deepseek-chat"
temperature = 0.3
max_tokens = 500
mock_response = "这是一条模拟的 AI 帮助响应。"
```

**环境变量：**
```bash
APP__AI_PROVIDER=deepseek
APP__AI_API_KEY=your-deepseek-api-key
APP__AI_MODEL=deepseek-chat
APP__AI_TEMPERATURE=0.3
APP__AI_MAX_TOKENS=500
```
