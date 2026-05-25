# Mobile — Flutter/GetX 开发指南

> 面向 AI Agent 的 Flutter 客户端开发规范。根目录规范见 [../AGENTS.md](../AGENTS.md)。

---

## 1. 技术栈

| 组件 | 库 |
|------|-----|
| 框架 | Flutter 3.x |
| 状态管理 | GetX（`Obx`、`Rx<T>`、`GetView<T>`） |
| 路由 | GetX Named Routes |
| HTTP | Dio（封装在 `ApiService`） |
| 本地存储 | GetStorage（`StorageService` 封装） |
| 屏幕适配 | flutter_screenutil |
| 离线进度 | `ProgressService` |
| 推送 | Firebase Cloud Messaging |

---

## 2. 目录结构

```
mobile/lib/
├── main.dart                     # 入口：Firebase → GetStorage → runApp
├── routes/
│   └── app_pages.dart            # GetX 路由定义 + Binding
├── bindings/
│   └── app_binding.dart          # 全局依赖注入
├── models/
│   └── app_models.dart           # 全部模型（User/Course/Chapter/Exercise/...）
├── services/
│   ├── api_service.dart          # Dio 封装 + 拦截器 + 错误处理
│   ├── storage_service.dart      # GetStorage 封装
│   ├── progress_service.dart     # 离线进度缓存 + 学习统计
│   └── notification_service.dart # FCM 推送处理
├── controllers/
│   └── base_controller.dart      # PageState 枚举 + 状态管理基类
├── views/
│   ├── splash/splash_view.dart           # 启动页：检查 token → 跳转
│   ├── onboarding/onboarding_view.dart   # 引导页
│   ├── login/login_view.dart             # 登录
│   ├── register/register_view.dart       # 注册
│   ├── home/home_view.dart               # 5-Tab 壳（IndexedStack）
│   ├── home/home_dashboard_view.dart     # 仪表板（数据聚合）
│   ├── course/course_list_view.dart      # 课程列表
│   ├── course/course_detail_view.dart    # 课程详情
│   ├── chapter/chapter_view.dart         # 章节学习
│   ├── exercise/exercise_view.dart       # 编程练习
│   ├── challenge/challenge_list_view.dart
│   ├── challenge/challenge_detail_view.dart
│   ├── daily_challenge/daily_challenge_view.dart
│   ├── social/social_view.dart
│   ├── profile/profile_view.dart
│   ├── profile_edit/profile_edit_view.dart
│   ├── profile_stats/profile_stats_view.dart
│   ├── profile_rewards/profile_rewards_view.dart
│   ├── settings/settings_view.dart
│   └── add_friend/add_friend_view.dart
└── themes/
    └── app_theme.dart            # 主题定义
```

---

## 3. 架构模式

### 3.1 View + Controller + Binding

```dart
// View
class SomeView extends GetView<SomeController> {
  const SomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageStateHost(
      state: controller.pageState.value,
      onRetry: controller.retry,
      child: _buildContent(context),
    ));
  }
}

// Controller（通常与 View 在同一文件底部）
class SomeController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  final Rxn<SomeModel> data = Rxn<SomeModel>();

  @override
  void onInit() {
    super.onInit();
    loadData();
    registerRetry(loadData);
  }

  Future<void> loadData() async {
    try {
      setLoading();
      final response = await _apiService.get('/learner/some-endpoint');
      // 解析数据...
      pageState.value = PageState.initial;
    } catch (e) {
      setError(message: '加载失败');
    }
  }
}
```

### 3.2 状态管理（PageState）

`BaseController` 提供统一状态：

```dart
enum PageState {
  initial,      // 正常显示内容
  loading,      // 加载中
  empty,        // 空数据
  error,        // 错误（全屏）
  offline,      // 离线
  authExpired,  // 登录过期
  partialData,  // 部分数据失败（显示内容 + 顶部警告条）
}
```

使用 `PageStateHost` 包装页面内容，自动处理各状态 UI。

### 3.3 路由

路由定义在 `routes/app_pages.dart`：

```dart
GetPage(
  name: '/chapter/:chapterId',
  page: () => const ChapterView(),
  binding: ChapterBinding(),
),
```

参数传递：

```dart
// 跳转并传参
Get.toNamed('/chapter/$chapterId', parameters: <String, String>{
  'courseId': courseId,
});

// 接收参数
final courseId = Get.parameters['courseId'] ?? '';
```

---

## 4. API 调用规范

### 4.1 标准模式

