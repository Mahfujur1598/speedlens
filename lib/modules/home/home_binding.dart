import 'package:get/get.dart';

import '../../data/repo/speed_test_repo.dart';
import '../../services/speed_test_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies(){
    Get.put(SpeedTestRepo(), permanent: true);
    Get.put(SpeedTestService(), permanent: true);
    Get.put(HomeController(), permanent: true);
  }
}