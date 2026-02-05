import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:easy_qr_reader/utils/constants.dart';
import 'package:easy_qr_reader/services/qr_parser.dart';
import 'package:easy_qr_reader/services/history_service.dart';
import 'package:easy_qr_reader/screens/result_screen.dart';
import 'package:easy_qr_reader/screens/history_screen.dart';
import 'package:easy_qr_reader/models/scan_record.dart'; // 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isCameraPermissionGranted = false;
  bool _isScanning = true;
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, // Web 등에서 인식률 높이기 위해 normal로 변경
    returnImage: false,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
      if (_isCameraPermissionGranted) {
        setState(() => _isScanning = true);
      }
    }
  }

  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Future.delayed(const Duration(milliseconds: 100));
      status = await Permission.camera.request();
    }
    
    if (status.isPermanentlyDenied) {
      setState(() => _isCameraPermissionGranted = false);
      if (mounted) _showPermissionDialog();
    } else {
      setState(() => _isCameraPermissionGranted = status.isGranted);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('카메라 권한 필요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: const Text(
          'QR 코드를 스캔하려면 카메라 권한이 필요합니다.\n설정에서 허용해주세요.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('설정으로 이동', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // 디버깅: 호출 빈도 확인
    // debugPrint('OnDetect: $_isScanning');
    
    if (!_isScanning) return; 

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
        final code = barcodes.first.rawValue;
        if (code != null) {
            debugPrint('Barcode found: $code');
            
            setState(() {
              _isScanning = false; // 스캔 중단
            });

            // 1. 피드백 (진동) - 웹에서는 진동 지원 안 함/에러 가능성 있음
            try {
              if (!kIsWeb && (await Vibration.hasVibrator() ?? false)) {
                Vibration.vibrate(duration: 100);
              }
            } catch (e) {
              debugPrint('Vibration error: $e');
            }

            // 2. 파싱 및 저장 (에러 핸들링 추가)
            ScanRecord? record;
            try {
              record = QrParser.parse(code);
              await HistoryService.save(record);
            } catch (e) {
               debugPrint('History save error: $e');
               // 저장이 실패해도 결과 화면은 보여주도록
               record = QrParser.parse(code); 
            }
            
            // 3. 결과 화면으로 이동
            if (mounted) {
              debugPrint('Navigating to ResultScreen...');
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ResultScreen(record: record!)),
              ).then((_) {
                debugPrint('Returned from ResultScreen');
                if (mounted) {
                  // 스캔 재개 - 웹에서 확실히 작동하도록
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      setState(() => _isScanning = true);
                      // 스캐너 명시적 재시작
                      try {
                        controller.start();
                      } catch (e) {
                        debugPrint('Scanner restart error: $e');
                      }
                    }
                  });
                }
              });
            }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      // 권한 없음 화면
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                '카메라 권한을 확인해주세요.',
                style: AppTextStyles.guideText,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text('권한 다시 확인', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          
          _buildOverlay(),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControlBar(),
          ),
          
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.history, color: Colors.white, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                tooltip: '스캔 기록',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    // CustomShape 사용 (아래 클래스 정의)
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppColors.guideLine,
          borderRadius: 20,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
          overlayColor: AppColors.overlay,
        ),
      ),
    );
  }

  Widget _buildBottomControlBar() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 갤러리 아이콘
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white, size: 32),
            onPressed: () {
              // TODO: 갤러리 구현
            },
            tooltip: '이미지 불러오기',
          ),

          // 중앙 셔터 버튼 (수동 스캔/재시작)
          InkWell(
            onTap: () {
              // 스캔 상태 강제 리셋 및 활성화
              setState(() {
                _isScanning = true;
              });
              controller.start(); // 카메라 재시작 시도
              
              // 피드백 (애니메이션 효과 대용)
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('스캔 중...'), duration: Duration(seconds: 1)),
              );
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.black, size: 36),
              ),
            ),
          ),
          
          // 플래시 아이콘
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, child) {
              final isTorchOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? AppColors.primary : Colors.white,
                  size: 32,
                ),
                onPressed: () => controller.toggleTorch(),
                tooltip: '플래시',
              );
            },
          ),
        ],
      ),
    );
  }
}

// 커스텀 오버레이 쉐이프 (검은 배경에 중앙만 뚫린 형태 + 테두리)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;
  final Color overlayColor;

  const QrScannerOverlayShape({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
    required this.overlayColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double leftOffset = (width - cutOutSize) / 2;
    final double topOffset = (height - cutOutSize) / 2;
    
    final boxRect = Rect.fromLTWH(leftOffset, topOffset, cutOutSize, cutOutSize);

    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final left = (width - cutOutSize) / 2;
    final top = (height - cutOutSize) / 2;
    final right = left + cutOutSize;
    final bottom = top + cutOutSize;

    // 1. 배경
    final backgroundPaint = Paint()..color = overlayColor;
    final cutOutRect = Rect.fromLTWH(left, top, cutOutSize, cutOutSize);
    
    final backgroundPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)));
      
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 2. 테두리
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    path.moveTo(left, top + borderLength);
    path.lineTo(left, top);
    path.lineTo(left + borderLength, top);

    path.moveTo(right - borderLength, top);
    path.lineTo(right, top);
    path.lineTo(right, top + borderLength);

    path.moveTo(right, bottom - borderLength);
    path.lineTo(right, bottom);
    path.lineTo(right - borderLength, bottom);

    path.moveTo(left + borderLength, bottom);
    path.lineTo(left, bottom);
    path.lineTo(left, bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }
  
  @override
  ShapeBorder scale(double t) => this;
}
