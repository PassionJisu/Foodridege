import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _contentController = TextEditingController();
  ReportType _selectedType = ReportType.inconvenience;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().appUser;
      if (user != null) {
        context.read<ReportProvider>().fetchMyReports(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.appUser!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('신고 및 문의'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '신고하기'),
              Tab(text: '나의 신고 내역'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 신고하기 탭
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('신고 카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReportType>(
                  value: _selectedType,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ReportType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 24),
                const Text('상세 내용', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '내용을 구체적으로 적어주세요. (예: 냉장고 청결 상태, 기물 파손 등)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(user),
                    child: const Text('신고 제출하기'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '※ 관리자가 유효한 신고로 승인할 경우 1끼 무료 쿠폰이 지급됩니다.\n※ 허위 신고 시 패널티가 부여될 수 있습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            // 나의 신고 내역 탭
            reportProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reportProvider.myReports.isEmpty
                    ? const Center(child: Text('신고 내역이 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reportProvider.myReports.length,
                        itemBuilder: (context, index) {
                          final report = reportProvider.myReports[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              title: Text('[${report.type.label}] ${report.status.label}'),
                              subtitle: Text(report.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('신고 내용: ${report.content}'),
                                      const SizedBox(height: 8),
                                      if (report.adminComment != null)
                                        Text('관리자 답변: ${report.adminComment}', style: const TextStyle(color: Colors.blue)),
                                      const SizedBox(height: 12),
                                      if (report.canWithdraw)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => _handleWithdraw(report.id, user.uid),
                                            child: const Text('신고 철회하기', style: TextStyle(color: Colors.red)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(var user) async {
    if (_contentController.text.trim().isEmpty) return;

    final success = await context.read<ReportProvider>().submitReport(
          userId: user.uid,
          userName: user.name,
          type: _selectedType,
          content: _contentController.text,
        );

    if (success && mounted) {
      _contentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
      DefaultTabController.of(context).animateTo(1);
    }
  }

  void _handleWithdraw(String reportId, String userId) async {
    final success = await context.read<ReportProvider>().withdrawReport(reportId, userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신고가 철회되었습니다.')));
    }
  }
}
