import 'package:flutter/material.dart';
import 'sale_registration_screen.dart';

class LoungeSelectionForSaleScreen extends StatelessWidget {
  const LoungeSelectionForSaleScreen({super.key});

  final List<String> lounges = const [
    '전남대 자판기',
    '광주여대 자판기',
    '광주대 자판기',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수거 지점 선택'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: lounges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lounge = lounges[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                child: const Icon(Icons.location_on, color: Colors.orange),
              ),
              title: Text(
                lounge,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text('잔반 · B급 농산물 보충분 수거 신청'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaleRegistrationScreen(branchName: lounge),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
