import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/terms_bottom_sheet.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      content: _buildContent(context),
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
            '關於氣喘健康護照',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Fill the space AppPageContainer leaves below the header (44) and its
    // default vertical contentPadding (12 top + 12 bottom), so spaceBetween
    // can pin the footer to the bottom instead of leaving it mid-page.
    final availableHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom - 44 - 24;

    return SizedBox(
      height: availableHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                '若您對產品及服務有任何建議，請與我們聯絡',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
              ),
              const SizedBox(height: 20),
              CardContainer(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('彰化基督教醫院 功能開發中')),
                    );
                  },
                  child: Row(
                    spacing: 12,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/internet.svg',
                        width: 40,
                        height: 40,
                        colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                      ),
                      const Text(
                        '彰化基督教醫院',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black, height: 1.6, letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '版本 1.0.0',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _showTerms(context),
                child: const Text(
                  '服務約定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.625,
                    letterSpacing: 0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TermsBottomSheet(
        title: '服務約定',
        readOnly: true,
      ),
    );
  }
}
