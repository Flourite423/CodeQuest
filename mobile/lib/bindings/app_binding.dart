import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageService>(() => StorageService());
    Get.put(ProgressService(), permanent: true);
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<MockDataService>(() => MockDataService(), fenix: true);
    Get.put(NotificationService());
  }
}
