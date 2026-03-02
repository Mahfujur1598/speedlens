import 'package:get/get.dart';
import 'package:internet_speed/routes/app_routes.dart';

import '../modules/history/history_binding.dart';
import '../modules/history/history_page.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';

class AppPages
{

static final pages = <GetPage>[
  GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding()
  ),

  GetPage(
      name: AppRoutes.history,
      page: () => HistoryPage(),
    binding: HistoryBinding()
  )

];
}