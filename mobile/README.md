# CodeQuest Mobile

基于 Flutter + GetX 的 CodeQuest 移动端。

## 项目结构

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
│   ├── models/                   # 数据模型
│   ├── views/                    # 页面视图
│   │   ├── splash/
│   │   ├── login/
│   │   ├── home/
│   │   ├── course/
│   │   ├── challenge/
│   │   └── friends/
│   └── controllers/              # 业务逻辑控制器
├── assets/                       # 静态资源
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml                  # 依赖配置
└── README.md
```

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: GetX
- **网络请求**: Dio + Retrofit
- **本地存储**: GetStorage
- **UI 适配**: flutter_screenutil
- **图片缓存**: cached_network_image

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
flutter pub run build_runner build
```

### 3. 运行应用

```bash
flutter run
```

## 开发规范

1. 使用 GetX 进行状态管理和路由管理
2. 遵循 MVC 架构：View → Controller → Service → API
3. 所有 API 调用通过 ApiService 统一处理
4. 本地数据存储通过 StorageService 管理
5. 使用 ScreenUtil 进行屏幕适配

## 页面说明

- **Splash**: 启动页，检查登录状态
- **Login**: 手机号 + 验证码登录
- **Home**: 主页面，包含底部导航栏
  - Courses: 课程列表
  - Challenges: 挑战列表
  - Leaderboard: 排行榜
  - Profile: 个人中心
- **Course Detail**: 课程详情页
- **Challenge Detail**: 挑战详情页
- **Friends**: 好友列表页

## 契约优先

本分支遵循契约优先开发原则。所有 API 调用必须：
1. 参考 `contracts/openapi/openapi.yaml` 中的定义
2. 使用 Retrofit 生成类型安全的 API 客户端
3. 保持与后端契约的一致性

## 环境配置

在 `lib/config/` 目录下创建环境配置文件：

```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String apiVersion = 'v1';
}
```
