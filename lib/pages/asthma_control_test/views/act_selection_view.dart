import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';

class ActSelectionView extends StatelessWidget {
  final Function(int) onSwitchView;
  final Function(bool) onSelectTestType;

  const ActSelectionView({
    super.key,
    required this.onSwitchView,
    required this.onSelectTestType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        _buildTestOption(
          '成人測驗',
          '(滿 12 歲)',
          true,
          () {
            onSelectTestType(true);
            onSwitchView(2);
          },
        ),
        const SizedBox(height: 16),
        _buildTestOption(
          '兒童測驗',
          '(4-11 歲)',
          false,
          () {
            onSelectTestType(false);
            onSwitchView(2);
          },
        ),
      ],
      ),
    );
  }

  Widget _buildTestOption(
    String title,
    String subtitle,
    bool isAdult,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.inputBorder, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 4),
              ),
              child: Center(
                child: SvgPicture.asset(
                  isAdult ? 'assets/icons/adult.svg' : 'assets/icons/child.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.375,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.reportTitle,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
