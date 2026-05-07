import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final Widget prefixIcon;
  final TextEditingController? controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? errorText;
  final Color borderColor;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.errorText,
    this.borderColor = AppColors.inputBorder,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
        ? AppColors.error
        : (_hasText ? AppColors.primaryGreen : widget.borderColor);

    final defaultHideIcon = SvgPicture.asset(
      'assets/icons/hide-on.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );
    final defaultShowIcon = SvgPicture.asset(
      'assets/icons/hide-off.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 54,
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: widget.prefixIcon,
              ),
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: widget.onToggleVisibility,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: widget.obscureText ? defaultHideIcon : defaultShowIcon,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: currentBorderColor, width: 2),
              ),
            ),
          ),
        ),
        if (hasError)
          Text(
            widget.errorText!,
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.error, fontSize: 14, height: 1.71),
          ),
      ],
    );
  }
}
