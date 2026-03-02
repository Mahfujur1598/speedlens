import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../data/repo/speed_test_repo.dart';
import '../../services/speed_test_service.dart';
import '../history/history_controller.dart';

class HomeController extends GetxController {
  final _repo = Get.find<SpeedTestRepo>();
  final _speedService = Get.find<SpeedTestService>();

  final isTesting = false.obs;
  final downloadMbps = 0.0.obs;
  final uploadMbps = 0.0.obs;
  final pingMs = 0.0.obs;
  final progress = 0.0.obs;
  final statusText = 'Ready'.obs;

  Future<void> startTest() async {
    // prevent double tap
    if (isTesting.value) return;

    final ok = await InternetConnection().hasInternetAccess;
    if (!ok) {
      statusText.value = 'No internet access. Please connect and try again.';
      return;
    }

    // reset UI
    downloadMbps.value = 0;
    uploadMbps.value = 0;
    pingMs.value = 0;
    progress.value = 0;
    statusText.value = 'Starting...';
    isTesting.value = true;

    try {
      await _speedService.start(
       // useFastApi: false,
       // fileSizeMb: 10,

        onStatus: (s) => statusText.value = s,

        onProgress: (p, dl, ul, ping) {
          progress.value = p;
          if (dl != null) downloadMbps.value = dl;
          if (ul != null) uploadMbps.value = ul;
          if (ping != null) pingMs.value = ping;
        },

        onCompleted: (record) async {
          pingMs.value = record.pingMs;

          await _repo.insert(record);

          if (Get.isRegistered<HistoryController>()) {
            await Get.find<HistoryController>().loadAll();
          }

          statusText.value = 'Completed & saved.';
          progress.value = 100;
        },

        onError: (msg) {
          statusText.value = msg;
        },

        onCancel: () {
          statusText.value = 'Cancelled.';
        },
      );
    } catch (e) {
      statusText.value = 'Error: $e';
    } finally {
      isTesting.value = false;
    }
  }

  Future<void> cancelTest() async {
    if (!isTesting.value) return;

    statusText.value = 'Cancelling...';
    progress.value = 0;
    isTesting.value = false;

    await _speedService.cancel();
  }
}