# Views — Flutter View/Controller 开发指南

> 面向 AI Agent 的 View 层规范。上级规范见 [../../AGENTS.md](../../AGENTS.md) 和 [../AGENTS.md](../AGENTS.md)。

---

## 1. 目录结构

```
mobile/lib/views/
├── splash/splash_view.dart              # 启动页（StatefulWidget，无 BaseController）
├── onboarding/onboarding_view.dart      # 引导页（GetxController，非 BaseController）
├── login/login_view.dart                # 登录
├── register/register_view.dart          # 注册
├── home/home_view.dart                  # 5-Tab 壳（GetxController，非 BaseController）
├── home/home_dashboard_view.dart        # 仪表板（BaseController）
├── course/course_list_view.dart         # 课程列表
├── course/course_detail_view.dart       # 课程详情
├── chapter/chapter_view.dart            # 章节学习
├── exercise/exercise_view.dart          # 编程练习（最大文件，1295行）
├── challenge/challenge_list_view.dart   # 挑战列表
├── challenge/challenge_detail_view.dart # 挑战详情
├── daily_challenge/daily_challenge_view.dart  # 每日挑战
├── social/social_view.dart              # 社交动态
├── add_friend/add_friend_view.dart      # 添加好友
├── profile/profile_view.dart            # 个人资料
├── profile_edit/profile_edit_view.dart  # 编辑资料
├── profile_stats/profile_stats_view.dart    # 统计
├── profile_rewards/profile_rewards_view.dart # 奖励
└── settings/settings_view.dart          # 设置
```

**20 个页面文件**，每个文件包含 View + Controller + Binding。

---

## 2. 核心架构模式

### 2.1 View + Controller + Binding 同文件（⚠️ 关键约定）

**所有 Controller 和 Binding 与 View 定义在同一文件中**，不在 `lib/controllers/` 目录中。

```dart
// lib/views/demo/demo_view.dart
class DemoView extends GetView<DemoController> { ... }       // View
class DemoController extends BaseController { ... }          // Controller
class DemoBinding extends Bindings { ... }                   // Binding
```

`lib/controllers/` 中唯一的文件是 `base_controller.dart`。

### 2.2 例外：不使用 BaseController 的页面

| 页面 | 使用的 Controller 类型 | 原因 |
|------|----------------------|------|
| SplashView | `StatefulWidget` + `State` | 纯导航逻辑，无数据获取 |
| OnboardingView | `GetxController` | 纯 UI 状态，无 API 调用 |
| HomeView | `GetxController` | Tab 外壳，无数据获取 |

**规则**：只有数据获取型页面使用 `BaseController`。

### 2.3 5-Tab Home 系统

```dart
class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final visitedTabs = <int>[0].obs;  // 惰性初始化

  void changeTab(int index) {
    if (!visitedTabs.contains(index)) visitedTabs.add(index);
    selectedIndex.value = index;
  }
}
```

Tab 顺序：0=首页, 1=课程, 2=挑战, 3=社交, 4=个人中心。

---

## 3. BaseController 状态系统

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

**使用 PageStateHost 包装页面内容**：

```dart
@override
Widget build(BuildContext context) {
  return Obx(() => PageStateHost(
    state: controller.pageState.value,
    onRetry: controller.retry,
    child: _buildContent(context),
  ));
}
```

---

## 4. API 调用模式

### 4.1 标准数据获取流程

```dart
Future<void> loadData() async {
  try {
    setLoading();
    
    // 检查在线状态
    if (!_progressService.isOnline.value) {
      // 从缓存加载
      final cached = _progressService.getCachedCourses();
      if (cached != null) {
        // 使用缓存数据
        pageState.value = PageState.partialData;
        return;
      }
    }
    
    // API 调用
    final response = await _apiService.get('/learner/courses');
    
    // 解析响应（标准 4 行）
    final payload = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final data = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    // 构造模型
    final result = SomeModel.fromJson(data);
    
    // 缓存到本地
    await _progressService.cacheCourses(result);
    
    pageState.value = PageState.initial;
  } catch (e) {
    setError(message: '加载失败');
  }
}
```

### 4.2 DioException 处理（标准模式）

