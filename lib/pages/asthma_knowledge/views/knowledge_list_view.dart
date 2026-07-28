import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';

typedef _KnowledgeItem = ({String title, String? mandarinUrl, String? taiwaneseUrl});

const List<_KnowledgeItem> _knowledgeItems = [
  (
    title: '兒童及成人吸藥輔助面罩使用',
    mandarinUrl: 'https://youtu.be/636xEC4QuGc?si=dV854nuMz5E9-RW2',
    taiwaneseUrl: 'https://youtu.be/2zPxkfABPa4?si=qBlLL7zRZj2A86Kq',
  ),
  (
    title: '輔舒酮-控制藥物',
    mandarinUrl: 'https://youtu.be/i84Vn0ra2NI?si=d72QH3uJjsZE3MEF',
    taiwaneseUrl: 'https://youtu.be/QojHbKTYtQg?si=ZT0t3xiJctCBEL_3',
  ),
  (
    title: '使肺泰-控制藥物',
    mandarinUrl: 'https://youtu.be/1JvZQIhz-zg?si=XYtj3fsu4l-tFdNm',
    taiwaneseUrl: 'https://youtu.be/nH3wYWnDHG4?si=okP8Z2iqkEW8f53h',
  ),
  (
    title: '吸必擴-控制藥物-乾粉劑型',
    mandarinUrl: 'https://youtu.be/y0_ZQABnvrQ?si=EcUzx68qPYWyATEx',
    taiwaneseUrl: 'https://youtu.be/FY0_ikceq7c?si=qnCN3Kg20WeqOK7l',
  ),
  (
    title: '吸必擴-控制藥物&緩解藥物-氣化噴霧劑型',
    mandarinUrl: 'https://youtu.be/zEBXHVcHJRU?si=hSRjyR8Mlb9FZuqx',
    taiwaneseUrl: 'https://youtu.be/ImyqbUHYIW0?si=n2tGfhzkwUq8btZu',
  ),
  (
    title: '備勞喘-緩解用藥',
    mandarinUrl: 'https://youtu.be/A_1iK-WMuqA?si=RCvpo383bDM6BMu4',
    taiwaneseUrl: 'https://youtu.be/i8jLiUegZGY?si=9pmaGE4KUCSsKUoO',
  ),
];

class KnowledgeListView extends StatelessWidget {
  final int selectedLanguageIndex; // 0: 國語, 1: 台語

  const KnowledgeListView({super.key, required this.selectedLanguageIndex});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        spacing: 8,
        children: List.generate(
          _knowledgeItems.length,
          (index) {
            final item = _knowledgeItems[index];
            final url = selectedLanguageIndex == 0 ? item.mandarinUrl : item.taiwaneseUrl;
            return Column(
              children: [
                _buildKnowledgeItem(item.title, url),
                if (index < _knowledgeItems.length - 1)
                  const Divider(color: AppColors.sweetGrey, height: 2),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKnowledgeItem(String title, String? url) {
    return GestureDetector(
      onTap: url == null ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
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
              colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
