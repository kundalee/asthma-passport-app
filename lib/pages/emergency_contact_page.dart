import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/custom_tab_bar.dart';
import 'emergency_contact/views/medical_resources_view.dart';
import 'emergency_contact/views/emergency_contacts_view.dart';
import 'emergency_contact/views/patient_info_view.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  int selectedTabIndex = 0;
  final List<String> tabs = ['醫療聯絡資源', '緊急連絡人', '病患基本資料'];

  void _switchTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      content: Column(
        children: [
          _buildTabButtons(),
          const SizedBox(height: 8),
          _buildTabContent(),
        ],
      ),
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
            '緊急聯絡',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return CustomTabBar(
      tabs: tabs,
      selectedTabIndex: selectedTabIndex,
      onTabChanged: _switchTab,
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return MedicalResourcesView(onSwitchTab: _switchTab);
      case 1:
        return EmergencyContactsView(onSwitchTab: _switchTab);
      case 2:
        return PatientInfoView(onSwitchTab: _switchTab);
      default:
        return const SizedBox.shrink();
    }
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
        children: [
          _buildNavButton('個人首頁', Icons.home, AppColors.funGreen, false),
          const SizedBox(width: 24),
          _buildNavButton('系統設定', Icons.settings, AppColors.funGreen, false),
          const SizedBox(width: 24),
          _buildNavButton('緊急聯絡', Icons.warning, Colors.red, true),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, Color color, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == '個人首頁') {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (title == '系統設定') {
          Navigator.of(context).pushReplacementNamed('/system-settings');
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
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(width: 4),
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
}
