import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import '../theme/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String iconPath;
  // Tint applied to the icon; null shows the SVG's own colors (for
  // multi-color icons like check-fill.svg).
  final Color? iconColor;
  // When set, the icon sits inside a circle of this color (for glyph-only
  // icons like checkup.svg).
  final Color? iconBackgroundColor;
  final String content;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const CustomDialog({
    super.key,
    required this.iconPath,
    this.iconColor = AppColors.mustardGold,
    this.iconBackgroundColor,
    required this.content,
    this.buttonText = '確認',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            _buildIcon(),
            Text(
              content,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.6,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: buttonText,
                onPressed: onButtonPressed ?? () => Navigator.pop(context),
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                height: 37,
                borderRadius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final background = iconBackgroundColor;
    final colorFilter = iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null;
    if (background == null) {
      return SvgPicture.asset(iconPath, width: 80, height: 80, colorFilter: colorFilter);
    }
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: SvgPicture.asset(iconPath, width: 40, height: 40, colorFilter: colorFilter),
    );
  }
}
