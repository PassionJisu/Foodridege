import '../models/sale_request.dart';

class OrgPickupPlace {
  const OrgPickupPlace({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.isOrigin = false,
  });

  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool isOrigin;

  double distanceSq(OrgPickupPlace other) {
    final dLat = lat - other.lat;
    final dLng = lng - other.lng;
    return dLat * dLat + dLng * dLng;
  }
}

/// 광주 기관 좌표. 수거 동선 출발지는 전남대.
class OrgLocations {
  static const jnuDepot = OrgPickupPlace(
    name: '전남대학교 (출발)',
    address: '광주 북구 용봉로 77',
    lat: 35.1761,
    lng: 126.9058,
    isOrigin: true,
  );

  static const known = <String, OrgPickupPlace>{
    '광주광역시 식자재지원센터': OrgPickupPlace(
      name: '광주광역시 식자재지원센터',
      address: '광주 북구 저양로 90',
      lat: 35.1738,
      lng: 126.8784,
    ),
    '광주 농식품유통센터': OrgPickupPlace(
      name: '광주 농식품유통센터',
      address: '광주 북구 양산택지로 50',
      lat: 35.2094,
      lng: 126.8736,
    ),
    '호남대 근처 공동부엌': OrgPickupPlace(
      name: '호남대 근처 공동부엌',
      address: '광주 광산구 어등대로 417',
      lat: 35.1482,
      lng: 126.8015,
    ),
    '조선대 기숙사 식당 지원': OrgPickupPlace(
      name: '조선대 기숙사 식당 지원',
      address: '광주 동구 필문대로 309',
      lat: 35.1428,
      lng: 126.9345,
    ),
    '광주 먹거리정책': OrgPickupPlace(
      name: '광주 먹거리정책',
      address: '광주광역시 서구 내방로 111',
      lat: 35.1601,
      lng: 126.8515,
    ),
  };

  static OrgPickupPlace resolve(String orgName, {String? address}) {
    final exact = known[orgName];
    if (exact != null) return exact;
    for (final entry in known.entries) {
      if (orgName.contains(entry.key) || entry.key.contains(orgName)) {
        return entry.value;
      }
    }
    final h = orgName.hashCode;
    return OrgPickupPlace(
      name: orgName,
      address: (address != null && address.trim().isNotEmpty)
          ? address.trim()
          : '광주광역시',
      lat: 35.1761 + ((h % 80) - 40) * 0.00045,
      lng: 126.9058 + (((h ~/ 80) % 80) - 40) * 0.00055,
    );
  }

  static List<OrgPickupPlace> nearestNeighbor(
    OrgPickupPlace start,
    List<OrgPickupPlace> stops,
  ) {
    final remaining = List<OrgPickupPlace>.of(stops);
    final ordered = <OrgPickupPlace>[];
    var current = start;
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => a.distanceSq(current).compareTo(b.distanceSq(current)));
      current = remaining.removeAt(0);
      ordered.add(current);
    }
    return ordered;
  }

  /// 전남대 출발 → 신청 기관을 가까운 순으로 이은 수거 동선.
  static List<OrgPickupPlace> routeForPending(Iterable<SaleRequest> requests) {
    final unique = <String, OrgPickupPlace>{};
    for (final req in requests) {
      if (req.status != SaleRequestStatus.pending) continue;
      unique.putIfAbsent(
        req.restaurantName,
        () => OrgPickupPlace(
          name: req.restaurantName,
          address: req.pickupAddress ??
              resolve(req.restaurantName).address,
          lat: req.lat ?? resolve(req.restaurantName).lat,
          lng: req.lng ?? resolve(req.restaurantName).lng,
        ),
      );
    }
    final ordered = nearestNeighbor(jnuDepot, unique.values.toList());
    return [jnuDepot, ...ordered];
  }
}
