# Firebase 연결 구현 계획

현재 Flutter 프로젝트(`flutter_app`)에 Firebase를 연동하기 위한 절차입니다. 프로젝트에는 이미 `firebase_core`, `firebase_auth`, `cloud_firestore` 라이브러리가 추가되어 있으며, `main.dart`에 초기화 로직도 일부 작성되어 있습니다. 하지만 실제 Firebase 프로젝트와의 연결 설정(`firebase_options.dart`)이 비어 있는 상태입니다.

## User Review Required

> [!IMPORTANT]
> **Firebase 프로젝트 생성 필요**: Firebase 콘솔([console.firebase.google.com](https://console.firebase.google.com/))에서 프로젝트를 먼저 생성해야 합니다.
> **패키지 명 변경 권장**: 현재 Android 패키지 명이 `com.example.flutter_app`으로 설정되어 있습니다. Firebase 연결 전에 고유한 패키지 명(예: `com.itda.foodsharing`)으로 변경하는 것을 권장합니다.

## Proposed Changes

### 1. FlutterFire CLI를 통한 설정

FlutterFire CLI를 사용하여 각 플랫폼(Android, iOS, Web)에 대한 Firebase 설정을 자동으로 생성합니다.

- **작업 내용**:
    - `firebase-tools` 설치 및 로그인 확인
    - `flutterfire configure` 명령 실행을 통한 `firebase_options.dart` 업데이트 및 Firebase 앱 등록

### 2. Android 빌드 구성 업데이트

Android 플랫폼에서 Firebase 서비스(Analytics 등)가 정상 작동하도록 Gradle 설정을 추가합니다.

#### [MODIFY] [build.gradle.kts](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/android/build.gradle.kts)
- `google-services` 클래스패스 플러그인 추가

#### [MODIFY] [build.gradle.kts](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/android/app/build.gradle.kts)
- `com.google.gms.google-services` 플러그인 적용

### 3. 소스 코드 초기화 로직 보완

#### [MODIFY] [main.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/main.dart)
- `DefaultFirebaseOptions.isConfigured` 체크 로직을 실제 설정 상태에 맞게 보완하여 Firebase가 정상적으로 초기화되도록 합니다.

## Verification Plan

### Manual Verification
1. `flutter run` 명령을 통해 앱이 오류 없이 실행되는지 확인합니다.
2. 디버그 콘솔에서 "Firebase initialized" 관련 메시지나 오류가 없는지 확인합니다.
3. Firebase 콘솔의 'Project Settings'에서 Android 앱이 정상적으로 등록되었는지 확인합니다.
