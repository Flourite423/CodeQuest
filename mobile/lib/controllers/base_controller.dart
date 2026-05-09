import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';

enum PageState {
  initial,
  loading,
  empty,
  error,
  offline,
  authExpired,
  partialData,
}

abstract class BaseController extends GetxController {
  final Rx<PageState> pageState = PageState.initial.obs;
  final RxString stateMessage = ''.obs;
  final RxBool hasPartialData = false.obs;

  Future<void> Function()? _retryAction;

  void registerRetry(Future<void> Function() action) {
    _retryAction = action;
  }

  Future<void> retry() async {
    final action = _retryAction;
    if (action == null) {
      return;
    }

    await action();
  }

  void resetState() {
    pageState.value = PageState.initial;
    stateMessage.value = '';
    hasPartialData.value = false;
  }

  void setLoading({String message = 'Loading...'}) {
    pageState.value = PageState.loading;
    stateMessage.value = message;
    hasPartialData.value = false;
  }

  void setEmpty({String message = 'Nothing to show yet.'}) {
    pageState.value = PageState.empty;
    stateMessage.value = message;
    hasPartialData.value = false;
  }

  void setError({String message = 'Something went wrong. Please try again.'}) {
    pageState.value = PageState.error;
    stateMessage.value = message;
    hasPartialData.value = false;
  }

  void setOffline({String message = '当前处于离线状态，请检查网络后重试。'}) {
    pageState.value = PageState.offline;
    stateMessage.value = message;
    hasPartialData.value = false;
  }

  Future<void> setAuthExpired({
    String message = '登录状态已失效，请重新登录。',
  }) async {
    pageState.value = PageState.authExpired;
    stateMessage.value = message;
    hasPartialData.value = false;
    await handleUnauthorized(message: message);
  }

  void setPartialData({
    String message = '当前仅显示本地缓存内容，部分信息可能不是最新。',
  }) {
    pageState.value = PageState.partialData;
    stateMessage.value = message;
    hasPartialData.value = true;
  }

  static Future<void> handleUnauthorized({
    String message = '登录状态已失效，请重新登录。',
  }) async {
    final storage = Get.isRegistered<StorageService>()
        ? Get.find<StorageService>()
        : null;
    await storage?.clearAuthSession();

    if (Get.context != null) {
      Get.snackbar(
        '登录已过期',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }

    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
    }
  }
}
