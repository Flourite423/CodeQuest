import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static const String authTokenKey = 'auth_token';

  GetStorage? _box;
  bool _initialized = false;

  @override
  void onInit() {
    super.onInit();
    try {
      _box = GetStorage();
      _initialized = true;
      debugPrint('StorageService: GetStorage initialized successfully');
    } catch (e) {
      // GetStorage initialization failed (e.g., headless environment)
      // Will use fallback behavior
      _initialized = false;
      debugPrint('StorageService: GetStorage initialization failed: $e');
    }
  }

  Future<void> write(String key, dynamic value) async {
    if (_initialized && _box != null) {
      await _box!.write(key, value);
    }
  }

  T? read<T>(String key) {
    if (_initialized && _box != null) {
      return _box!.read<T>(key);
    }
    return null;
  }

  Future<void> remove(String key) async {
    if (_initialized && _box != null) {
      await _box!.remove(key);
    }
  }

  Future<void> clear() async {
    if (_initialized && _box != null) {
      await _box!.erase();
    }
  }

  Future<void> clearAuthSession() async {
    await remove(authTokenKey);
  }

  bool hasKey(String key) {
    if (_initialized && _box != null) {
      return _box!.hasData(key);
    }
    return false;
  }

  String? readAuthToken() {
    return read<String>(authTokenKey);
  }
}
