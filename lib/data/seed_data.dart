import '../models/chingu.dart';
import '../models/foreign_shop.dart';
import '../models/vending.dart';

class SeedData {
  /// 6개 참가 대학 — 자판기 지점과 동기화.
  static const teams = [
    CulinaryTeam(
      id: 'jnu',
      name: '전남대 요리팀',
      region: '광주',
      cheers: 141,
      schoolName: '전남대학교',
      cafeteriaVenue: '전남대 학생식당',
    ),
    CulinaryTeam(
      id: 'gwu',
      name: '광주여대 조리팀',
      region: '광주',
      cheers: 128,
      schoolName: '광주여자대학교',
      cafeteriaVenue: '광주여대 학생식당',
    ),
    CulinaryTeam(
      id: 'scnu',
      name: '순천대 미식팀',
      region: '전남',
      cheers: 96,
      schoolName: '국립순천대학교',
      cafeteriaVenue: '순천대 학생식당',
    ),
    CulinaryTeam(
      id: 'gju',
      name: '광주대 요리팀',
      region: '광주',
      cheers: 110,
      schoolName: '광주대학교',
      cafeteriaVenue: '광주대 학생식당',
    ),
    CulinaryTeam(
      id: 'honam',
      name: '호남대 미식팀',
      region: '광주',
      cheers: 87,
      schoolName: '호남대학교',
      cafeteriaVenue: '호남대 학생식당',
    ),
    CulinaryTeam(
      id: 'chosun',
      name: '조선대 조리팀',
      region: '광주',
      cheers: 119,
      schoolName: '조선대학교',
      cafeteriaVenue: '조선대 학생식당',
    ),
  ];

  /// 2026년 9월 1일(화)~4일(금) 단일 팀 일정. 장소는 학교 식당 중복 없이 배정.
  static List<CulinaryMatch> get matches {
    // 화·수·목·금 (2026-09-01 = Tuesday)
    DateTime at(int month, int day) =>
        DateTime(2026, month, day, 14, 0);
    return [
      CulinaryMatch(
        id: 'ev-0',
        roundLabel: '9월 1일 (화)',
        teamId: 'jnu',
        menu: '계절 한식 코스 — 광어회, 보리밥 정식, 유자 셔벗',
        venue: '전남대 학생식당',
        date: at(9, 1),
        status: MatchStatus.scheduled,
      ),
      CulinaryMatch(
        id: 'ev-1',
        roundLabel: '9월 2일 (수)',
        teamId: 'gju',
        menu: '한식 정찬 — 궁중 비빔밥, 갈비찜, 녹차 한과',
        venue: '광주대 학생식당',
        date: at(9, 2),
        status: MatchStatus.scheduled,
      ),
      CulinaryMatch(
        id: 'ev-2',
        roundLabel: '9월 3일 (목)',
        teamId: 'honam',
        menu: '퓨전 코스 — 한우 타르타르, 된장 리조토, 팥 마카롱',
        venue: '호남대 학생식당',
        date: at(9, 3),
        status: MatchStatus.scheduled,
      ),
      CulinaryMatch(
        id: 'ev-3',
        roundLabel: '9월 4일 (금)',
        teamId: 'chosun',
        menu: '전통 한식 — 삼합, 전복죽, 약과 아이스크림',
        venue: '조선대 학생식당',
        date: at(9, 4),
        status: MatchStatus.scheduled,
      ),
      // 리뷰 데모용 지난 일정
      CulinaryMatch(
        id: 'ev-past',
        roundLabel: '지난 키친',
        teamId: 'gwu',
        menu: '전통 한식 — 삼합, 전복죽',
        venue: '광주여대 학생식당',
        date: DateTime(2026, 8, 20, 14, 0),
        status: MatchStatus.completed,
      ),
    ];
  }

