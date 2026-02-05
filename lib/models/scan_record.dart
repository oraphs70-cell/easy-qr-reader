import 'package:uuid/uuid.dart';

enum ScanType {
  url,
  text,
  wifi,
  contact,
}

class ScanRecord {
  final String id;
  final ScanType type;
  final String rawContent;
  final DateTime timestamp;

  ScanRecord({
    String? id,
    required this.type,
    required this.rawContent,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  // JSON 직렬화/역직렬화 (추후 저장소 기능을 위해 미리 준비)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'rawContent': rawContent,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'],
      type: ScanType.values.firstWhere((e) => e.toString() == json['type']),
      rawContent: json['rawContent'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
