import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  const HistoryRecordsPage({super.key});

  @override
  State<HistoryRecordsPage> createState() => _HistoryRecordsPageState();
}

class _HistoryRecordsPageState extends State<HistoryRecordsPage> {
  int selectedTabIndex = 0;
  String selectedMonth = '';
  List<String> availableMonths = [];
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
    _loadAvailableMonths();
    _loadHistoryData();
  }

  Future<void> _loadAvailableMonths() async {
    try {
      final months = await ApiService.getHistoryMonths();
      setState(() {
        availableMonths = months;
        if (months.isNotEmpty && selectedMonth.isEmpty) {
          selectedMonth = months.first;
        }
      });
    } catch (e) {
      // Keep empty list if API fails
    }
  }

  Future<void> _loadHistoryData() async {
    try {
      final data = await ApiService.getHistorySummary(selectedMonth);
      setState(() {
        summaryData = data;
        isLoading = false;
      });
      _loadChartData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadChartData() async {
    try {
      final data = await ApiService.getHistoryChartData(selectedMonth);
      setState(() {
        chartData = data;
      });
    } catch (e) {
      // Keep empty list if chart data fails to load
    }
  }

  void _onMonthChanged(String newMonth) {
    setState(() {
      selectedMonth = newMonth;
      isLoading = true;
    });
    _loadHistoryData();
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
          availableMonths: availableMonths,
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
              colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
            ),
            Expanded(
              child: CustomDropdown(
                value: selectedMonth,
                items: availableMonths,
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
      onTabChanged: (index) {
        setState(() {
          selectedTabIndex = index;
        });
      },
    );
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
      case 1:
        return AsthmaDiaryView.buildBottomNavigation();
      case 2:
        return PeakFlowView.buildBottomNavigation();
      case 3:
        return SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
