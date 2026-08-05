import 'package:flutter/material.dart';
import 'restaurant_list_screen.dart';

class LoungeSelectionScreen extends StatelessWidget {
  const LoungeSelectionScreen({super.key});

  final List<String> lounges = const [
    '늘찬 라운지 1호점',
    '늘찬 라운지 2호점',
    '늘찬 라운지 3호점',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지점 선택'),
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(
                lounge,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text('냉장고 현황 확인 및 예약하기'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantListScreen(branchName: lounge),
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
