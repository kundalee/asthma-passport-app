import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';

class KnowledgeSelectionView extends StatelessWidget {
  final Function(int) onSwitchView;

  const KnowledgeSelectionView({
    super.key,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildEducationOption(
            '成人衛教',
            true,
            () {
              onSwitchView(1);
            },
          ),
          const SizedBox(height: 16),
          _buildEducationOption(
            '兒童衛教',
            false,
            () {
              onSwitchView(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationOption(
    String title,
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
          border: Border.all(color: AppColors.whiteMarble, width: 1),
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
                border: Border.all(color: AppColors.funGreen, width: 4),
              ),
              child: Center(
                child: SvgPicture.asset(
                  isAdult ? 'assets/icons/adult.svg' : 'assets/icons/child.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
