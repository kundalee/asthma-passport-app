import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../components/card_container.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_tab_bar.dart';
import '../../models/history_models.dart';
import '../../models/peak_flow_models.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'views/comprehensive_data_view.dart';
import 'views/asthma_diary_view.dart';
import 'views/peak_flow_view.dart';
import 'views/control_test_view.dart';

class HistoryRecordsPage extends StatefulWidget {
  const HistoryRecordsPage({super.key});

  @override
  State<HistoryRecordsPage> createState() => _HistoryRecordsPageState();
}

class _HistoryRecordsPageState extends State<HistoryRecordsPage> {
  int selectedTabIndex = 0;
  String selectedMonth = '';
  List<String> diaryMonths = [];
  List<String> peakFlowMonths = [];
  List<String> actMonths = [];
  Map<String, dynamic> summaryData = {};
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;

  final List<String> tabs = [
    '綜合資料',
    '氣喘日記',
    '尖峰吐氣流量',
    '氣喘控制測量',
  ];

  @override
  void initState() {
    super.initState();
    // _loadAvailableMonths() triggers the first _loadComprehensiveData() call
    // once it resolves selectedMonth, since a month is required to fetch it.
    _loadAvailableMonths();
  }

  // The 綜合資料 tab isn't tied to one data type, so its dropdown offers
  // every month that has data in any category.
  List<String> get _comprehensiveMonths {
    final months = {...diaryMonths, ...peakFlowMonths, ...actMonths}.toList();
    months.sort((a, b) => b.compareTo(a));
    return months;
  }

  List<String> _monthsForTab(int index) {
    switch (index) {
      case 1:
        return diaryMonths;
      case 2:
        return peakFlowMonths;
      case 3:
        return actMonths;
      default:
        return _comprehensiveMonths;
    }
  }

  Future<void> _loadAvailableMonths() async {
    try {
      final results = await Future.wait([
        ApiService.getDiaryAvailableMonths(),
        ApiService.getPeakFlowAvailableMonths(),
        ApiService.getActAvailableMonths(),
      ]);

      final diary = results[0].success ? (results[0].data ?? []).map((m) => m.label).toList() : <String>[];
      final peakFlow = results[1].success ? (results[1].data ?? []).map((m) => m.label).toList() : <String>[];
      final act = results[2].success ? (results[2].data ?? []).map((m) => m.label).toList() : <String>[];
      diary.sort((a, b) => b.compareTo(a));
      peakFlow.sort((a, b) => b.compareTo(a));
      act.sort((a, b) => b.compareTo(a));

      var justSelectedMonth = false;
      setState(() {
        diaryMonths = diary;
        peakFlowMonths = peakFlow;
        actMonths = act;
        final months = _monthsForTab(selectedTabIndex);
        if (months.isNotEmpty && selectedMonth.isEmpty) {
          selectedMonth = months.first;
          justSelectedMonth = true;
        }
      });
      if (justSelectedMonth) {
        _loadComprehensiveData();
      }
    } catch (e) {
      // Keep empty lists if API fails
    }
  }

