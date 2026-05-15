import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/instructions_box.dart';
import '../../../components/status_container.dart';

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

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        spacing: 12,
        children: [
          _buildIconHeader(),
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
          Text(
            '量測日期：$measurementDate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.mirage,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          InstructionsBox(
            title: '量測說明',
            instructions: [
              '透過白天、晚上量測紀錄您的氣喘症狀',
              '根據您的紀錄，即時判定個人症狀',
              '誠實，是最好的處方',
            ],
          ),
          StatusContainer(
            items: [
              StatusItem(label: '白天量測', status: isDaytimeCompleted ? '完成' : '未完成'),
              StatusItem(label: '夜晚量測', status: isEveningCompleted ? '完成' : '未完成'),
            ],
            isComplete: isDaytimeCompleted && isEveningCompleted,
            onPressed: () => onSwitchView(1),
            withCard: false,
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
        border: Border.all(color: AppColors.funGreen, width: 4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/wind.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
        ),
      ),
    );
  }

}
