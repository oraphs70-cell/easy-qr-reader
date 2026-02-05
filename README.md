# Easy QR Reader (안티그래비티 스캐너)

시니어와 디지털 입문자를 위한 **가장 쉽고 직관적인 QR코드 리더기**입니다.  
복잡한 메뉴 없이 **앱을 켜면 바로 스캔**되고, **큰 글씨**로 결과를 보여줍니다.

## ✨ 주요 기능 (Key Features)

1.  **초간편 즉시 스캔**
    *   앱 실행과 동시에 카메라가 켜져 QR코드를 인식합니다.
    *   인식이 잘 안될 땐 **화면 중앙의 큰 버튼**을 눌러 수동으로 스캔할 수 있습니다.

2.  **시니어 맞춤형 결과 화면**
    *   작은 글씨 때문에 눈살 찌푸릴 필요가 없습니다. 결과를 **시원시원한 큰 글씨**로 표시합니다.
    *   웹사이트 주소는 **[사이트 연결하기]**, 텍스트는 **[복사하기]** 버튼이 자동으로 뜹니다.

3.  **편의 도구 모음**
    *   🔦 **손전등(Flash):** 어두운 곳에서도 문제없이 스캔하세요.
    *   📳 **진동 피드백:** 스캔 성공 시 "징-" 하는 진동으로 확실하게 알려줍니다.
    *   📜 **히스토리(History):** 깜빡하고 닫아도 걱정 마세요. 지난 스캔 기록이 저장됩니다.

---

## 🚀 시작하기 (Getting Started)

### 1. 프로젝트 설정 (최초 1회)
이 프로젝트는 Flutter로 제작되었습니다. 터미널에서 다음 명령어를 순서대로 입력하세요.

```bash
# 1. 패키지 다운로드
flutter pub get

# 2. Android/iOS 네이티브 파일 생성 (필수)
flutter create .
```

### 2. 플랫폼 권한 설정
앱 실행 전, 카메라 사용을 위한 권한 설정이 필요합니다.

*   **Android:** `android/app/src/main/AndroidManifest.xml` 파일의 `<manifest>` 태그 안에 추가
    ```xml
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.FLASHLIGHT"/>
    ```

*   **iOS:** `ios/Runner/Info.plist` 파일의 `<dict>` 태그 안에 추가
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>QR 코드를 스캔하기 위해 카메라 접근 권한이 필요합니다.</string>
    ```

### 3. 앱 실행
```bash
flutter run
```

---

## ❓ 트러블슈팅 (Troubleshooting)

### Q1. 'flutter' 명령어를 찾을 수 없다고 나와요!
컴퓨터에 Flutter SDK가 설치되지 않은 경우입니다. 다음 방법으로 설치해주세요.

1.  **C드라이브로 이동:** `cd C:\`
2.  **Flutter 다운로드:** `git clone https://github.com/flutter/flutter.git -b stable`
3.  **환경 변수 등록:**
    *   윈도우 검색창 `환경 변수` 검색 -> `시스템 환경 변수 편집`
    *   `환경 변수` 버튼 -> `Path` 더블 클릭 -> `새로 만들기`
    *   `C:\flutter\bin` 입력 후 저장
4.  **재부팅:** 설정 적용을 위해 컴퓨터를 껐다 켜주세요.

### Q2. 웹(Chrome)에서 스캔이 멈추거나 안돼요.
웹 환경은 모바일과 달리 카메라 성능이나 권한 제약이 있을 수 있습니다.
*   화면 중앙 하단의 **노란색 스캔 버튼**을 누르면 카메라가 재시작되며 인식을 다시 시도합니다.
*   **새로고침(F5)** 또는 터미널에서 **Hot Restart(R키)**를 해보세요.
