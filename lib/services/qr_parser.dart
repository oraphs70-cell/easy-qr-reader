import 'package:easy_qr_reader/models/scan_record.dart';

class QrParser {
  static ScanRecord parse(String rawValue) {
    ScanType type = ScanType.text;

    // 간단한 URL 감지 로직 (http/https 시작 or www. 포함)
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (urlPattern.hasMatch(rawValue) || rawValue.toLowerCase().startsWith('http')) {
      type = ScanType.url;
    }
    
    // TODO: WiFi, 연락처 패턴 추가 구현 가능

    return ScanRecord(
      type: type,
      rawContent: rawValue,
      timestamp: DateTime.now(),
    );
  }
}
