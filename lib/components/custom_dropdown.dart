import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class CustomDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String placeholder;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
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
                left: BorderSide(color: AppColors.inputBorder, width: 2),
                right: BorderSide(color: AppColors.inputBorder, width: 2),
                bottom: BorderSide(color: AppColors.inputBorder, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: AppColors.inputBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  color: AppColors.inputBorder,
                  indent: 0,
                  endIndent: 0,
                  thickness: 1,
                ),
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
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        border: !isLast
                            ? Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              )
                            : null,
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
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
          height: 54,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inputBorder, width: 2),
            borderRadius: isOverlayOpen
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )
                : BorderRadius.circular(10),
            color: AppColors.inputBackground,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value ?? widget.placeholder,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.625,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Transform.rotate(
                angle: isOverlayOpen ? 3.14159 : 0,
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
