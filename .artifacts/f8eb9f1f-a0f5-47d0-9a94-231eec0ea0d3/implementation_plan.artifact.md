# 잉여 식품 다중 품목 신청 기능 구현 계획

음식점 사장님이 한 번의 신청 과정에서 여러 종류의 식품(카테고리별 수량)을 동시에 등록할 수 있도록 UI와 로직을 개선합니다.

## User Review Required

> [!IMPORTANT]
> **일괄 처리 방식**: 여러 품목을 한 번에 신청하더라도, 데이터베이스(Firestore)에는 각 품목별로 개별 문서가 생성됩니다. 이는 추후 운송 기사가 품목별로 수거 여부를 체크하거나 관리자가 개별 관리하기 용이하게 하기 위함입니다.
> **UI 변경**: 기존의 즉시 신청 방식에서 "품목 추가 -> 목록 확인 -> 일괄 신청" 방식으로 사용자 경험이 변경됩니다.

## Proposed Changes

### 1. 데이터 레이어 및 프로바이더 확장

#### [MODIFY] [sale_provider.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/providers/sale_provider.dart)
- `submitMultipleSaleRequests` 메서드 추가: 여러 개의 신청 데이터를 받아 Firestore `WriteBatch`를 통해 한 번에 저장합니다.

### 2. UI 화면 고도화 (사장님 전용)

#### [MODIFY] [sale_registration_screen.dart](file:///C:/Users/nolga/OneDrive/바탕 화면/Flutter/lib/screens/provider/sale_registration_screen.dart)
- **임시 목록 관리**: 화면 내에 `List` 형태의 임시 저장소를 두어 사용자가 "추가하기" 버튼을 누를 때마다 품목을 쌓습니다.
- **품목 리스트 표시**: 추가된 품목들을 카드 형태로 리스트업하고, 잘못 입력한 경우 삭제할 수 있는 기능을 제공합니다.
- **일괄 신청 버튼**: 목록에 1개 이상의 품목이 있을 때만 활성화되며, 한 번의 클릭으로 모든 품목을 서버에 전송합니다.

## Verification Plan

### Manual Verification
1. 사장님 앱에서 특정 지점 선택 후 진입.
2. '반찬 5개' 추가 -> '베이커리 3개' 추가 진행.
3. 화면 하단 리스트에 두 항목이 정상적으로 나타나는지 확인.
4. 항목 삭제 버튼 작동 여부 확인.
5. '매매 신청하기' 클릭 시 두 항목이 모두 '매매 신청 내역'에 최신순으로 올라오는지 확인.
