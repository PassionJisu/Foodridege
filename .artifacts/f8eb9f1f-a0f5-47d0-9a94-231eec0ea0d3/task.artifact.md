# 수거 및 입고 프로세스 구현 작업 현황

- [x] **1. 데이터 모델 및 프로바이더 확장**
    - [x] `SaleRequestStatus` 수정 (`stocked` 추가)
    - [x] `SaleProvider` 확장 (`fetchAllSaleRequests`, `updateStatus`)
    - [x] `InventoryProvider` 확장 (`addStockFromRequest`)
- [x] **2. 운송 요원용 UI 구현**
    - [x] `DriverPickupListScreen` 생성 (수거 대상 목록)
    - [x] `DriverHomeScreen` 내비게이션 연결
- [x] **3. 관리자용 UI 구현**
    - [x] `AdminStockingManageScreen` 생성 (입고 관리 목록)
    - [x] `AdminHomeScreen` 내비게이션 연결
- [x] **4. 검증 및 마무리**
    - [x] 사장님-운송-관리자 전체 흐름 테스트
    - [x] 최종 결과 보고 (Walkthrough) 작성
