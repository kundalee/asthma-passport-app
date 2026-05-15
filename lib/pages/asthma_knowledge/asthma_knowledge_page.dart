import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import 'views/knowledge_selection_view.dart';
import 'views/knowledge_list_view.dart';

class AsthmaKnowledgePage extends StatefulWidget {
  const AsthmaKnowledgePage({super.key});

  @override
  State<AsthmaKnowledgePage> createState() => _AsthmaKnowledgePageState();
}

class _AsthmaKnowledgePageState extends State<AsthmaKnowledgePage> {
  int currentView = 0; // 0: selection

  void _switchView(int view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (currentView == 0) {
      content = KnowledgeSelectionView(
        onSwitchView: _switchView,
      );
    } else {
      content = KnowledgeListView(
        onSwitchView: _switchView,
      );
    }

    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: EdgeInsets.zero,
      content: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    String headerTitle = '氣喘知識';

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
          Text(
            headerTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
