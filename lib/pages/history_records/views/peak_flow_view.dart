import 'package:flutter/material.dart';
import '../../../components/calendar_grid.dart';
import '../../../components/status_container.dart';
import '../../../models/peak_flow_models.dart';
import '../../../services/api_service.dart';

class PeakFlowView extends StatefulWidget {
  final String selectedMonth;

  const PeakFlowView({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<PeakFlowView> createState() => _PeakFlowViewState();
}

class _PeakFlowViewState extends State<PeakFlowView> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  List<PeakFlowStatus> historyDays = [];
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
  void didUpdateWidget(PeakFlowView oldWidget) {
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
    final result = await ApiService.getPeakFlowHistory(year: currentMonth.year, month: currentMonth.month);
    if (!mounted) return;
    final days = result.success ? (result.data ?? []) : <PeakFlowStatus>[];
    setState(() {
      historyDays = days;
      dayStatus = {
        for (final day in days)
          if (day.morning.isCompleted || day.night.isCompleted)
            DateTime.parse(day.date).day: (day.morning.isCompleted && day.night.isCompleted ? 1 : 0),
      };
      isLoading = false;
    });
  }

  PeakFlowStatus? get _selectedDayEntry {
    for (final day in historyDays) {
      final date = DateTime.parse(day.date);
      if (date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day) {
        return day;
      }
    }
    return null;
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
    final morning = entry?.morning;
    final night = entry?.night;
    final isCompleted = (morning?.isCompleted ?? false) && (night?.isCompleted ?? false);
    return StatusContainer(
      title: '每日量測：${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
      items: [
        StatusItem(label: '白天量測', status: morning?.isCompleted == true ? '完成' : '未完成'),
        StatusItem(label: '夜晚量測', status: night?.isCompleted == true ? '完成' : '未完成'),
      ],
      onPressed: () {},
      isComplete: isCompleted,
    );
  }
}
