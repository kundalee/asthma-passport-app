import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/instructions_box.dart';
import '../../../components/status_container.dart';

class AsthmaDiaryView extends StatelessWidget {
  final String measurementDate;
  final bool isAssessmentCompleted;
  final String? measurementTime;
  final Function(int) onSwitchView;

  const AsthmaDiaryView({
    super.key,
    required this.measurementDate,
    required this.isAssessmentCompleted,
    required this.measurementTime,
    required this.onSwitchView,
  });

  String _getMeasurementTimeDisplay() {
    if (measurementTime == null || measurementTime!.isEmpty) {
      return '無紀錄';
    }
    return measurementTime!;
  }

  String _getAssessmentDisplay() {
    return isAssessmentCompleted ? '完成' : '未完成';
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          _buildDocumentIcon(),
          const SizedBox(height: 12),
          const Text(
            '每日氣喘評量',
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
              '透過 5 個問題評量和紀錄您的氣喘症狀',
              '1 分鐘的自我檢視，有效追蹤症狀變化',
              '誠實，是最好的處方',
            ],
          ),
          const SizedBox(height: 12),
          StatusContainer(
            items: [
              StatusItem(label: '自我評量', status: _getAssessmentDisplay()),
              StatusItem(label: '量測時間', status: _getMeasurementTimeDisplay()),
            ],
            isComplete: isAssessmentCompleted,
            onPressed: () => onSwitchView(1),
            withCard: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGreen, width: 4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/note.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
        ),
      ),
    );
  }


}
