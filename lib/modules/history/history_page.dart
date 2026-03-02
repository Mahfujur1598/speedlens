import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_controller.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: controller.exportAllHistoryPdf,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export All PDF',
          ),
          IconButton(
            onPressed: controller.clearAll,
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.records.isEmpty) {
          return const Center(child: Text('No history yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final r = controller.records[i];
            final dt = DateTime.fromMillisecondsSinceEpoch(r.ts).toLocal();

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dt.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('DL: ${r.downloadMbps.toStringAsFixed(2)} Mbps')),
                      Expanded(child: Text('UL: ${r.uploadMbps.toStringAsFixed(2)} Mbps')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Text('Ping: ${r.pingMs.toStringAsFixed(1)} ms')),
                      IconButton(
                        onPressed: () => controller.deleteOne(r.id!),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}