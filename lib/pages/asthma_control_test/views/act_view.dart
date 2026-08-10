import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/instructions_box.dart';
import '../../../components/status_container.dart';

class ActView extends StatelessWidget {
  final String measurementDate;
  final bool isAssessmentCompleted;
  final String? measurementTime;
  final Function(int) onSwitchView;

  const ActView({
    super.key,
    required this.measurementDate,
    required this.isAssessmentCompleted,
    this.measurementTime,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        spacing: 12,
        children: [
          _buildExamIcon(),
          const Text(
            '每月氣喘控制測驗',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
          Text(
            '測驗月份：$measurementDate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.mirage,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          InstructionsBox(
            title: '測驗說明',
            instructions: [
              '透過每個月測驗紀錄您個人的氣喘症狀',
              '根據您的紀錄，即時判定個人症狀',
              '誠實，是最好的處方',
            ],
          ),
          StatusContainer(
            items: [
              StatusItem(label: '測驗狀態', status: isAssessmentCompleted ? '完成' : '未完成'),
              StatusItem(label: '測驗時間', status: measurementTime == null || measurementTime!.isEmpty ? '無紀錄' : measurementTime!),
            ],
            isComplete: isAssessmentCompleted,
            onPressed: () => onSwitchView(isAssessmentCompleted ? 2 : 1),
            withCard: false,
          ),
        ],
      ),
    );
  }

  Widget _buildExamIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGreen, width: 4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/exam.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
        ),
      ),
    );
  }

}
