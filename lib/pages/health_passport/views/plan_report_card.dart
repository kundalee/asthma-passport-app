import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';

// Usage text for relief meds, which are taken as needed rather than on a
// day/night schedule. Sent as `info` when saving a plan.
const String reliefMedicationInfo = '需要的時候使用';

class PlanMedicationDisplay {
  final String name;
  final String morn;
  final String even;
  final String? info;
  final String? note;

  const PlanMedicationDisplay({
    required this.name,
    required this.morn,
    required this.even,
    this.info,
    this.note,
  });
}

const Map<String, Color> planLevelBackgroundColors = {
  '氣喘完全控制': AppColors.secondaryGreen,
  '氣喘部分控制': AppColors.secondaryYellow,
  '氣喘控制不佳': AppColors.secondaryOrange,
  '氣喘急性發作': AppColors.secondaryRed,
};

const Map<String, Color> planLevelIconColors = {
  '氣喘完全控制': AppColors.primaryGreen,
  '氣喘部分控制': AppColors.primaryYellow,
  '氣喘控制不佳': AppColors.primaryOrange,
  '氣喘急性發作': AppColors.primaryRed,
};

const Map<String, String> planLevelIconPaths = {
  '氣喘部分控制': 'assets/icons/alert-info.svg',
  '氣喘控制不佳': 'assets/icons/alert-info.svg',
  '氣喘急性發作': 'assets/icons/emergency.svg',
};

// The 行動計畫指派報告 card shared by NewPlanView's in-progress-form preview
// and PassportPlanView's read-only view of a saved plan — same layout,
// different data sources.
class PlanReportCard extends StatelessWidget {
  final String patientName;
  final String recordDate;
  final String? statusLevel;
  final List<PlanMedicationDisplay> controlMeds;
  final List<PlanMedicationDisplay> reliefMeds;
  final String? notes;
  final String? doctorName;

  const PlanReportCard({
    super.key,
    required this.patientName,
    required this.recordDate,
    required this.statusLevel,
    required this.controlMeds,
    required this.reliefMeds,
    required this.notes,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    final levelBgColor = planLevelBackgroundColors[statusLevel] ?? AppColors.honeydew;
    final levelIconColor = planLevelIconColors[statusLevel] ?? AppColors.primaryGreen;
    final levelIconPath = planLevelIconPaths[statusLevel] ?? 'assets/icons/check.svg';
    final isAcute = statusLevel == '氣喘急性發作';

    return CardContainer(
      padding: const EdgeInsets.only(left: 11, top: 16, right: 16, bottom: 24),
      borderRadius: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              '行動計畫指派報告',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black, height: 1.0, letterSpacing: 0),
            ),
          ),
          const Divider(height: 4, thickness: 4, color: Colors.black),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Text('基本資料', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0)),
                _buildRow('病患姓名', patientName),
                _buildRow('填寫日期', recordDate),
              ],
            ),
          ),
          const Divider(height: 4, thickness: 4, color: AppColors.sweetGrey),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Text('氣喘控制狀況', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(color: levelBgColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        levelIconPath,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(levelIconColor, BlendMode.srcIn),
                      ),
                      Text(
                        statusLevel ?? '無資料',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: levelIconColor, height: 1.5, letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 4, thickness: 4, color: AppColors.sweetGrey),
          if (isAcute)
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/emergency_instruction.png', width: double.infinity, fit: BoxFit.contain),
            )
          else ...[
            _buildMedicationList('控制藥物', controlMeds),
            _buildMedicationList('緩解藥物', reliefMeds, asNeeded: true),
          ],
          const Divider(height: 4, thickness: 4, color: AppColors.sweetGrey),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Text('備註事項', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0)),
                Text(
                  notes?.isNotEmpty == true ? notes! : '無',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                ),
              ],
            ),
          ),
          const Divider(height: 4, thickness: 4, color: Colors.black),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                const Text('醫師確認：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
                Text(
                  doctorName?.isNotEmpty == true ? doctorName! : '未確認',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1,
                    letterSpacing: 0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(String title, List<PlanMedicationDisplay> medications, {bool asNeeded = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0)),
          if (medications.isEmpty)
            _buildMedicationEntry(const PlanMedicationDisplay(name: '', morn: '', even: ''), 0)
          else
            for (int i = 0; i < medications.length; i++) _buildMedicationEntry(medications[i], i, asNeeded: asNeeded),
        ],
      ),
    );
  }

  Widget _buildMedicationEntry(PlanMedicationDisplay medication, int index, {bool asNeeded = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('藥物 ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0)),
        _buildRow('藥物名稱', medication.name.isNotEmpty ? medication.name : '未指派'),
        if (medication.name.isNotEmpty && asNeeded)
          Text('＊${medication.info?.isNotEmpty == true ? medication.info : reliefMedicationInfo}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0))
        else if (medication.name.isNotEmpty) ...[
          _buildRow('- 使用劑量：白天', medication.morn.isNotEmpty ? medication.morn : '未指派'),
          _buildRow('- 使用劑量：夜晚', medication.even.isNotEmpty ? medication.even : '未指派'),
        ],
        if (medication.note?.isNotEmpty == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const Text('備註', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
              Text(medication.note!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
            ],
          ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
      ],
    );
  }
}
