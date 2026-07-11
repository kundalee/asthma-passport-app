import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'card_container.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedTabIndex;
  final Function(int) onTabChanged;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      borderRadius: 8,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedTabIndex == index ? AppColors.primaryGreen : AppColors.richWhite,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedTabIndex == index ? Colors.white : Colors.black,
                        height: 2.67,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
