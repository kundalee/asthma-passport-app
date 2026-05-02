import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../components/app_page_container.dart';
import '../components/custom_button.dart';

class HealthPassportPage extends StatefulWidget {
  const HealthPassportPage({super.key});

  @override
  State<HealthPassportPage> createState() => _HealthPassportPageState();
}

class _HealthPassportPageState extends State<HealthPassportPage> {
  late Future<Map<String, dynamic>> passportData;

  @override
  void initState() {
    super.initState();
    passportData = ApiService.getPassport();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      content: FutureBuilder<Map<String, dynamic>>(
        future: passportData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          return _buildContent(context, data);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '健康護照',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString();
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
          // Passport Card
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
                // Green header section
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
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Asthma Health Passport',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.passportAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider line
                Container(
                  height: 4,
                  color: AppColors.passportAccent,
                ),
                // White content section
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
                            // Photo and Personal Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Photo
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
                                // Personal info - Grid layout
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          // Row 1
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 60,
                                                child: _buildInfoRow('TYPE / 類型', type),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 40,
                                                child: _buildInfoRow('CODE / 代碼', code),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Row 2
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 60,
                                                child: _buildInfoRow('NAME / 姓名', name),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 40,
                                                child: _buildInfoRow('SEX / 性別', sex),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Row 3
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 60,
                                                child: _buildInfoRow('DATE OF BIRTH / 出生日期', dateOfBirth),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 40,
                                                child: _buildInfoRow('AGE / 年齡', age),
                                              ),
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
                            // Divider line
                            Container(
                              height: 1,
                              color: AppColors.passportDivider,
                            ),
                            const SizedBox(height: 12),
                            // Barcode
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
                      // Menu items
                      _buildMenuItem('基本健康資料', '查看氣喘診測計畫', iconPath: 'assets/icons/user.svg'),
                      const SizedBox(height: 10),
                      _buildMenuItem('健康護照', '請專業醫生生給予診斷及保健指南', iconPath: 'assets/icons/doctor.svg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom section with green background
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
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '登出帳號',
                    onPressed: () => _logout(context),
                    backgroundColor: AppColors.logoutButtonBg,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: 4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '長化基督教醫院 核發',
                  style: TextStyle(fontSize: 10, color: AppColors.passportAccent70),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ISSUED BY CHANGHUA CHRISTIAN HOSPITAL',
                  style: TextStyle(fontSize: 10, color: AppColors.passportAccent70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.infoLabel),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, {required String iconPath}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.menuSubtitle),
                ),
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
    );
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
}
