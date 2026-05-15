import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(),
      contentPadding: EdgeInsets.zero,
      content: _buildContent(),
      bottomNavigation: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '系統設定',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final settingItems = [
      '當前地理位置設定',
      '彰化基督教醫院官方網站',
      '空氣品質監測網',
      '關於氣喘健康護照',
    ];

    return SingleChildScrollView(
      child: CardContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 0,
        child: Column(
          spacing: 8,
          children: List.generate(
            settingItems.length,
            (index) => Column(
              children: [
                _buildSettingItem(settingItems[index], () => _handleSettingTap(index)),
                if (index < settingItems.length - 1) const Divider(color: AppColors.sweetGrey, height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow-right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteMarble, width: 1),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          _buildNavButton('個人首頁', Icons.home, AppColors.funGreen, false),
          _buildNavButton('系統設定', Icons.settings, AppColors.funGreen, true),
          _buildNavButton('緊急聯絡', Icons.warning, Colors.red, false),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, Color color, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == '個人首頁') {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (title == '緊急聯絡') {
          Navigator.of(context).pushReplacementNamed('/emergency-contact');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: isActive ? color : Colors.transparent,
        ),
        child: Row(
          spacing: 4,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 24,
            ),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSettingTap(int index) {
    final messages = [
      '位置設定功能開發中',
      '彰化基督教醫院官方網站 功能開發中',
      '空氣品質監測網 功能開發中',
      '關於氣喘健康護照 功能開發中',
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messages[index])),
    );
  }
}
