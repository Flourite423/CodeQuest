# 共享组件系统实现记录

## 完成内容

创建了 `mobile/lib/widgets/shared/` 目录，包含以下 8 个共享组件：

### 1. EmptyState (`empty_state.dart`)
- 图标 + 标题 + 描述 + 可选 CTA 按钮
- 居中显示，适合各种页面
- 参数：icon, title, description, actionLabel?, onAction?

### 2. ErrorState (`error_state.dart`)
- 错误图标 + 错误信息 + 重试按钮
- 参数：message, onRetry

### 3. LoadingState (`loading_state.dart`)
- 居中 CircularProgressIndicator + 可选提示文字
- 参数：message?

### 4. CTABar (`cta_bar.dart`)
- 固定在底部的操作栏，SafeArea 处理
- 主按钮高 56，圆角 12
- 可选次要按钮
- 参数：primaryLabel, onPrimary, secondaryLabel?, onSecondary?

### 5. AppHeader (`app_header.dart`)
- 标题 + 可选副标题
- 可选返回按钮
- 可选操作按钮
- 实现了 PreferredSizeWidget 接口

### 6. ListCard (`list_card.dart`)
- 圆角 12，阴影 2
- leading 图标/图片 + title + subtitle + trailing
- 可选点击效果（InkWell）

### 7. RankRow (`rank_row.dart`)
- 排名数字（前 3 名特殊颜色：金/银/铜）
- 头像 + 用户名 + 等级 + XP
- 当前用户高亮（primaryContainer 背景）

### 8. BottomSheetScaffold (`bottom_sheet_scaffold.dart`)
- 顶部拖动指示条
- 标题栏（带关闭按钮）
- 内容区域（可滚动）
- 底部操作区

## 设计规范遵循

- 使用 Material 3 主题系统，不硬编码颜色
- 使用 ScreenUtil 进行屏幕适配（sp, w, h, r）
- 圆角统一 12px
- 安全边距 16
- 主按钮高 56
- 使用 `withValues(alpha: x)` 替代已废弃的 `withOpacity`

## 验证结果

`flutter analyze` 零错误通过。
