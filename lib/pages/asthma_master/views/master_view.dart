import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/instructions_box.dart';

class MasterView extends StatelessWidget {
  final Function(int) onSwitchView;

  const MasterView({
    super.key,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 20),
          const Text(
            '氣喘知識挑戰',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          InstructionsBox(
            title: '挑戰規則',
            instructions: [
              '選送 5 個問題題測你的氣喘常識',
              '掌握正確衛教資訊，守護呼吸健康',
              '自標得分：80 分以上即為「達人」',
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: '開始測驗',
              onPressed: () => onSwitchView(1),
              backgroundColor: AppColors.funGreen,
              foregroundColor: Colors.white,
              borderRadius: 4,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.funGreen, width: 4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/book.svg',
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
        ),
      ),
    );
  }
}
