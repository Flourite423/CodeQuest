import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:codequest/controllers/base_controller.dart';
import 'package:codequest/routes/app_pages.dart';
import 'package:codequest/services/api_service.dart';
import 'package:codequest/services/mock_data.dart';
import 'package:codequest/services/storage_service.dart';
import 'package:codequest/themes/app_theme.dart';
import 'package:codequest/views/challenge/challenge_detail_view.dart';
import 'package:codequest/views/challenge/challenge_list_view.dart';
import 'package:codequest/views/chapter/chapter_view.dart';
import 'package:codequest/views/course/course_detail_view.dart';
import 'package:codequest/views/course/course_list_view.dart';

import 'package:codequest/views/home/home_dashboard_view.dart';
import 'package:codequest/views/profile/profile_view.dart';
import 'package:codequest/views/social/social_view.dart';

typedef PostHandler = FutureOr<dio.Response<dynamic>> Function(dynamic data);
typedef GetHandler = FutureOr<dio.Response<dynamic>> Function(
  Map<String, dynamic>? queryParameters,
);

class _FakeStorageService extends StorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};


  @override
  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  T? read<T>(String key) {
    return _data[key] as T?;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<void> clearAuthSession() async {
    _data.remove(StorageService.authTokenKey);
  }

  @override
  bool hasKey(String key) {
    return _data.containsKey(key);
  }

  @override
  String? readAuthToken() {
    return read<String>(StorageService.authTokenKey);
  }
}

class _FakeApiService extends ApiService {
  _FakeApiService({
    Map<String, PostHandler>? postHandlers,
    Map<String, GetHandler>? getHandlers,
  })  : _postHandlers = postHandlers ?? <String, PostHandler>{},
        _getHandlers = getHandlers ?? <String, GetHandler>{};

  final Map<String, PostHandler> _postHandlers;
  final Map<String, GetHandler> _getHandlers;


  @override
  Future<dio.Response<dynamic>> post(String path, {dynamic data}) async {
    final handler = _postHandlers[path];
    if (handler == null) {
      return _jsonResponse(path, statusCode: 200, data: <String, dynamic>{'ok': true});
    }
    return await handler(data);
  }

  @override
  Future<dio.Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final handler = _getHandlers[path];
    if (handler == null) {
      return _jsonResponse(path, statusCode: 200, data: <String, dynamic>{'ok': true});
    }
    return await handler(queryParameters);
  }
}

class _TestBinding extends Bindings {
  _TestBinding({
    required this.apiService,
    required this.storageService,
    MockDataService? mockDataService,
  }) : mockDataService = mockDataService ?? MockDataService();

  final _FakeApiService apiService;
  final _FakeStorageService storageService;
  final MockDataService mockDataService;

  @override
  void dependencies() {
    Get.put<StorageService>(storageService, permanent: true);
    Get.put<ApiService>(apiService, permanent: true);
    Get.put<MockDataService>(mockDataService, permanent: true);

    if (!Get.isRegistered<HomeDashboardController>()) {
      Get.lazyPut<HomeDashboardController>(() => HomeDashboardController(), fenix: true);
    }
    if (!Get.isRegistered<CourseListController>()) {
      Get.lazyPut<CourseListController>(() => CourseListController(), fenix: true);
    }
    if (!Get.isRegistered<ChallengeListController>()) {
      Get.lazyPut<ChallengeListController>(() => ChallengeListController(), fenix: true);
    }
    if (!Get.isRegistered<SocialController>()) {
      Get.lazyPut<SocialController>(() => SocialController(), fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
  }
}

class _ProtectedProbeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onReady() {
    super.onReady();
    unawaited(_checkAccess());
  }

  Future<void> _checkAccess() async {
    try {
      await _apiService.get('/protected');
    } on dio.DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await BaseController.handleUnauthorized(
          message: 'Please sign in again.',
        );
      }
    } catch (_) {
      // Redirect assertions happen in the integration test.
    }
  }
}

class _ProtectedProbeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<_ProtectedProbeController>(() => _ProtectedProbeController());
  }
}

class _ProtectedProbeView extends GetView<_ProtectedProbeController> {
  const _ProtectedProbeView();

  @override
  Widget build(BuildContext context) {
    controller;
    return const Scaffold(
      body: Center(child: Text('Protected content')),
    );
  }
}

