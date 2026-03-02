import 'dart:io';
import 'dart:math';

class PingService {
  static Future<double> getPing({int samples = 6}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..idleTimeout = const Duration(seconds: 5);

    final uri = Uri.parse('https://speed.cloudflare.com/cdn-cgi/trace');

    try {
      // Warm-up (DNS/TLS/connection). Ignore this result.
      await _single(client, uri);

      final times = <double>[];
      for (int i = 0; i < samples; i++) {
        final ms = await _single(client, uri);
        if (ms > 0) times.add(ms);
      }

      if (times.isEmpty) return 0.0;

      times.sort();
      // median
      return times[times.length ~/ 2];
    } catch (_) {
      return 0.0;
    } finally {
      client.close(force: true);
    }
  }

  static Future<double> _single(HttpClient client, Uri uri) async {
    final sw = Stopwatch()..start();

    // HEAD is lighter, but some endpoints behave better with GET.
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

    final res = await req.close();
    await res.drain(); // ensure fully read
    sw.stop();

    return sw.elapsedMilliseconds.toDouble();
  }
}