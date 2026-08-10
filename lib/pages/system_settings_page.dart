import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
    );
  }

  Widget _buildHeader() {
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
            '系統設定',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final settingItems = [
      '當前地理位置設定',
      '彰化基督教醫院官方網站',
      '空氣品質監測網',
      '意見調查',
      '關於氣喘健康護照',
    ];
    const dividerAfterIndexes = {0, 3};

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
                if (dividerAfterIndexes.contains(index)) const Divider(color: AppColors.sweetGrey, height: 2),
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
              colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSettingTap(int index) {
    if (index == 0) {
      Geolocator.openAppSettings();
      return;
    }
    if (index == 1) {
      launchUrl(Uri.parse('https://www.cch.org.tw/home.aspx'), mode: LaunchMode.externalApplication);
      return;
    }
    if (index == 2) {
      launchUrl(Uri.parse('https://airtw.moenv.gov.tw/'), mode: LaunchMode.externalApplication);
      return;
    }
    if (index == 3) {
      launchUrl(Uri.parse('https://apisvc.cch.org.tw/website/asthma'), mode: LaunchMode.externalApplication);
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushNamed('/about');
      return;
    }
  }
}
