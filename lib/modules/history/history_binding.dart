
import 'package:get/get.dart';

import '../../services/pdf_service.dart';
import 'history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies(){
    Get.put(PdfService(), permanent: true);
    Get.put(HistoryController());
  }
}