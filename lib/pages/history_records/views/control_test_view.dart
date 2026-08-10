import 'package:flutter/material.dart';
import '../../../components/status_container.dart';
import '../../../models/history_models.dart';
import '../../../services/api_service.dart';

class ControlTestView extends StatefulWidget {
  const ControlTestView({super.key});

  @override
  State<ControlTestView> createState() => _ControlTestViewState();
}

class _ControlTestViewState extends State<ControlTestView> {
  Map<String, ActMonthSummary> monthResults = {};
  List<String> displayMonths = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // /act/history returns a rolling window of several months regardless of
  // the requested target_date, so one call covers every month this view
  // needs - no more per-month fetching.
  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final now = DateTime.now();
    final targetDate = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await ApiService.getActHistory(targetDate);
    if (!mounted) return;

    final months = result.success ? (result.data ?? []) : <ActMonthSummary>[];
    setState(() {
      monthResults = {for (final m in months) m.month.replaceAll('-', '/'): m};
      final currentMonth = '${now.year}/${now.month.toString().padLeft(2, '0')}';
      // Always show the last 6 months, even ones with no record, rather
      // than only the months /act/history happened to return data for -
      // except the current month, which is omitted until it has one.
      displayMonths = List.generate(6, (i) {
        final date = DateTime(now.year, now.month - i);
        return '${date.year}/${date.month.toString().padLeft(2, '0')}';
      }).where((m) => m != currentMonth || (monthResults[m]?.isCompleted ?? false)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayMonths.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final month = displayMonths[index];
        final monthParts = month.split('/');
        final monthDisplay = monthParts.length == 2 ? '${monthParts[1]}月' : month;
        final entry = monthResults[month];
        final isCompleted = entry?.isCompleted ?? false;
        final recordDate = entry?.recordDate;

        return StatusContainer(
          title: '每月測驗：$monthDisplay',
          items: [
            StatusItem(label: '自我評量', status: isCompleted ? '${entry?.totalScore ?? 0} 分' : '未完成'),
            StatusItem(label: '量測時間', status: recordDate != null ? '${recordDate.year}/${recordDate.month}/${recordDate.day}' : '無紀錄'),
          ],
          onPressed: () {},
          isComplete: isCompleted,
          showButton: false,
        );
      },
    );
  }
}
