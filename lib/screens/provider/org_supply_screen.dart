import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/org_locations.dart';
import '../../models/attached_photo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vending_provider.dart';
import '../../services/org_supply_window.dart';
import '../../theme/app_theme.dart';
import '../../widgets/attached_photo_view.dart';
import '../../widgets/photo_attach_field.dart';
import 'sale_history_screen.dart';

/// 기관 수거 신청 — 품목 등록 즉시 통합 번호·대학 슬롯 배정.
class OrgSupplyScreen extends StatefulWidget {
  const OrgSupplyScreen({super.key});

  @override
  State<OrgSupplyScreen> createState() => _OrgSupplyScreenState();
}

class _OrgSupplyScreenState extends State<OrgSupplyScreen> {
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '5');
  final _note = TextEditingController();
  AttachedPhoto? _photo;
  final _items = <_Draft>[];
  bool _submitting = false;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _name.dispose();
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().appUser;
    if (user == null || _items.isEmpty) return;
    if (!OrgSupplyWindow.isOpen()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OrgSupplyWindow.statusMessage())),
      );
      setState(() {});
      return;
    }

    final vending = context.read<VendingProvider>();
    final assignments = <SlotAssignment>[];
    for (var i = 0; i < _items.length; i++) {
      final slot = vending.reserveSlot();
      if (slot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('자판기 번호가 모두 소진되었습니다. (최대 120번)')),
        );
        return;
      }
      assignments.add(slot);
    }

    setState(() => _submitting = true);
    final place = OrgLocations.resolve(
      user.displayOrgName,
      address: user.address,
    );
    final ok = await context.read<SaleProvider>().submitOrgSupplyItems(
          orgId: user.uid,
          orgName: user.displayOrgName,
          items: _items
              .map(
                (d) => (
                  name: d.name,
                  qty: d.qty,
                  note: d.note,
                  photo: d.photo,
                ),
              )
              .toList(),
          assignments: assignments,
          pickupAddress: place.address,
          lat: place.lat,
          lng: place.lng,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신청에 실패했습니다.')),
      );
      return;
    }
    final summary = assignments
        .asMap()
        .entries
        .map((e) => '${_items[e.key].name} → No. ${e.value.displayNumber} · ${e.value.machineName}')
        .join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('수거 신청 ${_items.length}품목 등록\n$summary')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const SaleHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgName =
        context.watch<AuthProvider>().appUser?.displayOrgName ?? '기관';
    final open = OrgSupplyWindow.isOpen();
    final nextNumber = context.watch<VendingProvider>().nextGlobalNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('자판기 입고 신청')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text(
              '데모 접수 강제 열기',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              OrgSupplyWindow.demoForceOpen ? 'On · 시간 제한 없이 신청 가능' : 'Off · 오전 11시~오후 3시만 접수',
            ),
            value: OrgSupplyWindow.demoForceOpen,
            activeThumbColor: AppColors.sage,
            onChanged: (value) {
              setState(() => OrgSupplyWindow.demoForceOpen = value);
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: open ? const Color(0xFFE8F3EC) : const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: open ? AppColors.sage : const Color(0xFFE0A800),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  open
                      ? (OrgSupplyWindow.demoForceOpen
                          ? '접수 중 · 데모 On'
                          : '접수 중 · 오전 11시 ~ 오후 3시')
                      : '접수 마감',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: open ? AppColors.sage : const Color(0xFFB36B00),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  OrgSupplyWindow.statusMessage(),
                  style: const TextStyle(color: Color(0xFF8A7466), height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  '$orgName · 다음 부여 번호 No. $nextNumber\n신청과 동시에 대학 자판기가 라운드로빈으로 확정됩니다.',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InputDecorator(
            decoration: InputDecoration(labelText: '끼니'),
            child: Text('점심', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            enabled: open,
            decoration: const InputDecoration(labelText: '반찬/음식 이름'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _qty,
            enabled: open,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '수량 (200g 기준)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            enabled: open,
            decoration: const InputDecoration(labelText: '특이사항'),
          ),
          const SizedBox(height: 12),
          PhotoAttachField(
            photo: _photo,
            onChanged: open ? (value) => setState(() => _photo = value) : (_) {},
            label: '음식 사진 첨부',
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: !open
                ? null
                : () {
                    final qty = int.tryParse(_qty.text) ?? 0;
                    if (_name.text.trim().isEmpty || qty <= 0) return;
                    setState(() {
                      _items.add(
                        _Draft(
                          name: _name.text.trim(),
                          qty: qty,
                          note: _note.text.trim(),
                          photo: _photo,
                        ),
                      );
                      _name.clear();
                      _photo = null;
                    });
                  },
            child: const Text('품목 추가'),
          ),
          const SizedBox(height: 12),
          ..._items.map(
            (d) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: d.photo != null && d.photo!.hasImage
                  ? SizedBox(
                      width: 48,
                      height: 48,
                      child: AttachedPhotoView(
                        photo: d.photo!,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  : const Icon(Icons.image_outlined),
              title: Text('${d.name} · ${d.qty}개'),
              subtitle: d.note.isEmpty ? null : Text(d.note),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _items.remove(d)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
            onPressed: !open || _items.isEmpty || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('수거 신청하기'),
          ),
        ],
      ),
    );
  }
}

class _Draft {
  _Draft({
    required this.name,
    required this.qty,
    required this.note,
    this.photo,
  });
  final String name;
  final int qty;
  final String note;
  final AttachedPhoto? photo;
}
