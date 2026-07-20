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
  Map<String, HistoryDay?> monthResults = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(ControlTestView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableMonths != widget.availableMonths) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final entries = await Future.wait(widget.availableMonths.map(_loadMonth));
    if (!mounted) return;
    setState(() {
      monthResults = Map.fromEntries(entries);
      isLoading = false;
    });
  }

  Future<MapEntry<String, HistoryDay?>> _loadMonth(String month) async {
    final parts = month.split('/');
    final year = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final monthNum = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (year == null || monthNum == null) {
      return MapEntry(month, null);
    }

    final result = await ApiService.getActHistory(year: year, month: monthNum);
    final days = result.success ? (result.data ?? []) : <HistoryDay>[];

    HistoryDay? completed;
    for (final day in days) {
      if (day.isCompleted && (completed == null || day.date.isAfter(completed.date))) {
        completed = day;
      }
    }
    return MapEntry(month, completed);
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
        final isCompleted = entry != null;

        return StatusContainer(
          title: '每月測驗：$monthDisplay',
          items: [
            StatusItem(label: '自我評量', status: isCompleted ? '${entry.totalScore} 分' : '未完成'),
            StatusItem(label: '量測時間', status: isCompleted ? '${entry.date.year}/${entry.date.month}/${entry.date.day}' : '無紀錄'),
          ],
          onPressed: () {},
          isComplete: isCompleted,
        );
      },
    );
  }
}
