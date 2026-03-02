

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Speed Test'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.history),
            icon: const Icon(Icons.history),
            tooltip: 'History',
          ),
        ],
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _statCard(
                title: 'Download',
                value: controller.downloadMbps.value.toStringAsFixed(2),
                unit: 'Mbps',
              ),
              const SizedBox(height: 12),
              _statCard(
                title: 'Upload',
                value: controller.uploadMbps.value.toStringAsFixed(2),
                unit: 'Mbps',
              ),


              const SizedBox(height: 12),
              _statCard(
                title: 'Ping',
                value: controller.pingMs.value.toStringAsFixed(1),
                unit: 'ms',
              ),


              const SizedBox(height: 12),
              _statCard(
                title: 'Progress',
                value: controller.progress.value.toStringAsFixed(0),
                unit: '%',
              ),
              const Spacer(),

              if (controller.isTesting.value) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text(controller.statusText.value),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: controller.cancelTest,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.startTest,
                    icon: const Icon(Icons.speed),
                    label: const Text('Start Test'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.statusText.value,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            '$value ',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(unit, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}