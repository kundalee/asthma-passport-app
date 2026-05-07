import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';

class HealthPassportView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onLogout;
  final Function(int)? onMenuTap;

  const HealthPassportView({
    super.key,
    required this.data,
    required this.onLogout,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? '').toString();
    final dateOfBirth = (data['dateOfBirth'] ?? '').toString();
    final code = (data['code'] ?? '').toString();
    final sex = (data['sex'] ?? '').toString();
    final age = (data['age'] ?? '').toString();
    final barcode = (data['barcode'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.passportCardGradientStart,
                  AppColors.passportCardGradientEnd,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '我的健康護照',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.passportAccent,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Asthma Health Passport',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.passportAccent,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 4,
                  color: AppColors.passportAccent,
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.passportCardBgColor,
                          border: Border.all(color: AppColors.passportCardBorder, width: 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.photoBorder, width: 3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    color: AppColors.photoBackground,
                                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(flex: 60, child: _buildInfoRow('NAME / 姓名', name)),
                                              const SizedBox(width: 12),
                                              Expanded(flex: 40, child: _buildInfoRow('CODE / 代碼', code)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(flex: 60, child: _buildInfoRow('SEX / 性別', sex)),
                                              const SizedBox(width: 12),
                                              Expanded(flex: 40, child: _buildInfoRow('AGE / 年齡', age.isNotEmpty ? '$age 歲' : '')),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(flex: 60, child: _buildInfoRow('DATE OF BIRTH / 出生日期', dateOfBirth)),
                                              const SizedBox(width: 12),
                                              Expanded(flex: 40, child: Container()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(height: 1, color: AppColors.passportDivider),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.barcodeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  barcode,
                                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: AppColors.infoLabel, height: 1.0, letterSpacing: 2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuItem('氣喘處置計劃', '請專業醫生給予診斷及保健指南', iconPath: 'assets/icons/doctor.svg', onTap: () => onMenuTap?.call(1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.passportCardGradientStart,
                  AppColors.passportCardGradientEnd,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(top: 12, bottom: 40, left: 24, right: 24),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    '彰化基督教醫院 核發',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.passportAccent70, height: 1.0),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ISSUED BY CHANGHUA CHRISTIAN HOSPITAL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.passportAccent70, height: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.infoLabel, height: 1.0)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 2.0)),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, {required String iconPath, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.inputBorder, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(AppColors.menuIconColor, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.menuSubtitle, height: 1.0)),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow-right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
