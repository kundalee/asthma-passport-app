import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';

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

  String _getAssessmentDisplay() {
    return isAssessmentCompleted ? '完成' : '未完成';
  }

  String _getMeasurementTimeDisplay() {
    if (measurementTime == null || measurementTime!.isEmpty) {
      return '無紀錄';
    }
    return measurementTime!;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          _buildExamIcon(),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Text(
            '測驗月份：$measurementDate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.reportTitle,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          _buildInstructionsBox(),
          const SizedBox(height: 12),
          _buildStatusFields(),
          const SizedBox(height: 12),
          CustomButton(
            text: isAssessmentCompleted ? '查看測驗結果' : '開始紀錄',
            onPressed: () => onSwitchView(1),
            foregroundColor: Colors.white,
            backgroundColor: isAssessmentCompleted ? AppColors.completedButtonBg : AppColors.primaryGreen,
            height: 37,
            borderRadius: 4,
            padding: const EdgeInsets.all(12),
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

  Widget _buildInstructionsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.resultModerateBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.instructionsBoxBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/heart.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.resultModerateIcon, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              const Text(
                '測驗說明',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.resultModerateIcon,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionItem('透過每個月測驗紀錄您個人的氣喘症狀'),
              const SizedBox(height: 10),
              _buildInstructionItem('根據您的紀錄，即時判定個人症狀'),
              const SizedBox(height: 10),
              _buildInstructionItem('誠實，是最好的處方'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: const Center(
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFields() {
    final backgroundColor = isAssessmentCompleted ? AppColors.resultGoodBg : AppColors.resultSevereBg;

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
                '測驗狀態',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                _getAssessmentDisplay(),
                style: const TextStyle(
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
                '測驗時間',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                _getMeasurementTimeDisplay(),
                style: const TextStyle(
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
