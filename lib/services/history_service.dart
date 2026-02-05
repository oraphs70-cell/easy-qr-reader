import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_qr_reader/models/scan_record.dart';

class HistoryService {
  static const String _key = 'scan_history';

  // 저장하기
  static Future<void> save(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    // 새 기록 추가 (가장 앞에)
    history.insert(0, jsonEncode(record.toJson()));
    
    // 최대 저장 개수 제한 (예: 최근 50개만 저장)
    if (history.length > 50) {
      history.removeLast();
    }
    
    await prefs.setStringList(_key, history);
  }

  // 불러오기
  static Future<List<ScanRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    
    return history
        .map((item) => ScanRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  // 전체 삭제
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
  
  // 개별 삭제 (선택적 구현)
  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScanRecord> records = await load();
    
    records.removeWhere((item) => item.id == id);
    
    final List<String> updatedHistory = records
        .map((item) => jsonEncode(item.toJson()))
        .toList();
        
    await prefs.setStringList(_key, updatedHistory);
  }
}
