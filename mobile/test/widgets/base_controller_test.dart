import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:learning_app_mobile/controllers/base_controller.dart';
import 'package:learning_app_mobile/services/storage_service.dart';

class _TestController extends BaseController {}

class _FakeStorageService extends StorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};

  @override
  void onInit() {}

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
  bool hasKey(String key) {
    return _data.containsKey(key);
  }

  @override
  Future<void> clearAuthSession() async {
    _data.remove(StorageService.authTokenKey);
  }

  @override
  String? readAuthToken() {
    return read<String>(StorageService.authTokenKey);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<StorageService>(_FakeStorageService());
  });

  tearDown(() async {
    if (Get.isRegistered<StorageService>()) {
      await Get.find<StorageService>().clear();
    }
    Get.reset();
  });

  testWidgets('auth expired clears token and redirects to login', (tester) async {
    final storage = Get.find<StorageService>();
    await storage.write(StorageService.authTokenKey, 'token-123');

    final controller = Get.put(_TestController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/protected',
        getPages: [
          GetPage(
            name: '/protected',
            page: () => const Scaffold(body: Text('Protected content')),
          ),
          GetPage(
            name: '/login',
            page: () => const Scaffold(body: Text('Login page')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await controller.setAuthExpired(message: 'Please sign in again.');
    await tester.pumpAndSettle();

    expect(storage.readAuthToken(), isNull);
    expect(controller.pageState.value, PageState.authExpired);
    expect(find.text('Login page'), findsOneWidget);
    expect(find.text('Protected content'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  test('state helpers update page flags consistently', () {
    final controller = _TestController();

    controller.setLoading(message: 'Busy');
    expect(controller.pageState.value, PageState.loading);
    expect(controller.stateMessage.value, 'Busy');
    expect(controller.hasPartialData.value, isFalse);

    controller.setEmpty(message: 'Nothing');
    expect(controller.pageState.value, PageState.empty);
    expect(controller.stateMessage.value, 'Nothing');
    expect(controller.hasPartialData.value, isFalse);

    controller.setError(message: 'Oops');
    expect(controller.pageState.value, PageState.error);
    expect(controller.stateMessage.value, 'Oops');

    controller.setOffline(message: 'Offline');
    expect(controller.pageState.value, PageState.offline);
    expect(controller.stateMessage.value, 'Offline');

    controller.setPartialData(message: 'Partial');
    expect(controller.pageState.value, PageState.partialData);
    expect(controller.stateMessage.value, 'Partial');
    expect(controller.hasPartialData.value, isTrue);

    controller.resetState();
    expect(controller.pageState.value, PageState.initial);
    expect(controller.stateMessage.value, isEmpty);
    expect(controller.hasPartialData.value, isFalse);
  });

  test('retry executes registered callback when available', () async {
    final controller = _TestController();
    var callCount = 0;

    controller.registerRetry(() async {
      callCount += 1;
    });

    await controller.retry();

    expect(callCount, 1);
  });

  test('retry is a no-op when no callback is registered', () async {
    final controller = _TestController();

    await controller.retry();

    expect(controller.pageState.value, PageState.initial);
    expect(controller.stateMessage.value, isEmpty);
  });
}
