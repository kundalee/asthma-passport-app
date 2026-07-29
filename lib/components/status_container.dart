import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'card_container.dart';
import 'custom_button.dart';
import '../theme/app_colors.dart';

class StatusItem {
  final String label;
  final String status;

  const StatusItem({
    required this.label,
    required this.status,
  });
}

class StatusContainer extends StatelessWidget {
  final List<StatusItem> items;
  final VoidCallback onPressed;
  final String? title;
  final bool isComplete;
  final bool withCard;
  final bool showButton;

  const StatusContainer({
    super.key,
    required this.items,
    required this.onPressed,
    this.title,
    this.isComplete = false,
    this.withCard = true,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          if (title != null)
            Row(
              spacing: 8,
              children: [
                SvgPicture.asset(
                  'assets/icons/document.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                ),
                Text(
                  title!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                ),
              ],
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isComplete ? AppColors.honeydew : AppColors.babysBottom,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              spacing: 12,
              children: [
                for (final item in items)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
                      Text(item.status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
                    ],
                  ),
              ],
            ),
          ),
          if (showButton)
            CustomButton(
              text: isComplete ? '查看測驗結果' : '開始紀錄',
              onPressed: onPressed,
              backgroundColor: isComplete ? AppColors.sportyBlue : AppColors.primaryGreen,
              foregroundColor: Colors.white,
              borderRadius: 4,
              height: 37,
            ),
        ],
    );
    if (withCard) {
      return CardContainer(padding: const EdgeInsets.all(16), child: content);
    }
    return content;
  }
}
