import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../components/custom_tab_bar.dart';
import 'views/knowledge_base_view.dart';
import 'views/knowledge_list_view.dart';

class AsthmaKnowledgePage extends StatefulWidget {
  const AsthmaKnowledgePage({super.key});

  @override
  State<AsthmaKnowledgePage> createState() => _AsthmaKnowledgePageState();
}

class _AsthmaKnowledgePageState extends State<AsthmaKnowledgePage> {
  int selectedTabIndex = 0;
  final List<String> tabs = ['氣喘知識庫', '國語', '台語'];

  void _switchTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKnowledgeBase = selectedTabIndex == 0;
    return AppPageContainer(
      header: _buildHeader(context),
      scrollable: !isKnowledgeBase,
      content: Column(
        spacing: 8,
        children: [
          CustomTabBar(
            tabs: tabs,
            selectedTabIndex: selectedTabIndex,
            onTabChanged: _switchTab,
          ),
          if (isKnowledgeBase)
            const Expanded(child: KnowledgeBaseView())
          else
            KnowledgeListView(selectedLanguageIndex: selectedTabIndex - 1),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '氣喘知識',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
