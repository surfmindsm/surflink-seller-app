# 셀러셀러 (Seller Surflink)

> 인플루언서-판매사 카테고리 기반 자동매칭 중개 플랫폼

## 📱 프로젝트 소개

셀러셀러는 인플루언서와 판매사를 효율적으로 연결하는 모바일 애플리케이션입니다. 카테고리별 자동매칭, 프로필 기반 신뢰 검증, 실시간 협업 관리, 안전 결제 시스템을 통해 체계적인 인플루언서 마케팅 플랫폼을 제공합니다.

## 🎯 주요 기능

### 👥 사용자 관리
- **인플루언서**: SNS 기반 영향력 보유자
- **판매사**: 상품·캠페인 홍보를 원하는 기업/브랜드
- **관리자**: 운영, 심사, 분쟁/정산 관리

### 🔍 핵심 서비스
1. **회원가입/로그인**
   - 인플루언서/판매사 유형 선택
   - 이메일/휴대폰, SNS 연동 지원
   - 실명/사업자 인증 시스템

2. **프로필/인증**
   - 인플루언서: 포트폴리오, SNS 연동, 팔로워 수, 카테고리 관리
   - 판매사: 사업자 정보, 브랜드 관리
   - 인증 뱃지 시스템

3. **캠페인/매칭**
   - 카테고리·예산·팔로워 기반 자동매칭
   - 수동 검색 및 지원 시스템
   - 실시간 캠페인 상태 관리

4. **협업/결제**
   - 1:1 채팅 시스템
   - 전자서명 기반 계약
   - PG연동 안전결제 (에스크로)
   - 자동 정산 시스템

5. **리뷰/평가**
   - 쌍방 리뷰 시스템
   - 신고/분쟁 처리
   - 신뢰도 평가

## 🛠 기술 스택

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **UI Components**: Material Design 3

## 📦 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  go_router: ^13.2.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.0
  image_picker: ^1.0.7
  file_picker: ^8.0.0
  flutter_rating_bar: ^4.0.1
  intl: ^0.19.0
  uuid: ^4.3.3
  url_launcher: ^6.2.4
```

## 🚀 시작하기

### 필요 조건
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / VS Code
- Chrome (웹 실행용)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone [repository-url]
   cd seller_surflink
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   # 웹에서 실행
   flutter run -d chrome
   
   # Android에서 실행
   flutter run -d android
   
   # iOS에서 실행
   flutter run -d ios
   ```

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── user_model.dart
│   └── campaign_model.dart
├── providers/                # 상태 관리
│   ├── auth_provider.dart
│   └── user_provider.dart
├── screens/                  # 화면 구성
│   ├── auth/
│   ├── common/
│   ├── profile/
│   └── campaign/
├── widgets/                  # 재사용 위젯
├── services/                 # API 서비스
├── utils/                    # 유틸리티
│   └── theme.dart
└── ...
```

## 🎨 디자인 시스템

- **Primary Color**: #6C63FF (보라색)
- **Secondary Color**: #03DAC6 (청록색)
- **Background**: #F8F9FA (연한 회색)
- **Error**: #FF3333 (빨간색)
- **Typography**: Material Design 3 기반

## 📱 주요 화면

1. **스플래시 화면**: 앱 로딩 및 자동 로그인 체크
2. **로그인/회원가입**: 이메일 및 SNS 로그인 지원
3. **홈 화면**: 대시보드, 빠른 메뉴, 추천 콘텐츠
4. **프로필 화면**: 사용자 정보 관리 및 인증
5. **캠페인 목록**: 필터링 및 검색 기능
6. **채팅**: 실시간 메시징 (준비 중)

## 🔐 보안 고려사항

- 민감정보 암호화 저장
- SSL/TLS 통신
- 사용자 인증 토큰 관리
- 입력값 검증 및 필터링

## 🚧 향후 개발 계획

- [ ] 실시간 채팅 시스템
- [ ] 푸시 알림
- [ ] 결제 시스템 통합
- [ ] 관리자 백오피스
- [ ] 고급 필터링 및 추천 알고리즘
- [ ] 다국어 지원

## 📄 라이선스

This project is licensed under the MIT License.

## 👥 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**셀러셀러** - 인플루언서와 판매사를 연결하는 스마트한 매칭 플랫폼 🚀
