import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'card_container.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<int, int> dayStatus;
  final Function(DateTime) onDateSelected;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.dayStatus,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingDayOfWeek = firstDay.weekday % 7;

    List<Widget> dayWidgets = [];

    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    for (final day in weekdays) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      );
    }

    final prevMonthLastDay = DateTime(currentMonth.year, currentMonth.month, 0);
    final prevMonthDaysToShow = startingDayOfWeek;
    for (int i = prevMonthDaysToShow; i > 0; i--) {
      final day = prevMonthLastDay.day - i + 1;
      dayWidgets.add(
        Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Text(
                '$day',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF99A1AF),
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isSelected = selectedDate.year == date.year &&
          selectedDate.month == date.month &&
          selectedDate.day == date.day;
      final isToday = DateTime.now().day == day &&
          DateTime.now().month == currentMonth.month &&
          DateTime.now().year == currentMonth.year;

      final status = dayStatus[day];

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 0
                      ? Colors.red
                      : status == 1
                          ? AppColors.funGreen
                          : Colors.white,
                  border: isToday ? Border.all(color: Colors.black, width: 2) : isSelected ? Border.all(color: AppColors.funGreen, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: status != null ? Colors.white : Colors.black,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final totalCells = startingDayOfWeek + daysInMonth;
    final nextMonthDaysToShow = (7 - (totalCells % 7)) % 7;
    for (int day = 1; day <= nextMonthDaysToShow; day++) {
      dayWidgets.add(
        Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Text(
                '$day',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF99A1AF),
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(
            '${currentMonth.month}月',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1, letterSpacing: 0),
          ),
          GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }
}
