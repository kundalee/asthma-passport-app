import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';

class HealthReportView extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(int) onSwitchView;

  const HealthReportView({
    super.key,
    required this.data,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final age = (data['age'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder, width: 1),
        ),
        padding: const EdgeInsets.all(12),
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
                  '近期紀錄簡報',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.reportTitle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '基本資料',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('姓名', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle)),
                      Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('年齡', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle)),
                      Text('$age 歲', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.controlStatusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                children: [
                  const Text(
                    '前一個月控制狀況',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '良好',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '填寫新計書',
                onPressed: () {},
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '查看已指派計書',
                onPressed: () => onSwitchView(0),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                border: const BorderSide(color: AppColors.inputBorder, width: 1),
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
