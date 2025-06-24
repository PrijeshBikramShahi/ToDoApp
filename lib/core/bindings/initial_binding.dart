import 'package:get/get.dart';
import 'package:to_do_app/core/services/api_service.dart';
import 'package:to_do_app/core/services/storage_service.dart';
import '../../../controllers/task_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    
    Get.lazyPut<TaskController>(
      () => TaskController(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );
  }
}