```dart
on dio.DioException catch (e) {
  if (e.response?.statusCode == 401) {
    pageState.value = PageState.authExpired;
  } else if (e.response?.statusCode == 403) {
    setError(message: '无权访问');
  } else if (e.response?.statusCode == 404) {
    setError(message: '资源不存在');
  } else if (e.response?.statusCode == 500) {
    setError(message: '服务器错误');
  } else if (e.type == dio.DioExceptionType.connectionTimeout) {
    setError(message: '连接超时');
  } else {
    setError(message: '网络错误');
  }
}
```

---

## 5. 服务层访问模式

### 5.1 标准依赖获取

```dart
class SomeController extends BaseController {
  ApiService get _apiService => Get.find<ApiService>();
  
  // ProgressService 防御性初始化（冗余但无害）
  ProgressService get _progressService {
    if (Get.isRegistered<ProgressService>()) {
      return Get.find<ProgressService>();
    }
    return Get.put(ProgressService(), permanent: true);
  }
}
```

### 5.2 离线优先

每个数据加载方法：
1. 检查 `_progressService.isOnline.value`
2. 离线时从 `GetStorage` 缓存加载
3. 在线时正常获取并写入缓存
4. 在线但失败时回退到缓存（`PageState.partialData`）

---

## 6. 导航与参数

### 6.1 路由参数

```dart
// 跳转并传参
Get.toNamed('/chapter/$chapterId', parameters: <String, String>{
  'courseId': courseId,
});

// 接收参数
final chapterId = Get.parameters['chapterId'] ?? '';
final courseId = Get.parameters['courseId'] ?? '';
```

### 6.2 章节页面特殊回退

如果从练习页返回时 `courseId` 丢失，从缓存推断：

```dart
String _getCourseId() {
  return Get.parameters['courseId'] ?? 
      _progressService.getCachedCourseForChapter(chapterId) ?? 
      '';
}
```

---

## 7. 已知陷阱

| 问题 | 影响 | 解决方案 |
|------|------|---------|
| Controller 与 View 同文件 | 文件过大 | 保持现状，如需拆分遵循现有模式 |
| 重复 API 解析代码 | 维护困难 | 如需提取帮助方法，保持向后兼容 |
| ProgressService 防御性初始化 | 冗余 | 无害，可保留 |
| 挑战任务 placeholder | 后端无真实任务 ID | 使用合成 ID `challenge-{id}-stage-{n}` |
| 每日挑战提交硬编码 | score=100 | 实际由后端计算，前端显示即可 |
| 头像上传 TODO | 功能未完成 | 使用占位实现 |

---

## 8. 添加新页面的步骤

1. **创建文件**：`lib/views/{page}/{page}_view.dart`
2. **实现 View**：`class {Page}View extends GetView<{Page}Controller>`
3. **实现 Controller**：`class {Page}Controller extends BaseController`
4. **实现 Binding**：`class {Page}Binding extends Bindings`
5. **注册路由**：`lib/routes/app_pages.dart`
6. **注册 Binding**：`lib/bindings/app_binding.dart`（如需全局）

### 8.1 页面模板

```dart
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
      final response = await _apiService.get('/learner/some-endpoint');
      // 解析数据...
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

## 9. 模型工厂命名

```dart
// API 响应（Contract-first）
factory Course.fromDetailJson(JsonMap json)
factory Course.fromListItemJson(JsonMap json)
factory User.fromContracts({required JsonMap account, required JsonMap profile})

// 本地存储
factory Course.fromJson(JsonMap json)     // 来自 GetStorage
Map<String, dynamic> toJson()            // 到 GetStorage

// 特定端点
factory User.fromPersonalStatsJson(JsonMap json)
factory Badge.fromAwardJson(JsonMap json)
```

---

## 10. 测试相关

- **无 Service 测试**：`test/services/` 不存在
- **无 Model 测试**：`test/models/` 不存在
- **测试文件位置**：`test/widgets/`
- **测试约定**：使用 `_Test{Page}Controller` 覆盖 `onInit` 跳过自动加载
- **黄金测试**：`test/widgets/page_golden_test.dart`（753 行）

如需添加测试，遵循现有 `_FakeStorageService` 和 `_Test*Controller` 模式。
