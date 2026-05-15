import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class CustomDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String placeholder;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double height;
  final EdgeInsetsGeometry padding;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.textStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      height: 1.0,
      letterSpacing: 0,
    ),
    this.backgroundColor = AppColors.powder,
    this.borderColor = AppColors.whiteMarble,
    this.borderRadius = 10.0,
    this.borderWidth = 2.0,
    this.height = 54.0,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _currentOverlay;

  @override
  void dispose() {
    _currentOverlay?.remove();
    super.dispose();
  }

  void _showDropdownOverlay(BuildContext context) {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      setState(() {
        _currentOverlay = null;
      });
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: widget.borderColor, width: widget.borderWidth),
                right: BorderSide(color: widget.borderColor, width: widget.borderWidth),
                bottom: BorderSide(color: widget.borderColor, width: widget.borderWidth),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(widget.borderRadius),
                bottomRight: Radius.circular(widget.borderRadius),
              ),
              color: widget.backgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == widget.items.length - 1;
                  return GestureDetector(
                    onTap: () {
                      widget.onChanged(item);
                      overlayEntry.remove();
                      setState(() {
                        _currentOverlay = null;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      height: size.height,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        border: !isLast
                            ? Border(
                                bottom: BorderSide(
                                  color: widget.borderColor,
                                  width: widget.borderWidth,
                                ),
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: widget.textStyle,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    setState(() {
      _currentOverlay = overlayEntry;
    });
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverlayOpen = _currentOverlay != null;

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          _showDropdownOverlay(context);
        },
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor, width: widget.borderWidth),
            borderRadius: isOverlayOpen
                ? BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    topRight: Radius.circular(widget.borderRadius),
                  )
                : BorderRadius.circular(widget.borderRadius),
            color: widget.backgroundColor,
          ),
          padding: widget.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value ?? widget.placeholder,
                  style: widget.textStyle,
                ),
              ),
              Transform.rotate(
                angle: isOverlayOpen ? math.pi : 0,
                child: SvgPicture.asset(
                  'assets/icons/arrow-down.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