  static final seedReviews = [
    MatchReview(
      id: 'r1',
      matchId: 'ev-past',
      userId: 'seed-1',
      displayName: '식도락가 박**',
      stars: 5,
      comment: '갈비찜이 정말 일품이었습니다!',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    MatchReview(
      id: 'r2',
      matchId: 'ev-past',
      userId: 'seed-2',
      displayName: '미식러버 최**',
      stars: 4,
      comment: '코스 구성이 탄탄하고 플레이팅도 아름다웠습니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
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
    VendingMachine(
      id: 'vm-gju',
      name: '광주대 자판기',
      location: '광주 남구 효덕로 277 · 광주대학교',
    ),
    VendingMachine(
      id: 'vm-honam',
      name: '호남대 자판기',
      location: '광주 광산구 어등대로 417 · 호남대학교',
    ),
    VendingMachine(
      id: 'vm-chosun',
      name: '조선대 자판기',
      location: '광주 동구 필문대로 309 · 조선대학교',
    ),
  ];

  static const dishPresets = [
    DishPreset('멸치볶음', 0xFFC4783A),
    DishPreset('시금치나물', 0xFF3D8B6E),
    DishPreset('계란말이', 0xFFD4A017),
    DishPreset('콩자반', 0xFF5C4033),
    DishPreset('제육볶음', 0xFFB33A3A),
    DishPreset('깍두기', 0xFFE07A3D),
    DishPreset('고등어조림', 0xFF4A6FA5),
    DishPreset('잡채', 0xFF8B6914),
  ];

  static const shops = [
    ForeignShop(
      id: 'al-baraka',
      name: 'Baraka Kitchen',
      cuisine: 'Pakistani · Middle Eastern',
      description:
          'Halal kitchen near Chonnam National University. Not listed on Baemin or Coupang Eats.',
      address: 'Yongbong-dong, Buk-gu, Gwangju (near CNU)',
      lat: 35.1774,
      lng: 126.9072,
      badge: DietBadge.halal,
      partnerSurplus: true,
      surplusLabel: "Today's lamb biryani box",
      surplusPrice: 4500,
      photoAsset: 'assets/images/shop_biryani.png',
    ),
    ForeignShop(
      id: 'green-leaf',
      name: 'Green Leaf Table',
      cuisine: 'Plant-based cafe',
      description:
          'Certified vegan bowls near Gwangju University. Oat lattes and zero-waste packaging.',
      address: 'Hyodeok-ro, Nam-gu, Gwangju (near Gwangju Univ.)',
      lat: 35.1336,
      lng: 126.8964,
      badge: DietBadge.vegan,
      photoAsset: 'assets/images/shop_vegan.png',
    ),
    ForeignShop(
      id: 'sprout-house',
      name: 'Sprout House',
      cuisine: 'Vegetarian Korean',
      description:
          'Egg-inclusive vegetarian sets popular with Honam University students.',
      address: 'Eodeung-daero, Gwangsan-gu, Gwangju (near Honam Univ.)',
      lat: 35.1482,
      lng: 126.8015,
      badge: DietBadge.vegetarian,
      photoAsset: 'assets/images/shop_bibimbap.png',
    ),
    ForeignShop(
      id: 'warung',
      name: 'Warung Nusantara',
      cuisine: 'Indonesian',
      description:
          'Home-style nasi campur and sambal from an Indonesian owner-chef in Dong-gu.',
      address: 'Pilmun-daero, Dong-gu, Gwangju (near Chosun Univ.)',
      lat: 35.1421,
      lng: 126.9338,
      badge: DietBadge.none,
      partnerSurplus: true,
      surplusLabel: 'Nasi goreng surprise bag',
      surplusPrice: 3900,
      photoAsset: 'assets/images/shop_nasi.png',
    ),
    ForeignShop(
      id: 'samarkand',
      name: 'Samarkand House',
      cuisine: 'Uzbek · Central Asian',
      description:
          'Plov, lagman, and tandoor bread — a neighborhood table in Suncheon, Jeonnam.',
      address: 'Jungang-ro, Suncheon, Jeollanam-do',
      lat: 34.9507,
      lng: 127.4872,
      badge: DietBadge.none,
      photoAsset: 'assets/images/shop_plov.png',
    ),
    ForeignShop(
      id: 'golden-dragon',
      name: 'Mokpo Harbor Dragon',
      cuisine: 'Chinese · Shandong',
      description:
          'Family-run Chinese kitchen in Mokpo. Hand-pulled noodles and mapo tofu.',
      address: 'Haian-ro, Mokpo, Jeollanam-do',
      lat: 34.8118,
      lng: 126.3922,
      badge: DietBadge.none,
      partnerSurplus: true,
      surplusLabel: "Today's dumpling & fried rice box",
      surplusPrice: 4200,
      photoAsset: 'assets/images/shop_chinese.png',
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
    ShopReview(
      id: 'sr4',
      shopId: 'golden-dragon',
      author: 'Wei L.',
      stars: 5,
      comment: 'Tastes like home. The lunch surplus box is a fair price for students.',
      createdAt: DateTime(2026, 8, 14),
    ),
  ];
}

class DishPreset {
  const DishPreset(this.name, this.color);
  final String name;
  final int color;
}
