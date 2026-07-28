import 'package:flutter/material.dart';
import '../../../components/status_container.dart';
import '../../../models/history_models.dart';
import '../../../services/api_service.dart';

class ControlTestView extends StatefulWidget {
  final List<String> availableMonths;

  const ControlTestView({
    super.key,
    required this.availableMonths,
  });

  @override
  State<ControlTestView> createState() => _ControlTestViewState();
}

class _ControlTestViewState extends State<ControlTestView> {
  Map<String, ActMonthSummary> monthResults = {};
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
      itemCount: widget.availableMonths.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final month = widget.availableMonths[index];
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
        );
      },
    );
  }
}
