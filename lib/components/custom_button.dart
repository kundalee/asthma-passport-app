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
  final MainAxisAlignment iconAlignment;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.icon,
    this.border,
    this.isLoading = false,
    this.height,
    this.iconAlignment = MainAxisAlignment.center,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              constraints: BoxConstraints(
                minHeight: height ?? 0,
                minWidth: height != null ? double.infinity : 0,
              ),
              padding: height != null ? EdgeInsets.zero : padding,
              child: Center(
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
                            mainAxisAlignment: iconAlignment,
                            mainAxisSize: iconAlignment == MainAxisAlignment.center ? MainAxisSize.min : MainAxisSize.max,
                            children: [
                              icon!,
                              const SizedBox(width: 8),
                              Text(
                                text,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: foregroundColor),
                              ),
                            ],
                          )
                        : Text(
                            text,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: foregroundColor),
                          )),
              ),
            ),
          ),
        ),
      );
    }

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
                  mainAxisAlignment: iconAlignment,
                  mainAxisSize: iconAlignment == MainAxisAlignment.center ? MainAxisSize.min : MainAxisSize.max,
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
