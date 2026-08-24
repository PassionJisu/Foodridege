import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/foreign_shop.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_reservations_screen.dart';
import 'shop_detail_screen.dart';

/// Naver Map explore screen (Foodridge2 pattern) with Final shop dummy data.
class FoodridgeMapScreen extends StatefulWidget {
  const FoodridgeMapScreen({super.key, this.focusShopId});

  final String? focusShopId;

  @override
  State<FoodridgeMapScreen> createState() => _FoodridgeMapScreenState();
}

class _FoodridgeMapScreenState extends State<FoodridgeMapScreen> {
  NaverMapController? _controller;
  final _searchCtrl = TextEditingController();
  String _query = '';
  ForeignShop? _selected;
  bool _drawing = false;
  final Map<String, NOverlayImage> _iconCache = {};

  static const _defaultLat = 35.1595;
  static const _defaultLng = 126.8526;

  static const _markerSize = Size(
    _ShopMarker.diameter,
    _ShopMarker.diameter + _ShopMarker.tailHeight,
  );

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ForeignShop> _filtered(List<ForeignShop> shops) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return shops;
    return shops.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q) ||
          s.cuisine.toLowerCase().contains(q) ||
          (s.surplusLabel?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<NOverlayImage> _iconFor(ForeignShop shop) async {
    final cached = _iconCache[shop.id];
    if (cached != null) return cached;
    // Ensure local asset is decoded before we snapshot the marker widget.
    // Otherwise NOverlayImage may capture an empty/placeholder image.
    if (shop.photoAsset != null) {
      try {
        await precacheImage(AssetImage(shop.photoAsset!), context);
      } catch (_) {
        // ignore and fallback to marker fallback
      }
    }
    final icon = await NOverlayImage.fromWidget(
      widget: _ShopMarker(shop: shop),
      size: _markerSize,
      context: context,
    );
    _iconCache[shop.id] = icon;
    return icon;
  }

  Future<void> _drawMarkers(
    List<ForeignShop> all, {
    bool moveCamera = true,
  }) async {
    final controller = _controller;
    if (controller == null || _drawing) return;
    _drawing = true;
    try {
      final shops = _filtered(all);
      await controller.clearOverlays(type: NOverlayType.marker);
      if (shops.isEmpty) return;

      final markers = <NMarker>{};
      for (final shop in shops) {
        final marker = NMarker(
          id: shop.id,
          position: NLatLng(shop.lat, shop.lng),
          icon: await _iconFor(shop),
          size: _markerSize,
          caption: NOverlayCaption(
            text: shop.name,
            textSize: 11,
            color: AppColors.ink,
            haloColor: Colors.white,
          ),
        );
        marker.setOnTapListener((_) {
          setState(() => _selected = shop);
        });
        markers.add(marker);
      }
      await controller.addOverlayAll(markers);

      if (!moveCamera) return;
      if (shops.length == 1) {
        await controller.updateCamera(
          NCameraUpdate.withParams(
            target: NLatLng(shops.first.lat, shops.first.lng),
            zoom: 14,
          ),
        );
      } else {
        final bounds = NLatLngBounds.from(
          shops.map((s) => NLatLng(s.lat, s.lng)).toList(),
        );
        await controller.updateCamera(
          NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(56)),
        );
      }
    } finally {
      _drawing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodridgeProvider>();
    final shops = provider.shops;
    final focus = widget.focusShopId == null
        ? null
        : provider.shopById(widget.focusShopId!);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('MealPick Map'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FoodridgeReservationsScreen(),
                ),
              );
            },
            child: const Text('My bookings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: focus == null
                    ? const NLatLng(_defaultLat, _defaultLng)
                    : NLatLng(focus.lat, focus.lng),
                zoom: focus == null ? 11 : 14,
              ),
              locale: const NLocale('ko', 'KR'),
              indoorEnable: false,
              liteModeEnable: false,
              locationButtonEnable: false,
            ),
            onMapReady: (controller) async {
              _controller = controller;
              await _drawMarkers(shops, moveCamera: focus == null);
              if (focus != null) setState(() => _selected = focus);
            },
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _MapSearchBar(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() => _query = v);
                _drawMarkers(shops, moveCamera: false);
              },
              onClear: () {
                _searchCtrl.clear();
                setState(() {
                  _query = '';
                  _selected = null;
                });
                _drawMarkers(shops);
              },
              resultCount: _filtered(shops).length,
              hasQuery: _query.isNotEmpty,
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: _ShopPreviewCard(
                shop: _selected!,
                avgStars: provider.averageStars(_selected!.id),
                onClose: () => setState(() => _selected = null),
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopDetailScreen(shopId: _selected!.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopMarker extends StatelessWidget {
  const _ShopMarker({required this.shop});

  static const double diameter = 54;
  static const double tailHeight = 14;

  final ForeignShop shop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter + tailHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.sage, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: shop.photoAsset != null
                ? Image.asset(
                    shop.photoAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
          ),
          SizedBox(
            height: tailHeight,
            child: CustomPaint(
              size: const Size(16, tailHeight),
              painter: _TailPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.canvasDeep,
      alignment: Alignment.center,
      child: Text(
        shop.name.isEmpty ? '?' : shop.name.substring(0, 1),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.sage,
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.sage;
    final path = Path()
      ..moveTo(size.width / 2 - 7, 0)
      ..lineTo(size.width / 2 + 7, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.resultCount,
    required this.hasQuery,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int resultCount;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search kitchens, cuisine, or menus',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
        if (hasQuery) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: resultCount == 0 ? Colors.redAccent : AppColors.sage,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                resultCount == 0
                    ? 'No results'
                    : '$resultCount place${resultCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShopPreviewCard extends StatelessWidget {
  const _ShopPreviewCard({
    required this.shop,
    required this.avgStars,
    required this.onClose,
    required this.onOpen,
  });

  final ForeignShop shop;
  final double avgStars;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: shop.photoAsset != null
                      ? Image.asset(shop.photoAsset!, fit: BoxFit.cover)
                      : Container(color: AppColors.canvasDeep),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Color(0xFFE0A800)),
                        const SizedBox(width: 2),
                        Text(
                          avgStars > 0 ? avgStars.toStringAsFixed(1) : '—',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shop.cuisine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF8A7466),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.partnerSurplus && shop.surplusPrice != null
                          ? 'From ₩${NumberFormat('#,###').format(shop.surplusPrice)} · surplus today'
                          : shop.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.sage,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                color: const Color(0xFF8A7466),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DietMark extends StatelessWidget {
  const DietMark({super.key, required this.badge});

  final DietBadge badge;

  @override
  Widget build(BuildContext context) {
    if (badge == DietBadge.none) return const SizedBox.shrink();
    final label = switch (badge) {
      DietBadge.halal => 'HALAL',
      DietBadge.vegan => 'VEGAN',
      DietBadge.vegetarian => 'VEG',
      DietBadge.none => '',
    };
    final color = switch (badge) {
      DietBadge.halal => const Color(0xFF1B7A4A),
      DietBadge.vegan => AppColors.sage,
      DietBadge.vegetarian => const Color(0xFF7A8F4A),
      DietBadge.none => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
