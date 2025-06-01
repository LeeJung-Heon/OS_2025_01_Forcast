# 개발자 가이드 (날씨 및 미세먼지 통합 앱)

이 문서는 iOS 앱 프로젝트의 개발자 또는 유지보수 담당자를 위해 작성된 기술 문서입니다. 앱은 기상청 API와 환경부 미세먼지 API를 활용하여 사용자 위치 기반 날씨와 대기 정보를 제공합니다.

## 1. 프로젝트 개요

- 주요 기능:
  - 초단기 기상 예보 및 동네 예보 제공
  - 미세먼지 정보 제공
  - 알림 기능
- 개발 언어: Swift
- 사용 프레임워크: UIKit, CoreLocation, Alamofire, ObjectMapper, UserNotifications
- 주요 외부 API:
  - 기상청 초단기예보 API (UltraSrtFcst), 동네예보 API (VilageFcst)
  - 환경부 미세먼지 시도별 실황 API

## 2. 프로젝트 디렉토리 구조

```
├── AppDelegate.swift
├── SceneDelegate.swift
├── ViewController.swift              // 메인 화면 및 전체 앱 로직
├── ResponseGetWeather.swift         // 날씨 API 응답 모델 (ObjectMapper 기반)
├── ResponseGetDust.swift            // 미세먼지 API 응답 모델
└── Resources/
    ├── Assets.xcassets
    └── LaunchScreen.storyboard
```

## 3. 주요 클래스 및 역할

### AppDelegate.swift / SceneDelegate.swift
- 앱 생명주기 관리
- 앱 실행 시 초기 설정 수행

### ViewController.swift
- 메인 UI 및 API 호출 로직 포함
- 주요 역할:
  - `setupLocationManager()`: 위치 정보 설정
  - `locationManager(_:didUpdateLocations:)`: 위치 업데이트 수신 후 날씨/미세먼지 요청
  - `fetchForecast(type:)`: 기상청 API 호출
  - `fetchDust()`: 미세먼지 API 호출
  - `updateUI()`: 데이터 기반 화면 갱신
  - `scheduleUltraTimer()`: 초단기예보 자동 갱신 타이머
  - `scheduleNotification()`: 알림 설정
  - `refreshButtonTapped()`: 수동 새로고침 버튼 처리

### ResponseGetWeather.swift
- 기상청 API 응답 JSON 구조를 모델링한 클래스
- ObjectMapper의 `Mappable`을 채택하여 자동 매핑
- `item.category` 기준으로 필요한 데이터를 구분 (T1H, PTY, SKY, WSD 등)

### ResponseGetDust.swift
- 환경부 미세먼지 API의 응답 구조 정의
- `item.pm10Value`, `item.pm10Grade` 등을 사용해 미세먼지 수치 및 등급 파악

## 4. API 호출 흐름

### 4.1 날씨 API
- `fetchForecast(type:)` 함수 호출
- `ultraSrtFcst` 또는 `vilageFcst` 타입에 따라 URL 분기
- `Alamofire`로 GET 요청 → `ObjectMapper`로 응답 파싱
- `category`를 기반으로 필요한 값 필터링 후 UI 반영

### 4.2 미세먼지 API
- `fetchDust()` 함수 내에서 시도명 기반 요청 URL 생성
- `currentSidoName` 값이 존재하지 않으면 요청 실패 (이 시점 주의)
- 응답 JSON 파싱 후 `item.pm10Value`, `item.pm10Grade`를 기반으로 UI에 표시

## 5. 위치 기반 처리

- `CLLocationManager` 사용
- 위치 업데이트 시 위도, 경도를 격자 좌표로 변환 (`convertGPStoGRID`)
- 변환된 x, y 좌표는 기상청 API 요청에 사용됨

## 6. 알림 처리

- `UNUserNotificationCenter`을 통해 알림 권한 요청 및 스케줄링
- 날씨 예보와 미세먼지 상태를 일정 간격 또는 조건에 따라 사용자에게 전달
- 앱 실행 후 일정 지연 시 알림을 예약하도록 구현됨

## 7. UI 구성 요소

- Storyboard 기반
- UILabel, UIImageView 등을 통해 기상 예보 및 미세먼지 정보를 카드처럼 표시
- 각 시간대(1~5시간 후)의 정보를 나누어 표시하며, 각 항목은 명시적인 IBOutlet으로 연결됨

## 8. 오류 및 예외 처리 포인트

- 시도 이름(`currentSidoName`)이 API 요청 전에 nil일 수 있음 → URL 생성 실패
- 위치 권한이 거부되면 위치 관련 기능 작동 안함 → 안내 문구 출력 필요
- 알림 권한이 거부되면 스케줄링 무효 → 별도 안내 필요

## 9. 사용된 주요 외부 라이브러리

- **Alamofire**: 네트워크 요청
- **ObjectMapper**: JSON 응답 자동 매핑
- **CoreLocation**: 위치 정보
- **UserNotifications**: 알림 처리

## 10. 향후 개선 방향

- 에러 처리 강화: 네트워크 실패, 파싱 실패 등에 대한 예외 처리 추가
- UI 개선: 날씨 아이콘 및 예보 시각화 향상
- 알림 설정 사용자 커스터마이징 추가
- 다국어 지원, 다크 모드 대응

---

이 문서는 프로젝트 유지보수를 위한 개발자 가이드입니다. 수정이 필요한 부분이나 궁금한 사항은 문의부탁드립니다.

