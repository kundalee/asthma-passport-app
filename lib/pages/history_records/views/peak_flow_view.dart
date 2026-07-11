import 'package:flutter/material.dart';
import '../../../components/custom_button.dart';
import '../../../components/calendar_grid.dart';
import '../../../components/status_container.dart';
import '../../../theme/app_colors.dart';

class PeakFlowView extends StatefulWidget {
  final String selectedMonth;

  const PeakFlowView({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<PeakFlowView> createState() => _PeakFlowViewState();

  static Widget buildBottomNavigation() {
    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        spacing: 12,
        children: [
          CustomButton(
            text: '檢視前一個月資料',
            onPressed: () {},
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            borderRadius: 4,
            height: 37,
          ),
          const Text(
            '此報告僅供參考，實際治療請遵循醫師指示',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF4A5565), height: 1.71, letterSpacing: 0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PeakFlowViewState extends State<PeakFlowView> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  Map<int, int> dayStatus = {
    1: 1,
    2: 1,
    3: 1,
    4: 0,
    5: 0,
    6: 0,
    7: 1,
    8: 0,
    9: 1,
  };

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
          return;
        }
      }
      setState(() {
        currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      });
    } catch (e) {
      setState(() {
        currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      onDateSelected: (_) {},
    );
  }

  Widget _buildDailyMeasurementSection() {
    return StatusContainer(
      title: '每日量測：${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
      items: const [
        StatusItem(label: '白天量測', status: '未完成'),
        StatusItem(label: '夜晚量測', status: '未完成'),
      ],
      onPressed: () {},
      isComplete: false,
    );
  }
}