dio.Response<dynamic> _jsonResponse(
  String path, {
  required int statusCode,
  required dynamic data,
}) {
  return dio.Response<dynamic>(
    requestOptions: dio.RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

dio.DioException _responseError(
  String path, {
  required int statusCode,
  dynamic data,
}) {
  return dio.DioException(
    requestOptions: dio.RequestOptions(path: path),
    response: dio.Response<dynamic>(
      requestOptions: dio.RequestOptions(path: path),
      statusCode: statusCode,
      data: data,
    ),
    type: dio.DioExceptionType.badResponse,
  );
}

dio.DioException _networkError(String path) {
  return dio.DioException(
    requestOptions: dio.RequestOptions(path: path),
    type: dio.DioExceptionType.connectionError,
    error: Exception('Network unavailable'),
  );
}

Widget _buildTestApp({
  required _FakeApiService apiService,
  required _FakeStorageService storageService,
  MockDataService? mockDataService,
  String initialRoute = AppPages.initialRoute,
  List<GetPage<dynamic>> extraPages = const <GetPage<dynamic>>[],
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) {
      return GetMaterialApp(
        title: 'CodeQuest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialBinding: _TestBinding(
          apiService: apiService,
          storageService: storageService,
          mockDataService: mockDataService,
        ),
        initialRoute: initialRoute,
        getPages: <GetPage<dynamic>>[
          ...AppPages.routes,
          ...extraPages,
        ],
        defaultTransition: Transition.fade,
      );
    },
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required _FakeApiService apiService,
  required _FakeStorageService storageService,
  MockDataService? mockDataService,
  String initialRoute = AppPages.initialRoute,
  List<GetPage<dynamic>> extraPages = const <GetPage<dynamic>>[],
}) async {
  await tester.pumpWidget(
    _buildTestApp(
      apiService: apiService,
      storageService: storageService,
      mockDataService: mockDataService,
      initialRoute: initialRoute,
      extraPages: extraPages,
    ),
  );
  await tester.pump();
}

