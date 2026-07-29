import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/status_container.dart';
import '../../../components/line_chart_painter.dart';
import '../../../theme/app_colors.dart';

class ComprehensiveDataView extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final List<Map<String, dynamic>> chartData;
  final bool isLoading;

  const ComprehensiveDataView({
    super.key,
    required this.summaryData,
    required this.chartData,
    required this.isLoading,
  });

  static Widget buildBottomNavigation({
    required VoidCallback onDownload,
    required bool isDownloading,
  }) {
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
            text: '下載報告',
            onPressed: onDownload,
            isLoading: isDownloading,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _buildSummaryView(),
        _buildChartSection(),
        _buildPefrDistributionSection(),
        _buildMonthlyTestSection(),
      ],
    );
  }

  Widget _buildSummaryView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CardContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/wave.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
              ),
              const Text(
                '整體狀態',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          _buildStatusGrid(),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    final recordedDays = summaryData['recordedDays'] ?? 0;
    final averageScore = summaryData['averageScore'] ?? 0;
    final pefrAverage = summaryData['pefrAverage'] ?? 0;
    final actScore = summaryData['actScore'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.73,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildStatusCard('已記錄天數', '$recordedDays 天'),
        _buildStatusCard('症狀評分平均分數', '$averageScore 分'),
        _buildStatusCard('PEFR控制平均值', '$pefrAverage L/min', unitTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 2.0, letterSpacing: 0)),
        _buildStatusCard('本月氣喘控制測驗分數', '$actScore 分'),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    String value, {
    TextStyle? unitTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black, height: 1.0, letterSpacing: 0),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
          ),
          Builder(
            builder: (context) {
              final parts = value.split(' ');
              final numValue = parts[0];
              final unit = parts.sublist(1).join(' ');
              return Row(
                spacing: 4,
                children: [
                  Text(
                    numValue,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black, height: 1.0, letterSpacing: 0),
                  ),
                  Text(
                    unit,
                    style: unitTextStyle,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/increase.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
              ),
              const Text(
                '氣喘症狀檢測總分趨勢圖',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (chartData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '暫無數據',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    final dataMaxValue = chartData.fold<double>(
      0,
      (max, item) => (item['score'] ?? 0).toDouble() > max ? (item['score'] ?? 0).toDouble() : max,
    );
    final maxValue = max(4, (dataMaxValue / 4).ceil() * 4).toDouble();

    final yLabels = <String>[];
    for (double i = maxValue; i >= 0; i -= 4) {
      yLabels.add(i.toInt().toString());
    }

    return Column(
      spacing: 8,
      children: [
        SizedBox(
          height: 140,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (String label in yLabels)
                      Positioned(
                        bottom: (double.parse(label) / maxValue * 140) - 6,
                        right: 8,
                        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.sharkGray, height: 1.0, letterSpacing: 0)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CustomPaint(
                    painter: LineChartPainter(
                      dataPoints: chartData,
                      maxValue: maxValue,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxDay = chartData.last['day'] ?? 20;
              final chartWidth = constraints.maxWidth - 24 - 16;
              final spacing = chartWidth / (chartData.length - 1);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(child: Container()),
                      const SizedBox(width: 16),
                    ],
                  ),
                  ...List.generate(
                    ((maxDay) / 5).ceil(),
                    (index) {
                      final day = (index + 1) * 5;
                      final dataIndex = day - 1;
                      final xOffset = 24 + (dataIndex * spacing);

                      return Positioned(
                        left: xOffset - 15,
                        child: SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              '$day日',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.sharkGray, height: 1.0, letterSpacing: 0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            SvgPicture.asset(
              'assets/icons/score-trend.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
            ),
            const Text('總分', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.solidBlue, height: 1.71, letterSpacing: 0)),
          ],
        ),
      ],
    );
  }

  Widget _buildPefrDistributionSection() {
    final greenDays = summaryData['greenDays'] ?? 0;
    final yellowDays = summaryData['yellowDays'] ?? 0;
    final redDays = summaryData['redDays'] ?? 0;
    final totalDays = greenDays + yellowDays + redDays;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/wave.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
              ),
              const Text(
                '本月 PEFR 區間分布',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          _buildPefrStatusRow('綠燈（穩定控制', greenDays, AppColors.honeydew, AppColors.lightPastelMint, const Color(0xFF008235), AppColors.lightPastelMint, const Color(0xFF008236), totalDays),
          _buildPefrStatusRow('黃燈 (警告)', yellowDays, AppColors.secondaryYellow, AppColors.darkYellow, AppColors.windsorTan, const Color(0xFFFFF085), AppColors.windsorTan, totalDays),
          _buildPefrStatusRow('紅燈 (醫療急症)', redDays, AppColors.babysBottom, AppColors.spicyPastelPink, AppColors.digitalRed, AppColors.spicyPastelPink, AppColors.digitalRed, totalDays),
        ],
      ),
    );
  }

  Widget _buildPefrStatusRow(String label, int days, Color backgroundColor, Color borderColor, Color barForegroundColor, Color barBackgroundColor, Color badgeColor, int maxDays) {
    final progressRatio = maxDays > 0 ? days / maxDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$days 天',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, height: 1.71, letterSpacing: 0),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  color: barBackgroundColor,
                ),
                FractionallySizedBox(
                  widthFactor: progressRatio,
                  child: Container(
                    height: 12,
                    color: barForegroundColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTestSection() {
    final isComplete = summaryData['actCompleted'] ?? false;
    return StatusContainer(
      title: '每月測驗：${summaryData['month'] ?? DateTime.now().month}月',
      items: [
        StatusItem(label: '自我評量', status: isComplete ? '${summaryData['actLatestScore'] ?? 0} 分' : '未完成'),
        StatusItem(label: '量測時間', status: summaryData['measurementDate'] ?? '無紀錄'),
      ],
      isComplete: isComplete,
      onPressed: () {},
      showButton: false,
    );
  }
}
