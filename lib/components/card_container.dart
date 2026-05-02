import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 14,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? AppColors.inputBorder, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }
}
