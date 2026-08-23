import '../models/chingu.dart';
import '../models/foreign_shop.dart';
import '../models/vending.dart';

class SeedData {
  static const teams = [
    CulinaryTeam(id: 'gwu', name: '광주여대 조리팀', region: '광주', cheers: 128),
    CulinaryTeam(id: 'scnu', name: '순천대 미식팀', region: '전남', cheers: 96),
    CulinaryTeam(id: 'jnu', name: '전남대 요리팀', region: '광주', cheers: 141),
    CulinaryTeam(id: 'pcu', name: '배재대 조리팀', region: '대전', cheers: 88),
    CulinaryTeam(id: 'hyejeon', name: '혜전대 미식팀', region: '대전', cheers: 74),
    CulinaryTeam(id: 'dju', name: '대전대 셰프팀', region: '대전', cheers: 102),
  ];

  static final matches = [
    CulinaryMatch(
      id: 'prelim-a',
      roundLabel: '예선전 A조',
      homeTeamId: 'gwu',
      awayTeamId: 'jnu',
      menu: '전통 한식 — 삼합, 전복죽, 약과 아이스크림',
      venue: '광주 북구 문화복합관 2층',
      date: DateTime(2026, 8, 22, 18, 30),
      time: '18:30',
      status: MatchStatus.completed,
    ),
    CulinaryMatch(
      id: 'qf-1',
      roundLabel: '8강 1경기',
      homeTeamId: 'gwu',
      awayTeamId: 'pcu',
      menu: '한식 정찬 코스 — 궁중 비빔밥, 갈비찜, 녹차 한과',
      venue: '광주 북구 문화복합관 2층',
      date: DateTime(2026, 9, 5, 18, 30),
      time: '18:30',
      status: MatchStatus.live,
    ),
    CulinaryMatch(
      id: 'qf-2',
      roundLabel: '8강 2경기',
      homeTeamId: 'scnu',
      awayTeamId: 'hyejeon',
      menu: 'Fusion Korean Course — Hanwoo Tartare, Soybean Paste Risotto, Red Bean Macaron',
      venue: '대전 중구 평화시장 미식홀',
      date: DateTime(2026, 9, 12, 18, 30),
      time: '18:30',
      status: MatchStatus.scheduled,
    ),
    CulinaryMatch(
      id: 'qf-3',
      roundLabel: '8강 3경기',
      homeTeamId: 'jnu',
      awayTeamId: 'dju',
      menu: '계절 한식 코스 — 광어회, 보리밥 정식, 유자 셔벗',
      venue: '순천 해룡면 문화원 대강당',
      date: DateTime(2026, 9, 19, 18, 30),
      time: '18:30',
      status: MatchStatus.scheduled,
    ),
  ];

  static final seedReviews = [
    MatchReview(
      id: 'r1',
      matchId: 'prelim-a',
      userId: 'seed-1',
      displayName: '식도락가 박**',
      stars: 5,
      comment: '갈비찜이 정말 일품이었습니다. 간이 딱 맞고 고기도 부드러워서 감탄했어요!',
      createdAt: DateTime(2026, 8, 22, 21, 10),
    ),
    MatchReview(
      id: 'r2',
      matchId: 'prelim-a',
      userId: 'seed-2',
      displayName: '미식러버 최**',
      stars: 4,
      comment: '코스 구성이 탄탄하고 플레이팅도 아름다웠습니다. 소스가 조금 더 진하면 좋겠어요.',
      createdAt: DateTime(2026, 8, 22, 20, 40),
    ),
    MatchReview(
      id: 'r3',
      matchId: 'prelim-a',
      userId: 'seed-3',
      displayName: '쿡러버 이**',
      stars: 5,
      comment: '삼합 조합이 독창적이었고 약과 아이스크림은 완전 신세계였어요!',
      createdAt: DateTime(2026, 8, 22, 20, 5),
    ),
  ];

