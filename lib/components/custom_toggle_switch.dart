import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomToggleSwitch extends StatelessWidget {
  final bool isLeftSelected;
  final String leftText;
  final String rightText;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomToggleSwitch({
    super.key,
    required this.isLeftSelected,
    required this.leftText,
    required this.rightText,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(360),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: leftText,
              onPressed: () => onChanged(true),
              backgroundColor: isLeftSelected ? activeColor : Colors.transparent,
              foregroundColor: isLeftSelected ? Colors.white : Colors.black,
              borderRadius: 360,
            ),
          ),
          Expanded(
            child: CustomButton(
              text: rightText,
              onPressed: () => onChanged(false),
              backgroundColor: !isLeftSelected ? activeColor : Colors.transparent,
              foregroundColor: !isLeftSelected ? Colors.white : Colors.black,
              borderRadius: 360,
            ),
          ),
        ],
      ),
    );
  }
}
