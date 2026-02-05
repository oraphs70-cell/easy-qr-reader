import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_qr_reader/models/scan_record.dart';
import 'package:easy_qr_reader/utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final ScanRecord record;

  const ResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('인식 결과'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 유형 아이콘 및 제목
            Center(
              child: _buildTypeHeader(record.type),
            ),
            const SizedBox(height: 30),

            // 2. 인식된 내용 표시 영역 (카드 형태)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    record.rawContent,
                    style: AppTextStyles.resultText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 3. 주요 액션 버튼
            _buildActionButtons(context),
            
            const SizedBox(height: 16),
            
            // 4. 다시 스캔하기 (보조 버튼)
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('다시 스캔하기', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeHeader(ScanType type) {
    IconData icon;
    String text;
    Color color;

    switch (type) {
      case ScanType.url:
        icon = Icons.public;
        text = "인터넷 주소";
        color = AppColors.primary;
        break;
      case ScanType.text:
      default:
        icon = Icons.text_fields;
        text = "텍스트 정보";
        color = Colors.white;
        break;
    }

    return Column(
      children: [
        Icon(icon, size: 64, color: color),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (record.type == ScanType.url) {
      return ElevatedButton.icon(
        onPressed: () => _launchURL(context, record.rawContent),
        icon: const Icon(Icons.open_in_browser, size: 32, color: Colors.black),
        label: const Text('사이트 연결하기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => _copyToClipboard(context, record.rawContent),
        icon: const Icon(Icons.copy, size: 32, color: Colors.white),
        label: const Text('내용 복사하기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionButton,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    // URL 보정 (http 없으면 추가)
    if (!urlString.startsWith('http')) {
      urlString = 'https://$urlString';
    }
    
    final Uri url = Uri.parse(urlString);
    
    try {
      // 웹에서는 platformDefault 사용
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('URL launch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사이트를 열 수 없습니다: $urlString')),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내용이 복사되었습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
