import 'package:flutter/material.dart';

class AppColors {
  // 시인성을 위한 고대비 색상
  static const Color primary = Color(0xFFFFD700); // 밝은 노란색 (주요 강조)
  static const Color secondary = Color(0xFFFFFFFF); // 흰색
  static const Color background = Color(0xFF000000); // 검정 (배경)
  
  static const Color overlay = Color(0x80000000); // 반투명 검정
  static const Color guideLine = Color(0xFFFFD700); // 가이드라인 색상
  
  // 버튼 색상
  static const Color actionButton = Color(0xFF4CAF50); // 녹색 (긍정적 액션)
  static const Color cancelButton = Color(0xFFEF5350); // 적색 (부정적 액션/취소)
}

class AppTextStyles {
  // 읽기 쉬운 큰 폰트 스타일
  static const TextStyle resultText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.5,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle guideText = TextStyle(
    fontSize: 18,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );
}
