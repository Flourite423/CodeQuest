import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static const String authTokenKey = 'auth_token';

  late final GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clear() async {
    await _box.erase();
  }

  Future<void> clearAuthSession() async {
    await _box.remove(authTokenKey);
  }

  bool hasKey(String key) {
    return _box.hasData(key);
  }

  String? readAuthToken() {
    return read<String>(authTokenKey);
  }
}
