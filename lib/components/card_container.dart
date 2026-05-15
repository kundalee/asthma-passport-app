import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final bool showBorder;

  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.whiteMarble,
    this.borderRadius = 14,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: borderColor, width: 1) : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
