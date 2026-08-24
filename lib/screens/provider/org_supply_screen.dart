import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../theme/app_theme.dart';
import 'sale_history_screen.dart';

/// 기관 입고 신청 — 지점 선택 없이 품목만 등록 → 매매 신청 내역 연결.
class OrgSupplyScreen extends StatefulWidget {
  const OrgSupplyScreen({super.key});

  @override
  State<OrgSupplyScreen> createState() => _OrgSupplyScreenState();
}

class _OrgSupplyScreenState extends State<OrgSupplyScreen> {
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '5');
  final _note = TextEditingController(text: '사진 첨부(데모)');
  final _items = <_Draft>[];
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().appUser;
    if (user == null || _items.isEmpty) return;
    setState(() => _submitting = true);
    final ok = await context.read<SaleProvider>().submitOrgSupplyItems(
          orgId: user.uid,
          orgName: user.name,
          items: _items
              .map((d) => (name: d.name, qty: d.qty, note: d.note))
              .toList(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신청에 실패했습니다.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('입고 ${_items.length}품목이 매매 신청 내역에 등록되었습니다.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const SaleHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgName = context.watch<AuthProvider>().appUser?.name ?? '기관';

    return Scaffold(
      appBar: AppBar(title: const Text('자판기 입고 신청')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '$orgName · 지점 선택 없이 바로 신청합니다.\n점심 마감 1시간 전까지 접수',
            style: const TextStyle(color: Color(0xFF8A7466), height: 1.4),
          ),
          const SizedBox(height: 16),
          const InputDecorator(
            decoration: InputDecoration(labelText: '끼니'),
            child: Text('점심', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '반찬/음식 이름'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '수량'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: '사진/검수 메모'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              final qty = int.tryParse(_qty.text) ?? 0;
              if (_name.text.trim().isEmpty || qty <= 0) return;
              setState(() {
                _items.add(
                  _Draft(
                    name: _name.text.trim(),
                    qty: qty,
                    note: _note.text.trim(),
                  ),
                );
                _name.clear();
              });
            },
            child: const Text('품목 추가'),
          ),
          const SizedBox(height: 12),
          ..._items.map(
            (d) => ListTile(
              title: Text('${d.name} · ${d.qty}개'),
              subtitle: Text(d.note),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _items.remove(d)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
            onPressed: _items.isEmpty || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('신청하기'),
          ),
        ],
      ),
    );
  }
}

class _Draft {
  _Draft({required this.name, required this.qty, required this.note});
  final String name;
  final int qty;
  final String note;
}
