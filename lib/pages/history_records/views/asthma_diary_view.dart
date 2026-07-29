import 'package:flutter/material.dart';
import '../../../components/calendar_grid.dart';
import '../../../components/status_container.dart';
import '../../../models/history_models.dart';
import '../../../services/api_service.dart';

class AsthmaDiaryView extends StatefulWidget {
  final String selectedMonth;

  const AsthmaDiaryView({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<AsthmaDiaryView> createState() => _AsthmaDiaryViewState();
}

class _AsthmaDiaryViewState extends State<AsthmaDiaryView> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  List<HistoryDay> historyDays = [];
  Map<int, int> dayStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    currentMonth = DateTime.now();
    _updateCurrentMonth();
  }

  @override
  void didUpdateWidget(AsthmaDiaryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _updateCurrentMonth();
    }
  }

  void _updateCurrentMonth() {
    try {
      if (widget.selectedMonth.isEmpty) {
        setState(() {
          currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
        });
        _loadHistory();
        return;
      }

      final parts = widget.selectedMonth.split('/');
      if (parts.length == 2) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (year != null && month != null) {
          setState(() {
            currentMonth = DateTime(year, month);
          });
          _loadHistory();
          return;
        }
      }
      setState(() {
        currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      });
      _loadHistory();
    } catch (e) {
      setState(() {
        currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      });
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final result = await ApiService.getDiaryHistory(year: currentMonth.year, month: currentMonth.month);
    if (!mounted) return;
    final days = result.success ? (result.data ?? []) : <HistoryDay>[];
    setState(() {
      historyDays = days;
      dayStatus = {
        for (final day in days)
          if (!day.date.isAfter(DateTime.now())) day.date.day: (day.isCompleted ? 1 : 0),
      };
      isLoading = false;
    });
  }

  HistoryDay? get _selectedDayEntry {
    for (final day in historyDays) {
      if (day.date.year == selectedDate.year && day.date.month == selectedDate.month && day.date.day == selectedDate.day) {
        return day;
      }
    }
    return null;
  }

  bool get _isSelectedToday {
    final now = DateTime.now();
    return selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _buildCalendarSection(),
        _buildDailyMeasurementSection(),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return CalendarGrid(
      currentMonth: currentMonth,
      selectedDate: selectedDate,
      dayStatus: dayStatus,
      onDateSelected: (date) => setState(() => selectedDate = date),
    );
  }

  Widget _buildDailyMeasurementSection() {
    final entry = _selectedDayEntry;
    final isCompleted = entry?.isCompleted ?? false;
    return StatusContainer(
      title: '每日量測：${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
      items: [
        StatusItem(label: '自我評量', status: isCompleted ? '完成' : '未完成'),
        StatusItem(label: '量測時間', status: isCompleted ? '${entry!.date.year}/${entry.date.month}/${entry.date.day}' : '無紀錄'),
      ],
      onPressed: () {
        // Clear back to home first, matching how the home page itself
        // enters this route - otherwise this history view stays buried in
        // the stack under the fresh home page the diary flow ends on. That
        // also means this widget is disposed immediately, so there's no
        // point awaiting the result to refresh afterward.
        Navigator.of(context).pushNamedAndRemoveUntil('/asthma-diary', (route) => route.isFirst);
      },
      isComplete: isCompleted,
      showButton: _isSelectedToday,
    );
  }
}
