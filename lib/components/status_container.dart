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
  final String title;
  final List<StatusItem> items;
  final bool isComplete;
  final VoidCallback onPressed;

  const StatusContainer({
    super.key,
    required this.title,
    required this.items,
    required this.onPressed,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/document.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: List.generate(
                items.length,
                (index) => [
                  if (index > 0) const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        items[index].label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                      ),
                      Text(
                        items[index].status,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                      ),
                    ],
                  ),
                ],
              ).expand((element) => element).toList(),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: isComplete ? '查看測驗結果' : '開始紀錄',
            onPressed: onPressed,
            backgroundColor: isComplete ? const Color(0xFF155DFC) : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            borderRadius: 4,
            height: 37,
          ),
        ],
      ),
    );
  }
}
