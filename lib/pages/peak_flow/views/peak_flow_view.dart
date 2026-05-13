import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/instructions_box.dart';

class PeakFlowView extends StatelessWidget {
  final String measurementDate;
  final bool isDaytimeCompleted;
  final bool isEveningCompleted;
  final Function(int) onSwitchView;

  const PeakFlowView({
    super.key,
    required this.measurementDate,
    required this.isDaytimeCompleted,
    required this.isEveningCompleted,
    required this.onSwitchView,
  });

  String _getDaytimeStatus() {
    return isDaytimeCompleted ? '完成' : '未完成';
  }

  String _getEveningStatus() {
    return isEveningCompleted ? '完成' : '未完成';
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          _buildIconHeader(),
          const SizedBox(height: 12),
          const Text(
            '每日尖峰吐氣流量',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '量測日期：$measurementDate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.reportTitle,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          InstructionsBox(
            title: '量測說明',
            instructions: [
              '透過白天、晚上量測紀錄您的氣喘症狀',
              '根據您的紀錄，即時判定個人症狀',
              '誠實，是最好的處方',
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusFields(),
          const SizedBox(height: 12),
          CustomButton(
            text: '開始紀錄',
            onPressed: () => onSwitchView(1),
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryGreen,
            height: 37,
            borderRadius: 4,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  Widget _buildIconHeader() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGreen, width: 4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/wind.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
        ),
      ),
    );
  }

Widget _buildStatusFields() {
    final backgroundColor = (isDaytimeCompleted && isEveningCompleted)
        ? AppColors.resultGoodBg
        : AppColors.resultSevereBg;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '白天量測',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                _getDaytimeStatus(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '夜晚量測',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                _getEveningStatus(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
