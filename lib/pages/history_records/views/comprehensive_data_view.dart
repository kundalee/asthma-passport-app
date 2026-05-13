import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
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
        children: [
          CustomButton(
            text: '下載報告',
            onPressed: () {},
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            borderRadius: 4,
            height: 37,
          ),
          const SizedBox(height: 12),
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
      children: [
        _buildSummaryView(),
        const SizedBox(height: 12),
        _buildChartSection(),
        const SizedBox(height: 12),
        _buildPefrDistributionSection(),
        const SizedBox(height: 12),
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
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/wave.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF155DFC), BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                '整體狀態',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusGrid(),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    final recordedDays = summaryData['recordedDays'] ?? 20;
    final averageScore = summaryData['averageScore'] ?? 2;
    final pefrAverage = summaryData['pefrAverage'] ?? 253;
    final actScore = summaryData['actScore'] ?? 23;

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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (context) {
              final parts = value.split(' ');
              final numValue = parts[0];
              final unit = parts.sublist(1).join(' ');
              return Row(
                children: [
                  Text(
                    numValue,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black, height: 1.0, letterSpacing: 0),
                  ),
                  const SizedBox(width: 4),
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
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/increase.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF155DFC), BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                '氣喘症狀檢測總分趨勢圖',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
    final maxValue = ((dataMaxValue / 4).ceil() * 4).toDouble();

    final yLabels = <String>[];
    for (double i = maxValue; i >= 0; i -= 4) {
      yLabels.add(i.toInt().toString());
    }

    return Column(
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
                        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.axisLabelColor, height: 1.0, letterSpacing: 0)),
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
        const SizedBox(height: 8),
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
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.axisLabelColor, height: 1.0, letterSpacing: 0),
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
          children: [
            SvgPicture.asset(
              'assets/icons/score-trend.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(Color(0xFF155DFC), BlendMode.srcIn),
            ),
            const SizedBox(width: 4),
            const Text('總分', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF155DFC), height: 1.71, letterSpacing: 0)),
          ],
        ),
      ],
    );
  }

  Widget _buildPefrDistributionSection() {
    final greenDays = 19;
    final yellowDays = 1;
    final redDays = 0;
    final totalDays = greenDays + yellowDays + redDays;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/wave.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF155DFC), BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                '本月 PEFR 區間分布',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPefrStatusRow('綠燈（穩定控制', greenDays, const Color(0xFFF0FDF4), const Color(0xFFB9F8CF), const Color(0xFF008235), const Color(0xFFB9F8CF), const Color(0xFF008236), totalDays),
          const SizedBox(height: 8),
          _buildPefrStatusRow('黃燈 (警告)', yellowDays, const Color(0xFFFEFCE8), const Color(0xFFFFDF20), const Color(0xFFA65F00), const Color(0xFFFFF085), const Color(0xFFA65F00), totalDays),
          const SizedBox(height: 8),
          _buildPefrStatusRow('紅燈 (醫療急症)', redDays, const Color(0xFFFEF2F2), const Color(0xFFFFC9C9), const Color(0xFFFF0000), const Color(0xFFFFC9C9), const Color(0xFFFF0000), totalDays),
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
          const SizedBox(height: 12),
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
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/document.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                '每月測驗：12月',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '自我評量',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                    ),
                    Text(
                      '${summaryData['actScore'] ?? 23} 分',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '量測時間',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                    ),
                    Text(
                      summaryData['measurementDate'] ?? '2025/12/03',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: '查看測驗結果',
            onPressed: () {},
            backgroundColor: AppColors.completedButtonBg,
            foregroundColor: Colors.white,
            borderRadius: 4,
            height: 37,
          ),
        ],
      ),
    );
  }
}
