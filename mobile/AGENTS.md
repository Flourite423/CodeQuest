# MOBILE KNOWLEDGE BASE

**Generated:** 2026-05-07
**Branch:** mobile
**Framework:** Flutter 3.x + GetX

## OVERVIEW

学习应用移动端，基于 Flutter + GetX 构建。使用 ScreenUtil 进行屏幕适配，Dio + Retrofit 处理网络请求，GetStorage 进行本地存储。

## STRUCTURE

```
mobile/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── bindings/                 # 依赖注入绑定
│   │   └── app_binding.dart
│   ├── routes/                   # 路由配置
│   │   └── app_pages.dart
│   ├── themes/                   # 主题配置
│   │   └── app_theme.dart
│   ├── services/                 # 服务层
│   │   ├── api_service.dart      # API 客户端
│   │   └── storage_service.dart  # 本地存储
│   ├── models/                   # 数据模型（预留）
│   ├── views/                    # 页面视图
│   │   ├── splash/
│   │   ├── login/
│   │   ├── home/
│   │   │   └── 包含 CourseListView, ChallengeListView, LeaderboardView, ProfileView
│   │   ├── course/
│   │   ├── challenge/
│   │   └── friends/
│   └── controllers/              # 业务逻辑控制器（与 View 同文件）
├── assets/                       # 静态资源（预留）
│   ├── images/
│   ├── icons/
│   └── fonts/
└── pubspec.yaml
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| 添加新页面 | `lib/views/` | 每个页面独立目录，包含 View + Controller + Binding |
| 配置路由 | `lib/routes/app_pages.dart` | 使用 GetPage 定义路由和绑定 |
| 修改主题 | `lib/themes/app_theme.dart` | Material3 + ColorScheme.fromSeed |
| 添加服务 | `lib/services/` | 继承 GetxService，在 AppBinding 中注册 |
| 依赖注入 | `lib/bindings/app_binding.dart` | 全局服务懒加载 |
| 屏幕适配 | 所有 build 方法 | 使用 ScreenUtil (sp, w, h) |

## CODE MAP

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| LearningApp | StatelessWidget | main.dart | 应用根组件 |
| AppBinding | Bindings | bindings/app_binding.dart | 全局依赖注入 |
| AppPages | Class | routes/app_pages.dart | 路由配置 |
| AppTheme | Class | themes/app_theme.dart | 主题配置 |
| ApiService | GetxService | services/api_service.dart | HTTP 客户端 |
| StorageService | GetxService | services/storage_service.dart | 本地存储 |
| SplashView | GetView | views/splash/ | 启动页 |
| LoginView | GetView | views/login/ | 登录页 |
| HomeView | GetView | views/home/ | 主页面（含底部导航） |
| CourseDetailView | GetView | views/course/ | 课程详情 |
| ChallengeDetailView | GetView | views/challenge/ | 挑战详情 |
| FriendsView | GetView | views/friends/ | 好友列表 |

## CONVENTIONS

### 架构模式
- **View → Controller → Service → API**
- 每个页面包含：View（UI）+ Controller（逻辑）+ Binding（依赖注入）
- Controller 与 View 同文件定义

### 命名规范
- View: `XxxView` extends `GetView<XxxController>`
- Controller: `XxxController` extends `GetxController`
- Binding: `XxxBinding` extends `Bindings`
- Service: `XxxService` extends `GetxService`

### 状态管理
- 使用 `.obs` 定义响应式变量
- 使用 `Obx(() => ...)` 包裹需要响应式更新的 Widget
- 避免在 build 方法中直接访问 `.value`

### 屏幕适配
- 字体大小：`14.sp`
- 宽度：`100.w`
- 高度：`50.h`
- 设计稿基准：375x812（iPhone X）

### 路由
- 使用 `Get.toNamed('/route')` 跳转
- 使用 `Get.offAllNamed('/route')` 清除栈跳转
- 参数传递：`Get.parameters['id']`

## ANTI-PATTERNS

- **不要在 View 中直接调用 API**：必须通过 Controller → Service
- **不要硬编码颜色**：使用 Theme.of(context) 或 AppTheme
- **不要使用 setState**：使用 GetX 响应式状态
- **不要重复创建 Dio 实例**：统一使用 ApiService
- **不要直接访问 GetStorage**：通过 StorageService 封装

## UNIQUE STYLES

### 页面结构
每个页面目录包含单一 .dart 文件，内部定义三个类：
```dart
class XxxView extends GetView<XxxController> { ... }
class XxxController extends GetxController { ... }
class XxxBinding extends Bindings { ... }
```

### 主题特点
- Material3 设计
- 圆角统一 12px（卡片、按钮、输入框）
- 主色：蓝色（0xFF2196F3）
- 支持亮色/暗色主题

### 导航栏
- 底部 4 个 Tab：Courses / Challenges / Ranking / Profile
- 使用 IndexedStack 保持页面状态

## COMMANDS

```bash
# 安装依赖
flutter pub get

# 生成代码（Retrofit/Freezed）
flutter pub run build_runner build

# 运行应用
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios
```

## UI/UX SKILL

本项目使用 `ui-ux-pro-max` skill 进行 Flutter 页面设计。

### 使用方法

1. **生成设计系统**（必需）：
   ```bash
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<产品类型> <行业> <风格关键词>" --design-system -p "Learning App"
   ```

2. **补充搜索**（按需）：
   ```bash
   # 样式细节
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<关键词>" --domain style
   
   # 字体搭配
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<关键词>" --domain typography
   
   # 颜色方案
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<关键词>" --domain color
   
   # UX 最佳实践
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<关键词>" --domain ux
   ```

3. **Flutter 技术栈指南**：
   ```bash
   python3 .opencode/skills/ui-ux-pro-max/scripts/search.py "<关键词>" --stack flutter
   ```

### 设计原则

- 使用 Material3 设计规范
- 所有圆角统一 12px
- 主色：蓝色（0xFF2196F3）
- 支持亮色/暗色主题切换
- 使用 ScreenUtil 进行屏幕适配
- 避免使用 emoji 作为图标
- 确保足够的颜色对比度

## NOTES

- 契约优先：API 调用参考 `contracts/openapi/openapi.yaml`
- 使用 Retrofit 生成类型安全的 API 客户端
- assets 目录已预留但未创建实际文件
- 登录页面 SMS 验证待实现（TODO）
- 所有页面使用模拟数据，未连接真实 API
