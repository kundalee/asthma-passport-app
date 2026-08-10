import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../components/app_page_container.dart';
import '../../components/card_container.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_tab_bar.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import 'views/comprehensive_data_view.dart';
import 'views/asthma_diary_view.dart';
import 'views/peak_flow_view.dart';
import 'views/control_test_view.dart';

class HistoryRecordsPage extends StatefulWidget {
  final int initialTabIndex;

  const HistoryRecordsPage({super.key, this.initialTabIndex = 0});

  @override
  State<HistoryRecordsPage> createState() => _HistoryRecordsPageState();
}

class _HistoryRecordsPageState extends State<HistoryRecordsPage> {
  int selectedTabIndex = 0;
  String selectedMonth = '';
  List<String> comprehensiveMonths = [];
  List<String> diaryMonths = [];
  List<String> peakFlowMonths = [];
  List<String> actMonths = [];
  Map<String, dynamic> summaryData = {};
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;
  bool isDownloadingReport = false;

  final List<String> tabs = [
    '綜合資料',
    '氣喘日記',
    '尖峰吐氣流量',
    '氣喘控制測量',
  ];

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
    // _loadAvailableMonths() triggers the first _loadComprehensiveData() call
    // once it resolves selectedMonth, since a month is required to fetch it.
    _loadAvailableMonths();
  }

  List<String> _monthsForTab(int index) {
    final months = switch (index) {
      1 => diaryMonths,
      2 => peakFlowMonths,
      3 => actMonths,
      _ => comprehensiveMonths,
    };
    // The ACT tab manages its own rolling window and hides this dropdown,
    // so it doesn't need the current month injected here.
    if (index == 3) return months;

    final now = DateTime.now();
    final currentMonth = '${now.year}/${now.month.toString().padLeft(2, '0')}';
    return months.contains(currentMonth) ? months : [currentMonth, ...months];
  }

  Future<void> _loadAvailableMonths() async {
    try {
      final results = await Future.wait([
        ApiService.getAvailableMonths(0), // all modules
        ApiService.getAvailableMonths(1), // diary
        ApiService.getAvailableMonths(2), // pefr
        ApiService.getAvailableMonths(3), // act
      ]);

      final comprehensive = results[0].success ? (results[0].data ?? []).map((m) => m.replaceAll('-', '/')).toList() : <String>[];
      final diary = results[1].success ? (results[1].data ?? []).map((m) => m.replaceAll('-', '/')).toList() : <String>[];
      final peakFlow = results[2].success ? (results[2].data ?? []).map((m) => m.replaceAll('-', '/')).toList() : <String>[];
      final act = results[3].success ? (results[3].data ?? []).map((m) => m.replaceAll('-', '/')).toList() : <String>[];
      comprehensive.sort((a, b) => b.compareTo(a));
      diary.sort((a, b) => b.compareTo(a));
      peakFlow.sort((a, b) => b.compareTo(a));
      act.sort((a, b) => b.compareTo(a));

      var justSelectedMonth = false;
      setState(() {
        comprehensiveMonths = comprehensive;
        diaryMonths = diary;
        peakFlowMonths = peakFlow;
        actMonths = act;
        final months = _monthsForTab(selectedTabIndex);
        if (selectedMonth.isEmpty) {
          final now = DateTime.now();
          selectedMonth = months.isNotEmpty ? months.first : '${now.year}/${now.month.toString().padLeft(2, '0')}';
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
      final result = await ApiService.getDashboardSummary(selectedMonth);
      if (!mounted) return;

      if (!result.success || result.data == null) {
        setState(() => isLoading = false);
        return;
      }
      final summary = result.data!;

      // Dense one-point-per-day series (0 for days without a completed
      // entry): the chart painter indexes points by day-of-month, so a
      // sparse list misaligns the x-axis and divides by zero when there's
      // only one recorded day.
      final scoreByDay = {for (final (day, score) in summary.symptomTrend) day: score};
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final chart = [
        for (int day = 1; day <= daysInMonth; day++) {'day': day, 'score': scoreByDay[day] ?? 0},
      ];

      setState(() {
        summaryData = {
          'recordedDays': summary.days,
          'averageScore': summary.diaryAvg.round(),
          'pefrAverage': summary.pefrAvg,
          'actScore': summary.actAvg,
          'actCompleted': summary.actLatestScore != null,
          'actLatestScore': summary.actLatestScore ?? 0,
          'measurementDate': summary.actLatestDate ?? '無紀錄',
          'greenDays': summary.greenDays,
          'yellowDays': summary.yellowDays,
          'redDays': summary.redDays,
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

  Future<void> _downloadReport() async {
    setState(() => isDownloadingReport = true);
    try {
      final result = await ApiService.getSummaryDownloadUrl(selectedMonth);
      if (!mounted) return;

      if (!result.success || result.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '無法取得報告下載連結')),
        );
        return;
      }

      final response = await http.get(Uri.parse(result.data!));
      await Printing.sharePdf(bytes: response.bodyBytes, filename: 'health_summary_report.pdf');
    } finally {
      if (mounted) setState(() => isDownloadingReport = false);
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
        return const ControlTestView();
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
        return ComprehensiveDataView.buildBottomNavigation(
          onDownload: _downloadReport,
          isDownloading: isDownloadingReport,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
