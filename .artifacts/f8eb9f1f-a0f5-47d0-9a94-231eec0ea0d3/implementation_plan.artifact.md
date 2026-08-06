# 운송 요원 및 관리자용 매매 신청 처리 기능 구현 계획

음식점 사장님이 신청한 매매 내역을 운송 요원이 수거하고, 관리자가 최종 확인하여 냉장고 재고로 등록하는 전체 프로세스를 구축합니다.

## User Review Required

> [!IMPORTANT]
> **데이터 흐름**: 사장님 신청(`pending`) → 운송 요원 수거(`collected`) → 관리자 검수 및 입고(`stocked`)의 3단계 상태 변화를 따릅니다.
> **재고 자동 등록**: 관리자가 '입고 확정'을 누르는 순간, `sale_requests`의 상태가 변경됨과 동시에 `products` 컬렉션에 실제 판매 가능한 상품으로 데이터가 생성됩니다.

## Proposed Changes

### 1. 데이터 모델 및 프로바이더 확장

#### [MODIFY] [sale_request.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/models/sale_request.dart)
- `SaleRequestStatus`에 `stocked('입고 완료')` 상태 추가.

#### [MODIFY] [sale_provider.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/providers/sale_provider.dart)
- `fetchAllSaleRequests()`: 운송/관리자용 전체 내역 조회.
- `updateSaleRequestStatus(String requestId, SaleRequestStatus status)`: 상태 변경 로직.

#### [MODIFY] [inventory_provider.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/providers/inventory_provider.dart)
- `addStockFromRequest(SaleRequest request)`: 수거된 물품을 실제 `Product` 데이터로 변환하여 저장하는 로직.

### 2. UI 화면 구현

#### [NEW] [driver_pickup_list_screen.dart] (운송 요원용)
- `pending` 상태의 신청 내역을 지점별로 나열.
- '수거 완료' 버튼을 통해 상태를 `collected`로 변경.

#### [NEW] [admin_stocking_manage_screen.dart] (관리자용)
- `collected` 상태(수거됨)의 물품 목록 표시.
- '입고 확정' 버튼 클릭 시 재고 반영 및 상태를 `stocked`로 변경.

#### [MODIFY] Home Screens 연동
- [AdminHomeScreen](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/screens/provider/admin_home_screen.dart): '판매 수량 업데이트' 메뉴에 새 화면 연결.
- [DriverHomeScreen](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/screens/provider/driver_home_screen.dart): '수거 대상 목록' 메뉴에 새 화면 연결.

## Verification Plan

### Manual Verification
1. **사장님**: 식품 1종 매매 신청 (`pending`).
2. **운송 요원**: '수거 대상 목록'에서 해당 건 확인 및 '수거 완료' 처리 (`collected`).
3. **관리자**: '판매 수량 업데이트'에서 수거된 물품 확인 및 '입고 확정' 처리 (`stocked`).
4. **확인**:
   - 청년 앱의 '음식 예약하기' 리스트에 해당 상품이 나타나는지 확인.
   - 사장님 앱의 내역에서 '입고 완료' 상태로 변했는지 확인.
