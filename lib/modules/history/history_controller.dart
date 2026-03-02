import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repo/speed_test_repo.dart';
import '../../model/speed_test_record.dart';
import '../../services/pdf_service.dart';

class HistoryController extends GetxController {
  final _repo = Get.find<SpeedTestRepo>();
  final _pdf = Get.find<PdfService>();

  final records = <SpeedTestRecord>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    records.value = await _repo.getAll();
    isLoading.value = false;
  }

  Future<void> deleteOne(int id) async {
    await _repo.deleteOne(id);
    await loadAll();
  }

  Future<void> clearAll() async {
    await _repo.deleteAll();
    await loadAll();
  }

  Future<void> exportAllHistoryPdf() async {
    if (records.isEmpty) {
      Get.snackbar('Empty', 'No history to export.');
      return;
    }

    final file = await _pdf.exportAll(records.toList()); // ✅ snapshot
    await Share.shareXFiles([XFile(file.path)], text: 'Speed Test History PDF');
  }
}