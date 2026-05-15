import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final String? errorText;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final bool dynamicBorderColor;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.errorText,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.backgroundColor = AppColors.powder,
    this.borderColor = AppColors.whiteMarble,
    this.borderRadius = 10,
    this.dynamicBorderColor = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  static final _hideIcon = SvgPicture.asset(
    'assets/icons/hide-on.svg',
    width: 24,
    height: 24,
    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
  );
  static final _showIcon = SvgPicture.asset(
    'assets/icons/hide-off.svg',
    width: 24,
    height: 24,
    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
  );

  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller?.text.isNotEmpty ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final currentBorderColor = hasError
        ? AppColors.strongRed
        : (widget.dynamicBorderColor && _hasText ? AppColors.funGreen : widget.borderColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 54,
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
              prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: widget.prefixIcon,
                  )
                : null,
              suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: widget.onToggleVisibility,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: widget.obscureText ? _hideIcon : _showIcon,
                    ),
                  )
                : null,
              filled: true,
              fillColor: widget.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
            ),
          ),
        ),
        if (hasError)
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.strongRed, height: 1.71, letterSpacing: 0),
          ),
      ],
    );
  }
}