  static const machines = [
    VendingMachine(
      id: 'vm-jnu',
      name: '전남대 자판기',
      location: '광주 북구 용봉로 77 · 전남대학교 학생회관',
    ),
    VendingMachine(
      id: 'vm-gwu',
      name: '광주여대 자판기',
      location: '광주 광산구 광주여대길 201',
    ),
    VendingMachine(
      id: 'vm-scnu',
      name: '순천대 자판기',
      location: '전남 순천시 중앙로 255',
    ),
  ];

  static const dishPresets = [
    DishPreset('멸치볶음', 0xFFC4783A),
    DishPreset('시금치나물', 0xFF3D8B6E),
    DishPreset('계란말이', 0xFFD4A017),
    DishPreset('콩자반', 0xFF5C4033),
    DishPreset('제육볶음', 0xFFB33A3A),
    DishPreset('깍두기', 0xFFE07A3D),
  ];

  static const shops = [
    ForeignShop(
      id: 'al-baraka',
      name: 'Al-Baraka Kitchen',
      cuisine: 'Pakistani · Middle Eastern',
      description:
          'Halal kitchen near Chonnam National University. Not listed on Baemin or Coupang Eats.',
      address: 'Yongbong-dong, Buk-gu, Gwangju (near CNU North Gate)',
      lat: 35.1774,
      lng: 126.9072,
      badge: DietBadge.halal,
      partnerSurplus: true,
      surplusLabel: "Today's lamb biryani box",
      surplusPrice: 4500,
    ),
    ForeignShop(
      id: 'green-leaf',
      name: 'Green Leaf Table',
      cuisine: 'Plant-based cafe',
      description: 'Certified vegan bowls, oat lattes, and zero-waste packaging.',
      address: 'Yongbong-ro 146, Buk-gu, Gwangju',
      lat: 35.1751,
      lng: 126.9104,
      badge: DietBadge.vegan,
    ),
    ForeignShop(
      id: 'sprout-house',
      name: 'Sprout House',
      cuisine: 'Vegetarian Korean',
      description: 'Egg-inclusive vegetarian set meals for students around CNU.',
      address: 'Yongbong-ro 77-beon-gil, Buk-gu, Gwangju',
      lat: 35.1742,
      lng: 126.9038,
      badge: DietBadge.vegetarian,
    ),
    ForeignShop(
      id: 'warung',
      name: 'Warung Nusantara',
      cuisine: 'Indonesian',
      description: 'Home-style nasi campur and sambal from an Indonesian owner-chef.',
      address: 'Munhwa-dong, Buk-gu, Gwangju',
      lat: 35.1789,
      lng: 126.9046,
      badge: DietBadge.none,
      partnerSurplus: true,
      surplusLabel: 'Nasi goreng surprise bag',
      surplusPrice: 3900,
    ),
    ForeignShop(
      id: 'samarkand',
      name: 'Samarkand House',
      cuisine: 'Uzbek · Central Asian',
      description: 'Plov, lagman, and tandoor bread — a neighborhood table for Central Asian students.',
      address: 'Yongbong-dong 1321, Buk-gu, Gwangju',
      lat: 35.1768,
      lng: 126.9121,
      badge: DietBadge.none,
    ),
  ];

  static final shopReviews = [
    ShopReview(
      id: 'sr1',
      shopId: 'al-baraka',
      author: 'Aisha K.',
      stars: 5,
      comment: 'Finally a clearly marked halal kitchen near campus. Biryani is generous.',
      createdAt: DateTime(2026, 8, 18),
    ),
    ShopReview(
      id: 'sr2',
      shopId: 'green-leaf',
      author: 'Minji P.',
      stars: 5,
      comment: 'Vegan certification is posted at the counter. The sesame bowl is excellent.',
      createdAt: DateTime(2026, 8, 16),
    ),
    ShopReview(
      id: 'sr3',
      shopId: 'sprout-house',
      author: 'Leo S.',
      stars: 4,
      comment: 'Good vegetarian bibimbap. Eggs are optional — ask if you are vegan.',
      createdAt: DateTime(2026, 8, 12),
    ),
  ];
}

class DishPreset {
  const DishPreset(this.name, this.color);
  final String name;
  final int color;
}
