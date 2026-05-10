import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

const AndroidNotificationChannel _defaultNotificationChannel =
    AndroidNotificationChannel(
      'codequest_notifications',
      '学习提醒',
      description: '用于显示学习应用的推送与测试通知。',
      importance: Importance.high,
    );

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('后台消息初始化 Firebase 失败: $e');
  }

  debugPrint(
    '收到后台消息: ${message.messageId ?? 'unknown'} / ${message.notification?.title ?? '无标题'}',
  );
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('后台点击本地通知: ${response.payload}');
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxnString fcmToken = RxnString();
  final RxString permissionStatusText = '未申请'.obs;
  final RxString lastMessageSummary = '暂无通知记录'.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxBool firebaseReady = false.obs;

  bool _isInitializing = false;
  bool _localNotificationsReady = false;
  FirebaseMessaging? _messaging;

  bool get _supportsFcm {
    if (kIsWeb) {
      return true;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  bool get _supportsLocalNotifications {
    return !kIsWeb;
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      await _ensureFirebaseInitialized();
      await _initializeLocalNotifications();

      if (_supportsFcm && firebaseReady.value) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        await _configureForegroundPresentation();
        await requestPermission();
        await _bindMessageListeners();
        await refreshToken();
      } else if (!_supportsFcm) {
        permissionStatusText.value = '当前平台不支持 FCM';
      }
    } catch (e) {
      debugPrint('通知服务初始化失败: $e');
      permissionStatusText.value = '通知初始化失败';
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) {
      firebaseReady.value = true;
      _messaging = FirebaseMessaging.instance;
      return;
    }

    try {
      await Firebase.initializeApp();
      firebaseReady.value = true;
      _messaging = FirebaseMessaging.instance;
    } catch (e) {
      firebaseReady.value = false;
      debugPrint('Firebase 初始化失败，通知服务降级运行: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsReady || !_supportsLocalNotifications) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: '打开通知',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultNotificationChannel);

    _localNotificationsReady = true;
  }

  Future<void> _configureForegroundPresentation() async {
    await _messaging?.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _bindMessageListeners() async {
    final messaging = _messaging;
    if (messaging == null) {
      return;
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    messaging.onTokenRefresh.listen((token) {
      fcmToken.value = token;
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage, launchedFromTerminated: true);
    }
  }

  Future<NotificationSettings?> requestPermission() async {
    if (!_supportsFcm || !firebaseReady.value) {
      permissionStatusText.value = '等待 Firebase 配置完成';
      return null;
    }

    final messaging = _messaging;
    if (messaging == null) {
      permissionStatusText.value = '等待 Firebase 配置完成';
      return null;
    }

    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _updatePermissionState(settings.authorizationStatus);
      return settings;
    } catch (e) {
      permissionStatusText.value = '权限请求失败';
      debugPrint('通知权限请求失败: $e');
      return null;
    }
  }

  Future<String?> refreshToken() async {
    if (!_supportsFcm || !firebaseReady.value) {
      fcmToken.value = null;
      return null;
    }

    final messaging = _messaging;
    if (messaging == null) {
      fcmToken.value = null;
      return null;
    }

    try {
      final token = await messaging.getToken();
      fcmToken.value = token;
      return token;
    } catch (e) {
      debugPrint('获取 FCM Token 失败: $e');
      fcmToken.value = null;
      return null;
    }
  }

  Future<void> sendTestNotification() async {
    final token = await refreshToken();

    if (_supportsLocalNotifications && _localNotificationsReady) {
      await _showLocalNotification(
        title: '测试通知',
        body: token == null ? '本地通知已触发，可用于验证通知展示流程。' : '当前 Token 已刷新，可用于调试推送链路。',
        payload: 'test_notification',
      );
    }

    lastMessageSummary.value = token == null
        ? '已发送本地测试通知'
        : '已发送测试通知，Token 已刷新';
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? '新消息';
    final body = message.notification?.body ?? '你收到了一条新的推送消息。';

    lastMessageSummary.value = '$title：$body';

    await _showLocalNotification(
      title: title,
      body: body,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationOpen(
    RemoteMessage message, {
    bool launchedFromTerminated = false,
  }) {
    final title = message.notification?.title ?? '通知';
    final body = message.notification?.body ?? '已打开通知内容';

    lastMessageSummary.value = launchedFromTerminated
        ? '应用通过通知启动：$title'
        : '已点击通知：$title';

    if (Get.context != null) {
      Get.snackbar(
        launchedFromTerminated ? '通知启动应用' : '通知已打开',
        body,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    lastMessageSummary.value = '已点击本地通知';

    if (Get.context != null) {
      Get.snackbar(
        '通知已打开',
        '你点击了一条本地测试通知。',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_supportsLocalNotifications || !_localNotificationsReady) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'codequest_notifications',
        '学习提醒',
        channelDescription: '用于显示学习应用的推送与测试通知。',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _updatePermissionState(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        permissionStatusText.value = '已授权';
        notificationsEnabled.value = true;
        break;
      case AuthorizationStatus.provisional:
        permissionStatusText.value = '临时授权';
        notificationsEnabled.value = true;
        break;
      case AuthorizationStatus.denied:
        permissionStatusText.value = '已拒绝';
        notificationsEnabled.value = false;
        break;
      case AuthorizationStatus.notDetermined:
        permissionStatusText.value = '未申请';
        notificationsEnabled.value = false;
        break;
    }
  }
}