Future<void> _settleMockData(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

Future<void> _waitForSnackbarToDisappear(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _fillLoginForm(
  WidgetTester tester, {
  String email = 'learner@example.com',
  String password = 'secret123',
}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.pump();
}

Future<void> _fillRegisterForm(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'New Learner');
  await tester.enterText(find.byType(TextField).at(1), 'new@example.com');
  await tester.enterText(find.byType(TextField).at(2), 'secret123');
  await tester.enterText(find.byType(TextField).at(3), 'secret123');
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = false;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('启动后完成 onboarding、登录并进入首页', (tester) async {
    final storage = _FakeStorageService();
    final api = _FakeApiService(
      postHandlers: <String, PostHandler>{
        '/auth/login': (_) => _jsonResponse(
          '/auth/login',
          statusCode: 200,
          data: <String, dynamic>{'token': 'token-login'},
        ),
      },
    );

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/splash',
    );

    expect(find.text('CodeQuest'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Learn Anything'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    await _fillLoginForm(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);

    expect(storage.readAuthToken(), 'token-login');
    expect(Get.currentRoute, '/home');
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('今日成长'), findsOneWidget);
  });

  testWidgets('登录失败时展示 401 错误态', (tester) async {
    final storage = _FakeStorageService();
    final api = _FakeApiService(
      postHandlers: <String, PostHandler>{
        '/auth/login': (_) => throw _responseError(
          '/auth/login',
          statusCode: 401,
          data: <String, dynamic>{'message': 'Unauthorized'},
        ),
      },
    );

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/login',
    );

    await _fillLoginForm(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(Get.currentRoute, '/login');
    expect(storage.readAuthToken(), isNull);
  });

  testWidgets('登录失败时展示网络错误态', (tester) async {
    final storage = _FakeStorageService();
    final api = _FakeApiService(
      postHandlers: <String, PostHandler>{
        '/auth/login': (_) => throw _networkError('/auth/login'),
      },
    );

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/login',
    );

    await _fillLoginForm(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('No internet connection. Please check your network.'), findsOneWidget);
    expect(Get.currentRoute, '/login');
  });

  testWidgets('注册成功后自动进入首页', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    final api = _FakeApiService(
      postHandlers: <String, PostHandler>{
        '/auth/register': (_) => _jsonResponse(
          '/auth/register',
          statusCode: 201,
          data: <String, dynamic>{'token': 'token-register'},
        ),
      },
    );

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/login',
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);

    await _fillRegisterForm(tester);
    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();
    await _settleMockData(tester);

    expect(storage.readAuthToken(), 'token-register');
    expect(Get.currentRoute, '/home');
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tab 切换后渲染对应内容并支持返回', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    await storage.write(StorageService.authTokenKey, 'token-home');
    final api = _FakeApiService();

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/home',
    );
    await _settleMockData(tester);

    expect(find.text('今日成长'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);
    expect(find.text('Courses'), findsAtLeastNWidgets(1));
    expect(find.text('Frontend Foundations 1'), findsOneWidget);

    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);
    expect(find.text('Challenge Map'), findsOneWidget);

    await tester.tap(find.text('Social'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);
    expect(find.text('Social Center'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('View Stats'), findsOneWidget);

    await tester.tap(find.text('View Stats'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/profile/stats');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/home');
    expect(find.text('Quick Access'), findsOneWidget);
  });

  testWidgets('课程详情、章节、练习与底部面板流程可达', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    await storage.write(StorageService.authTokenKey, 'token-detail');
    final api = _FakeApiService();

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/home',
    );
    await _settleMockData(tester);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);

    await tester.tap(find.text('Frontend Foundations 1'));
    await tester.pumpAndSettle();
    expect(Get.find<CourseController>().courseId.value, 'course-1');
    expect(find.text('Continue Learning'), findsOneWidget);

    await tester.tap(find.text('Continue Learning'));
    await tester.pumpAndSettle();
    expect(Get.find<ChapterController>().chapterId.value, 'chapter-2');

    await tester.tap(find.text('Complete Learning'));
    await tester.pumpAndSettle();
    expect(find.text('Complete Chapter?'), findsOneWidget);

    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();
    expect(find.text('Go to Exercise'), findsOneWidget);
    await _waitForSnackbarToDisappear(tester);

    await tester.tap(find.text('Go to Exercise'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/exercise/chapter-2');
    expect(find.text('Exercise 2'), findsOneWidget);

    await tester.tap(find.textContaining('Rely only on visual spacing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('提交结果'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('提交结果'), findsNothing);

    await tester.tap(find.text('AI 帮助'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('AI 帮助'), findsOneWidget);
    expect(find.text('继续练习'), findsOneWidget);

    await tester.tap(find.text('继续练习'));
    await tester.pumpAndSettle();
    expect(find.text('AI 帮助'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/chapter/chapter-2');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/course/course-1');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/home');
  });

  testWidgets('锁定挑战点击后停留当前页并提示失败原因', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    await storage.write(StorageService.authTokenKey, 'token-challenge');
    final api = _FakeApiService();

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/home',
    );
    await _settleMockData(tester);

    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);

    await tester.scrollUntilVisible(
      find.text('Challenge 3'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Challenge 3'));
    await tester.pumpAndSettle();

    expect(find.text('Complete the previous challenge first.'), findsOneWidget);
    expect(Get.currentRoute, '/home');
    expect(find.text('Challenge Map'), findsOneWidget);
    await _waitForSnackbarToDisappear(tester);
  });

  testWidgets('挑战详情完成领奖后可进入奖励中心并打开徽章预览', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    await storage.write(StorageService.authTokenKey, 'token-rewards');
    final api = _FakeApiService();

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/challenge/challenge-2',
    );
    await _settleMockData(tester);

    expect(Get.find<ChallengeController>().challengeId.value, 'challenge-2');
    expect(find.text('Start Challenge'), findsOneWidget);

    await tester.tap(find.text('Start Challenge'));
    await tester.pumpAndSettle();
    expect(find.text('Complete Challenge'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(Checkbox).at(1),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(Checkbox).at(2),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Challenge'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Challenge Completed!'), findsOneWidget);
    expect(find.text('Claim Reward'), findsOneWidget);

    await tester.tap(find.text('Claim Reward'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.textContaining('Reward settled:'), findsOneWidget);
    expect(find.text('Back to Map'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('View Achievements'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('View Achievements'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);
    await _waitForSnackbarToDisappear(tester);

    expect(Get.currentRoute, '/profile');
    expect(find.text('Quick Access'), findsOneWidget);

    await tester.tap(find.text('Rewards Center'));
    await tester.pumpAndSettle();
    await _settleMockData(tester);

    expect(Get.currentRoute, '/profile/rewards');
    expect(find.text('Rewards Ledger'), findsOneWidget);

    await tester.tap(find.text('Badge 1').first);
    await tester.pumpAndSettle();

    expect(find.text('Share Achievement'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Share Achievement'), findsNothing);
  });

  testWidgets('401 受保护页面访问会清 token 并重定向登录', (tester) async {
    final storage = _FakeStorageService();
    await storage.write('first_launch', true);
    await storage.write(StorageService.authTokenKey, 'expired-token');

    final api = _FakeApiService(
      getHandlers: <String, GetHandler>{
        '/protected': (_) => throw _responseError(
          '/protected',
          statusCode: 401,
          data: <String, dynamic>{'message': 'Unauthorized'},
        ),
      },
    );

    await _pumpApp(
      tester,
      apiService: api,
      storageService: storage,
      initialRoute: '/protected',
      extraPages: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: '/protected',
          page: () => const _ProtectedProbeView(),
          binding: _ProtectedProbeBinding(),
        ),
      ],
    );

    expect(find.text('Protected content'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(storage.readAuthToken(), isNull);
    expect(Get.currentRoute, '/login');
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
