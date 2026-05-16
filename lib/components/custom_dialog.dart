import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import '../theme/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String iconPath;
  final String content;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const CustomDialog({
    super.key,
    required this.iconPath,
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
            SvgPicture.asset(
              iconPath,
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(AppColors.mustardGold, BlendMode.srcIn),
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.5,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: buttonText,
                onPressed: onButtonPressed ?? () => Navigator.pop(context),
                backgroundColor: AppColors.funGreen,
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
}
