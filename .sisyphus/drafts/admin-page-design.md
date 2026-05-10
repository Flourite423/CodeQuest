# Draft: Admin端页面设计

## 需求确认
- 在admin分支单独开发admin端
- 中文界面
- 使用Element Plus组件库
- 基于现有Vue 3 + Vite + Pinia + TypeScript技术栈

## 技术现状
- admin目录已存在基础项目结构
- 已有8个基础页面（英文界面）
- 使用Element Plus但界面为英文
- 路由、布局、状态管理已搭建
- 契约优先：需对齐contracts/openapi/openapi.yaml

## 关键设计决策
- 全面中文化：所有UI文本、标签、提示改为中文
- 保持Element Plus默认主题或定制主题色
- 遵循契约中的admin DTO定义和字段规范
- 按契约重组页面结构，严格对齐admin tags
- Leaderboard移除，功能并入Dashboard

## 已确认问题
- 设计深度：全面重新设计（视觉+交互+功能增强）
- 深色模式：不需要
- 响应式布局：不需要，仅桌面端
- 页面架构：完全按契约重组，严格对齐admin tags
- 新增页面：题目管理(Practice)、公告与配置(Announcements)
- 移除页面：Leaderboard（功能并入Dashboard）
