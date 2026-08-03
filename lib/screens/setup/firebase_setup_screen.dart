import 'package:flutter/material.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase 설정 필요')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Firebase 프로젝트 연결이 필요합니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('1. Firebase Console에서 프로젝트 생성'),
            const Text('   https://console.firebase.google.com'),
            const SizedBox(height: 12),
            const Text('2. Authentication → 이메일/비밀번호 활성화'),
            const SizedBox(height: 12),
            const Text('3. Firestore Database 생성'),
            const SizedBox(height: 12),
            const Text('4. 터미널에서 아래 명령 실행:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SelectableText(
                'dart pub global activate flutterfire_cli\n'
                'flutterfire configure',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('5. 앱을 Hot Restart (R) 하세요'),
          ],
        ),
      ),
    );
  }
}
