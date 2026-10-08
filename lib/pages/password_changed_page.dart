import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';

class PasswordChangedPage extends StatelessWidget {
  const PasswordChangedPage({super.key});

  // The reset flow is finished, so both the back arrow and 返回首頁 clear it
  // rather than returning to the 設定新密碼 form.
  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: AppPageContainer(
        contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        header: _buildHeader(context),
        content: _buildContent(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _goHome(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '設定新密碼',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
              child: SvgPicture.asset('assets/icons/checkup.svg', width: 40, height: 40),
            ),
          ),
          const Column(
            spacing: 12,
            children: [
              Text(
                '新密碼已變更',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
                textAlign: TextAlign.center,
              ),
              Text(
                '請妥善保管您的密碼',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          CustomButton(
            text: '返回首頁',
            onPressed: () => _goHome(context),
            backgroundColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}