  Future<void> _loadComprehensiveData() async {
    final parts = selectedMonth.split('/');
    final year = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final month = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (year == null || month == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final diaryFuture = ApiService.getDiaryHistory(year: year, month: month);
      final peakFlowFuture = ApiService.getPeakFlowHistory(year: year, month: month);
      final actFuture = ApiService.getActHistory(year: year, month: month);

      final diaryResult = await diaryFuture;
      final peakFlowResult = await peakFlowFuture;
      final actResult = await actFuture;

      final completedDiaryDays = (diaryResult.success ? (diaryResult.data ?? []) : <HistoryDay>[]).where((d) => d.isCompleted).toList();
      final peakFlowDays = peakFlowResult.success ? (peakFlowResult.data ?? <PeakFlowStatus>[]) : <PeakFlowStatus>[];
      final actDays = actResult.success ? (actResult.data ?? <HistoryDay>[]) : <HistoryDay>[];

      final recordedDays = completedDiaryDays.length;
      final averageScore = completedDiaryDays.isEmpty
          ? 0
          : (completedDiaryDays.map((d) => d.totalScore).reduce((a, b) => a + b) / completedDiaryDays.length).round();

      final pefrValues = <double>[];
      int greenDays = 0, yellowDays = 0, redDays = 0;
      for (final day in peakFlowDays) {
        if (day.morning.value != null) pefrValues.add(day.morning.value!);
        if (day.night.value != null) pefrValues.add(day.night.value!);

        final statuses = [day.morning.statusColor, day.night.statusColor].whereType<int>();
        if (statuses.isEmpty) continue;
        switch (statuses.reduce((a, b) => a > b ? a : b)) {
          case 0:
            greenDays++;
          case 1:
            yellowDays++;
          default:
            redDays++;
        }
      }
      final pefrAverage = pefrValues.isEmpty ? 0 : (pefrValues.reduce((a, b) => a + b) / pefrValues.length).round();

      HistoryDay? latestAct;
      for (final day in actDays) {
        if (day.isCompleted && (latestAct == null || day.date.isAfter(latestAct.date))) {
          latestAct = day;
        }
      }

      // Dense one-point-per-day series (0 for days without a completed
      // entry): the chart painter indexes points by day-of-month, so a
      // sparse list misaligns the x-axis and divides by zero when there's
      // only one recorded day.
      final scoreByDay = {for (final d in completedDiaryDays) d.date.day: d.totalScore};
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final chart = [
        for (int day = 1; day <= daysInMonth; day++) {'day': day, 'score': scoreByDay[day] ?? 0},
      ];

      if (!mounted) return;
      setState(() {
        summaryData = {
          'recordedDays': recordedDays,
          'averageScore': averageScore,
          'pefrAverage': pefrAverage,
          'actScore': latestAct?.totalScore ?? 0,
          'actCompleted': latestAct != null,
          'measurementDate': latestAct != null
              ? '${latestAct.date.year}/${latestAct.date.month.toString().padLeft(2, '0')}/${latestAct.date.day.toString().padLeft(2, '0')}'
              : '無紀錄',
          'greenDays': greenDays,
          'yellowDays': yellowDays,
          'redDays': redDays,
          'month': month,
        };
        chartData = chart;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _onMonthChanged(String newMonth) {
    setState(() {
      selectedMonth = newMonth;
    });
    _loadComprehensiveData();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildTabButtons(),
          if (selectedTabIndex != 3)
            _buildMonthDropdown(),
          _buildTabContent(),
        ],
      ),
      bottomNavigation: _buildBottomNavigation(),
      bottomNavigationPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return ComprehensiveDataView(
          summaryData: summaryData,
          chartData: chartData,
          isLoading: isLoading,
        );
      case 1:
        return AsthmaDiaryView(
          selectedMonth: selectedMonth,
        );
      case 2:
        return PeakFlowView(
          selectedMonth: selectedMonth,
        );
      case 3:
        return ControlTestView(
          availableMonths: actMonths,
        );
      default:
        return _buildOtherTabsView();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '歷史紀錄',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return SizedBox(
      height: 54,
      child: CardContainer(
        borderRadius: 4,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          spacing: 12,
          children: [
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
            ),
            Expanded(
              child: CustomDropdown(
                value: selectedMonth,
                items: _monthsForTab(selectedTabIndex),
                placeholder: '選擇月份',
                onChanged: (newMonth) {
                  if (newMonth != null) {
                    _onMonthChanged(newMonth);
                  }
                },
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.0,
                  letterSpacing: 0,
                ),
                borderRadius: 0,
                borderWidth: 1,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return CustomTabBar(
      tabs: tabs,
      selectedTabIndex: selectedTabIndex,
      onTabChanged: _onTabChanged,
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedTabIndex = index;
    });

    final months = _monthsForTab(index);
    if (months.isNotEmpty && !months.contains(selectedMonth)) {
      _onMonthChanged(months.first);
    }
  }

  Widget _buildOtherTabsView() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteMarble, width: 1),
      ),
      child: Text(
        '${tabs[selectedTabIndex]}功能即將推出',
        style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    switch (selectedTabIndex) {
      case 0:
        return ComprehensiveDataView.buildBottomNavigation();
      default:
        return const SizedBox.shrink();
    }
  }
}
