class SpeedTestRecord {
  final int? id;
  final int ts;
  final double downloadMbps;
  final double uploadMbps;
  final double pingMs;
  final double? jitterMs;
  final String? server;
  final String? ip;

  SpeedTestRecord({
    this.id,
    required this.ts,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.pingMs,
    this.jitterMs,
    this.server,
    this.ip,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'ts': ts,
    'download_mbps': downloadMbps,
    'upload_mbps': uploadMbps,
    'ping_ms': pingMs,
    'jitter_ms': jitterMs,
    'server': server,
    'ip': ip,
  };

  static SpeedTestRecord fromMap(Map<String, Object?> m) => SpeedTestRecord(
    id: m['id'] as int?,
    ts: m['ts'] as int,
    downloadMbps: (m['download_mbps'] as num).toDouble(),
    uploadMbps: (m['upload_mbps'] as num).toDouble(),
    pingMs: (m['ping_ms'] as num).toDouble(),
    jitterMs: (m['jitter_ms'] as num?)?.toDouble(),
    server: m['server'] as String?,
    ip: m['ip'] as String?,
  );
}