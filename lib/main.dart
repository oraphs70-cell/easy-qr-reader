import 'package:flutter/material.dart';
import 'package:easy_qr_reader/screens/home_screen.dart';
import 'package:easy_qr_reader/utils/constants.dart';

void main() {
  runApp(const EasyQRReaderApp());
}

class EasyQRReaderApp extends StatelessWidget {
  const EasyQRReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '쉬운 QR 리더기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.black, // 카메라 뷰가 기본이므로 배경은 검정
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
