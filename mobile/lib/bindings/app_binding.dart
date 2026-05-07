import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageService>(() => StorageService());
    Get.lazyPut<ApiService>(() => ApiService());
  }
}
