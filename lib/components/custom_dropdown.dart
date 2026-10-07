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
  // Optional colors used while the list is open (the dropdown's equivalent
  // of a focused text field). Fall back to the normal colors when null.
  final Color? activeBackgroundColor;
  final Color? activeBorderColor;
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
    this.backgroundColor = AppColors.secondaryGray,
    this.borderColor = AppColors.secondaryGrayW,
    this.activeBackgroundColor,
    this.activeBorderColor,
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
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _currentOverlay?.remove();
    super.dispose();
  }

  void _closeDropdown() {
    if (_currentOverlay == null) return;
    _currentOverlay!.remove();
    setState(() {
      _currentOverlay = null;
    });
  }

  void _showDropdownOverlay(BuildContext context) {
    if (_currentOverlay != null) {
      _closeDropdown();
      return;
    }

    // Opening the list makes this the active field, so take focus (and the
    // keyboard) away from any text field that still has it.
    FocusManager.instance.primaryFocus?.unfocus();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final int visibleItemCount = math.min(widget.items.length, 5);
    // The open list is part of the active field, so it uses the active colors.
    final Color listBorderColor =
        widget.activeBorderColor ?? widget.borderColor;
    final Color listBackgroundColor =
        widget.activeBackgroundColor ?? widget.backgroundColor;

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, size.height),
        child: Align(
          alignment: Alignment.topLeft,
          // Same group as the field itself, so taps on the options don't
          // count as "outside" and close the list before onTap runs.
          child: TapRegion(
            groupId: this,
            child: Material(
              elevation: 0,
              child: SizedBox(
                width: size.width,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                          color: listBorderColor, width: widget.borderWidth),
                      right: BorderSide(
                          color: listBorderColor, width: widget.borderWidth),
                      bottom: BorderSide(
                          color: listBorderColor, width: widget.borderWidth),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(widget.borderRadius),
                      bottomRight: Radius.circular(widget.borderRadius),
                    ),
                    color: listBackgroundColor,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: size.height * visibleItemCount),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        ...widget.items.asMap().entries.map((entry) {
                          final item = entry.value;
                          final isLast = entry.key == widget.items.length - 1;
                          return GestureDetector(
                            onTap: () {
                              widget.onChanged(item);
                              _closeDropdown();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              height: size.height,
                              decoration: BoxDecoration(
                                color: listBackgroundColor,
                                border: !isLast
                                    ? Border(
                                        bottom: BorderSide(
                                          color: listBorderColor,
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
    final Color borderColor = isOverlayOpen
        ? widget.activeBorderColor ?? widget.borderColor
        : widget.borderColor;
    final Color backgroundColor = isOverlayOpen
        ? widget.activeBackgroundColor ?? widget.backgroundColor
        : widget.backgroundColor;

    // Closes the list on any tap outside it, including on another dropdown.
    return Builder(
      builder: (context) => TapRegion(
        groupId: this,
        onTapOutside: (_) => _closeDropdown(),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: () {
              _showDropdownOverlay(context);
            },
            child: Container(
              width: double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                border:
                    Border.all(color: borderColor, width: widget.borderWidth),
                borderRadius: isOverlayOpen
                    ? BorderRadius.only(
                        topLeft: Radius.circular(widget.borderRadius),
                        topRight: Radius.circular(widget.borderRadius),
                      )
                    : BorderRadius.circular(widget.borderRadius),
                color: backgroundColor,
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
                      colorFilter:
                          const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
