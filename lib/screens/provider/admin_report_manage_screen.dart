import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';

class AdminReportManageScreen extends StatefulWidget {
  const AdminReportManageScreen({super.key});

  @override
  State<AdminReportManageScreen> createState() => _AdminReportManageScreenState();
}

class _AdminReportManageScreenState extends State<AdminReportManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('신고 관리'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '대기 중'),
              Tab(text: '처리 완료'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportList(reportProvider.pendingReports, reportProvider.isLoading),
            _buildReportList(reportProvider.completedReports, reportProvider.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(List<Report> reports, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (reports.isEmpty) return const Center(child: Text('표시할 신고 내역이 없습니다.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            isThreeLine: true,
            title: Text('[${report.type.label}] ${report.userName}님'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(report.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '접수: ${DateFormat('yyyy.MM.dd HH:mm').format(report.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: _buildStatusBadge(report.status),
            onTap: () => _showProcessDialog(report),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color = Colors.grey;
    if (status == ReportStatus.accepted) color = Colors.green;
    if (status == ReportStatus.rejected) color = Colors.red;
    if (status == ReportStatus.pending) color = Colors.orange;
    if (status == ReportStatus.withdrawn) color = Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showProcessDialog(Report report) {
    final commentController = TextEditingController(text: report.adminComment);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고 처리'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('작성자: ${report.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('[${report.type.label}]'),
              const SizedBox(height: 8),
              Text('내용: ${report.content}'),
              const Divider(height: 24),
              const Text('관리자 메모 (사유)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: '처리 사유를 입력하세요'),
                maxLines: 2,
                enabled: report.status == ReportStatus.pending,
              ),
            ],
          ),
        ),
        actions: [
          if (report.status == ReportStatus.pending) ...[
            TextButton(
              onPressed: () => _handleProcess(
                report.id,
                ReportStatus.rejected,
                commentController.text,
              ),
              child: const Text('거절', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => _handleProcess(
                report.id,
                ReportStatus.accepted,
                commentController.text,
              ),
              child: const Text('수용 (보상 지급)'),
            ),
          ] else
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }

  Future<void> _handleProcess(
    String reportId,
    ReportStatus status,
    String comment,
  ) async {
    final ok = await context.read<ReportProvider>().processReport(
          reportId,
          status,
          adminComment: comment,
        );
    if (!mounted) return;
    Navigator.pop(context);
    if (ok) {
      context.read<AuthProvider>().reloadFromStore();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리가 완료되었습니다.')),
      );
    }
  }
}
