import 'dart:async';
import 'dart:io';
import '../model/speed_test_record.dart';
import 'ping_service.dart';

typedef StatusCallback = void Function(String);
typedef ProgressCallback = void Function(double percent, double? dl, double? ul, double? ping);
typedef CompletedCallback = FutureOr<void> Function(SpeedTestRecord record);
typedef ErrorCallback = void Function(String);
typedef CancelledCallback = void Function();

class SpeedTestService {
  bool _cancelRequested = false;

  Future<void> start({
    required StatusCallback onStatus,
    required ProgressCallback onProgress,
    required CompletedCallback onCompleted,
    required ErrorCallback onError,
    required CancelledCallback onCancel,
  }) async {
    try {
      _cancelRequested = false;

      // 0% -> start
      onProgress(0, null, null, null);

      // -------- Download ----------
      onStatus("Testing download...");
      final downloadMbps = await _downloadTest(
        onProgress: (p, dl) => onProgress(p, dl, null, null),
      );

      if (_cancelRequested) {
        onCancel();
        return;
      }

      // -------- Upload ----------
      onStatus("Testing upload...");
      final uploadMbps = await _uploadTest(
        onProgress: (p, ul) => onProgress(p, null, ul, null),
      );

      if (_cancelRequested) {
        onCancel();
        return;
      }

      // -------- Ping ----------
      onStatus("Measuring ping...");
      final ping = await PingService.getPing();
      onProgress(100, downloadMbps, uploadMbps, ping);

      final record = SpeedTestRecord(
        ts: DateTime.now().millisecondsSinceEpoch,
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
        pingMs: ping,
        jitterMs: null,
        server: null,
        ip: null,
      );

      onStatus("Completed");
      await onCompleted(record);
    } catch (e) {
      onError("Test failed: $e");
    }
  }

  // ---------------- Download (0 -> 50%) ----------------
  Future<double> _downloadTest({
    required void Function(double percent, double mbps) onProgress,
  }) async {

    final url = Uri.parse(
      "https://speed.cloudflare.com/__down?bytes=20000000",
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    final request = await client.getUrl(url);
    final response = await request.close();

    int totalBytes = 0;
    final sw = Stopwatch()..start();

    await for (final chunk in response) {
      totalBytes += chunk.length;
      if (_cancelRequested) break;
    }

    sw.stop();
    client.close(force: true);

    final seconds = sw.elapsedMilliseconds / 1000.0;
    if (seconds <= 0) return 0.0;

    final mbps = (totalBytes * 8) / (seconds * 1000000);

    // finish download phase at 50%
    onProgress(50, mbps);
    return mbps;
  }

  // ---------------- Upload (50 -> 100%) ----------------
  Future<double> _uploadTest({
    required void Function(double percent, double mbps) onProgress,
  }) async {
    // fallback endpoints (practice only)
    final endpoints = <Uri>[
      Uri.parse("https://postman-echo.com/post"),
      Uri.parse("https://httpbin.org/post"),
    ];

    // 1MB payload for practice (কম রাখলে fail কম হবে)
    final data = List<int>.filled(1 * 1024 * 1024, 7);

    for (final url in endpoints) {
      if (_cancelRequested) return 0.0;

      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);

        final request = await client.postUrl(url);
        request.headers.set(HttpHeaders.contentTypeHeader, "application/octet-stream");
        request.headers.set(HttpHeaders.contentLengthHeader, data.length);

        final sw = Stopwatch()..start();

        request.add(data);
        final response = await request.close().timeout(const Duration(seconds: 20));
        await response.drain().timeout(const Duration(seconds: 20));

        sw.stop();
        client.close(force: true);

        final seconds = sw.elapsedMilliseconds / 1000.0;
        if (seconds <= 0) return 0.0;

        final mbps = (data.length * 8) / (seconds * 1000000);

        // finish upload phase at 100%
        onProgress(100, mbps);
        return mbps;
      } catch (_) {
        // try next endpoint
        continue;
      }
    }

    // all endpoints failed
    return 0.0;
  }

  Future<void> cancel() async {
    _cancelRequested = true;
  }
}