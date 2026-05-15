import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final MainAxisAlignment iconAlignment;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final BorderSide? border;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final bool isLoading;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.borderRadius = 4.0,
    this.border,
    this.height,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.gradient,
    this.isLoading = false,
    this.textStyle,
  });

  TextStyle get _textStyle => textStyle ?? TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: foregroundColor,
    height: 1.5,
    letterSpacing: 0,
  );

  Widget get _loadingIndicator => SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          borderRadius: radius,
          border: border != null ? Border.fromBorderSide(border!) : null,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: radius,
          child: Container(
            constraints: BoxConstraints(
              minHeight: height ?? 0,
              minWidth: height != null ? double.infinity : 0,
            ),
            padding: height != null ? EdgeInsets.zero : padding,
            child: Center(child: _buildChild()),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) return _loadingIndicator;
    if (icon != null) {
      return Row(
        mainAxisAlignment: iconAlignment,
        mainAxisSize: iconAlignment == MainAxisAlignment.center ? MainAxisSize.min : MainAxisSize.max,
        children: [icon!, const SizedBox(width: 8), Text(text, style: _textStyle)],
      );
    }
    return Text(text, style: _textStyle);
  }
}
