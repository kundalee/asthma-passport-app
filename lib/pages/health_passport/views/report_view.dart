import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/passport_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';

class HealthReportView extends StatelessWidget {
  final PassportInfo info;
  final PassportPlan plan;
  final Function(int) onSwitchView;

  const HealthReportView({
    super.key,
    required this.info,
    required this.plan,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    final name = info.name;
    final age = info.age;
    final statusTitle = plan.statusTitle;

    return CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                SvgPicture.asset(
                  'assets/icons/document.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                ),
                const Text(
                  '近期紀錄簡報',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.mirage, height: 1.5),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text(
                    '基本資料',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('姓名', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71)),
                      Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('年齡', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71)),
                      Text('$age 歲', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.honeydew,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                spacing: 8,
                children: [
                  const Text(
                    '前一個月控制狀況',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71),
                  ),
                  Text(
                    statusTitle,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, height: 1.0),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '填寫新計畫',
                onPressed: () => onSwitchView(2),
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '下載報告',
                onPressed: () => {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                border: const BorderSide(color: AppColors.whiteMarble, width: 1),
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
          ],
        ),
    );
  }
}
