import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

/// 기관 입고 신청 — 지점 선택 없이 품목만 등록 (Foodridge2 fridge supply 이식).
class OrgSupplyScreen extends StatefulWidget {
  const OrgSupplyScreen({super.key});

  @override
  State<OrgSupplyScreen> createState() => _OrgSupplyScreenState();
}

class _OrgSupplyScreenState extends State<OrgSupplyScreen> {
  String _meal = '점심';
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '5');
  final _note = TextEditingController(text: '사진 첨부(데모)');
  final _items = <_Draft>[];

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _note.dispose();
    super.dispose();
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
            '$orgName · 지점 선택 없이 바로 신청합니다.\n아침/점심/저녁 마감 1시간 전까지 접수',
            style: const TextStyle(color: Color(0xFF8A7466), height: 1.4),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _meal,
            decoration: const InputDecoration(labelText: '끼니'),
            items: const [
              DropdownMenuItem(value: '아침', child: Text('아침')),
              DropdownMenuItem(value: '점심', child: Text('점심')),
              DropdownMenuItem(value: '저녁', child: Text('저녁')),
            ],
            onChanged: (v) => setState(() => _meal = v ?? _meal),
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
                  _Draft(name: _name.text.trim(), qty: qty, note: _note.text.trim()),
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
            onPressed: _items.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_meal 입고 ${_items.length}품목 신청이 접수되었습니다. (데모)',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
            child: const Text('신청하기'),
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