```dart
class SomeController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  Future<void> fetchData() async {
    try {
      setLoading();
      final response = await _apiService.get('/learner/some-endpoint');

      // 统一解析响应信封
      final payload = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // 构造模型
      final result = SomeModel.fromJson(data);
      // ...
      pageState.value = PageState.initial;
    } catch (e) {
      setError(message: '加载失败，请重试');
    }
  }
}
```

### 4.2 离线优先

`ProgressService` 提供离线缓存：

```dart
ProgressService get _progress => Get.find<ProgressService>();

// 保存进度
await _progress.saveChapterCompleted(chapterId: id, courseId: courseId);

// 读取缓存
final cached = _progress.getCachedUser();
final courses = _progress.getCachedCourses();
```

---

## 5. 添加新页面

1. **创建 View + Controller**：`lib/views/{page}/{page}_view.dart`
2. **注册路由**：`lib/routes/app_pages.dart`
3. **注册 Binding**：`lib/bindings/app_binding.dart`

### 5.1 页面模板

```dart
// lib/views/demo/demo_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/base_controller.dart';
import '../../services/api_service.dart';
import '../../widgets/page_state_host.dart';

class DemoView extends GetView<DemoController> {
  const DemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageStateHost(
      state: controller.pageState.value,
      onRetry: controller.retry,
      child: Scaffold(
        appBar: AppBar(title: const Text('Demo')),
        body: const Center(child: Text('Content')),
      ),
    ));
  }
}

class DemoController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    loadData();
    registerRetry(loadData);
  }

  Future<void> loadData() async {
    try {
      setLoading();
      // API call...
      pageState.value = PageState.initial;
    } catch (e) {
      setError(message: '加载失败');
    }
  }
}

class DemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DemoController>(() => DemoController());
  }
}
```

---

## 6. 模型开发

所有模型集中在 `lib/models/app_models.dart`。

### 6.1 模型规范

```dart
class SomeModel {
  const SomeModel({required this.id, required this.name});

  final String id;
  final String name;

  // 从后端 API 响应构造（字段名与 API 一致）
  factory SomeModel.fromJson(Map<String, dynamic> json) {
    return SomeModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  // 序列化（用于本地缓存）
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

### 6.2 类型安全辅助函数

```dart
// 已定义在 app_models.dart 顶部
int _asInt(dynamic value, {int fallback = 0}) { ... }
double? _asDouble(dynamic value) { ... }
DateTime? _parseDateTime(dynamic value) { ... }
```

---

## 7. 已知陷阱

### 7.1 GetStorage 初始化

```dart
// ✅ 正确：直接 await，不要加 timeout
await GetStorage.init();

// ❌ 错误：可能导致 Web 下初始化不完整
// await GetStorage.init().timeout(Duration(seconds: 2));
```

### 7.2 null 安全处理

```dart
// ✅ 正确：显式检查 null
final challengeRaw = data['daily_challenge'];
if (challengeRaw == null) {
  dailyChallenge.value = null;  // 今日无挑战，正常情况
  return;
}

// ❌ 错误：fallback 到整个 data Map
// final challengeData = (data['daily_challenge'] ?? data) as Map;
// 会把整个响应当作 challenge，导致空内容对象
```

### 7.3 Exercise ID vs Chapter ID

```dart
// ✅ 正确：从 API 获取 exercise 列表，使用第一个 exercise 的 ID
final exercises = await _apiService.get(
  '/learner/courses/$courseId/chapters/$chapterId/exercises'
);
final firstExerciseId = exercises.data['data'][0]['id'];
Get.toNamed('/exercise/$firstExerciseId');

// ❌ 错误：用 chapterId 当 exerciseId
// Get.toNamed('/exercise/$chapterId');  // 404
```

### 7.4 Splash 自动登录

`SplashView` 检查 `StorageService` 中的 `auth_token`：
- 存在有效 token → 跳转 `/home`
- 无 token → 跳转 `/login`
- 首次启动 → 跳转 `/onboarding`

**不要硬编码 token**，正常依赖登录流程写入 Storage。

### 7.5 Web 下的限制

- `GetStorage` 使用 `localStorage`，浏览器隐私模式可能不可用
- 每次新 session 需要点击 `flt-semantics-placeholder` 启用 accessibility（自动化测试时）
- 代码编辑器是自定义渲染的 textarea，Playwright 等工具需要用 JS `document.querySelector('textarea').value = ...` 注入代码

---

## 8. 构建与测试

```bash
cd mobile

flutter pub get                    # 安装依赖
flutter analyze                    # 静态分析
flutter test                       # 运行测试
flutter run -d chrome              # Web 开发运行
flutter build web --release        # 发布构建
cd build/web && python3 -m http.server 8088   # 本地预览
```
