import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final BorderSide? border;
  final bool isLoading;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.icon,
    this.border,
    this.isLoading = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: height != null ? Size(double.infinity, height!) : Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: height != null ? EdgeInsets.zero : padding,
        side: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : (icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                )),
    );
  }
}
