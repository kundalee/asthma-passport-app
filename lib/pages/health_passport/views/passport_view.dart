import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/passport_models.dart';
import '../../../theme/app_colors.dart';

class HealthPassportView extends StatelessWidget {
  final PassportInfo info;
  final VoidCallback onLogout;
  final Function(int)? onMenuTap;

  const HealthPassportView({
    super.key,
    required this.info,
    required this.onLogout,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPassportTitle(),
        Container(
          height: 4,
          color: AppColors.goldenPoppy,
        ),
        _buildPassportBody(),
        _buildPassportFooter(),
      ],
    );
  }

  Widget _buildPassportTitle() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sensationalGreen,
            AppColors.primaryGreen,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          const Text(
            '我的健康護照',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.goldenPoppy,
              height: 1.0,
            ),
          ),
          const Text(
            'Asthma Health Passport',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.goldenPoppy,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sensationalGreen,
            AppColors.primaryGreen,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 40, left: 24, right: 24),
      child: Column(
        spacing: 4,
        children: [
          const Text(
            '彰化基督教醫院 核發',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.goldenPoppy70, height: 1.0),
          ),
          const Text(
            'ISSUED BY CHANGHUA CHRISTIAN HOSPITAL',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.goldenPoppy70, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportBody() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          _buildPassportCard(),
          _buildMenuItem('氣喘處置計劃', '請專業醫生給予診斷及保健指南', iconPath: 'assets/icons/doctor.svg', onTap: () => onMenuTap?.call(1)),
        ],
      ),
    );
  }

  Widget _buildPassportCard() {
    final name = info.name;
    final dateOfBirth = info.birthday;
    final code = info.code;
    final sex = info.sex;
    final age = info.age;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.butteryWhite,
        border: Border.all(color: AppColors.tranquilYellow, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.brown, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: AppColors.sweetGrey,
                  child: info.avatarUrl.startsWith('http')
                      ? Image.network(
                          info.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 60, color: Colors.grey),
                        )
                      : const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Expanded(flex: 60, child: _buildInfoRow('NAME / 姓名', name)),
                        Expanded(flex: 40, child: _buildInfoRow('CODE / 代碼', code)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Expanded(flex: 60, child: _buildInfoRow('SEX / 性別', sex)),
                        Expanded(flex: 40, child: _buildInfoRow('AGE / 年齡', age == '-' ? age : '$age 歲')),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Expanded(flex: 60, child: _buildInfoRow('DATE OF BIRTH / 出生日期', dateOfBirth)),
                        Expanded(flex: 40, child: Container()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: 1, color: AppColors.gangsterGold),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.beeswax,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBarcodeLine(),
                _buildBarcodeLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeLine() {
    return Text(
      '<' * 200,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: AppColors.newAmber, height: 1.0, letterSpacing: 2),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.newAmber, height: 1.0)),
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
          border: Border.all(color: AppColors.secondaryGrayW, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.hydrocarbon, height: 1.0)),
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
