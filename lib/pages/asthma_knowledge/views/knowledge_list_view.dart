import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';

class KnowledgeListView extends StatelessWidget {
  final Function(int) onSwitchView;

  const KnowledgeListView({
    super.key,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    final knowledgeItems = [
      '認識常見過敏原',
      '遠離過敏原的方法',
      '認識氣喘居家監測',
      '過敏原評估',
      '氣喘隨床照護計劃',
      '照護團隊服務介紹',
      '工具：氣喘控制程度評估',
      '工具：尖峰呼氣流速量測',
      '氣喘藥物治療計劃',
    ];

    return SingleChildScrollView(
      child: CardContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 0,
        child: Column(
          spacing: 8,
          children: List.generate(
            knowledgeItems.length,
            (index) => Column(
              children: [
                _buildKnowledgeItem(knowledgeItems[index]),
                if (index < knowledgeItems.length - 1)
                  const Divider(color: AppColors.sweetGrey, height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeItem(String title) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow-right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
