import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/app_page_container.dart';
import 'asthma_master/views/master_view.dart';
import 'asthma_master/views/master_form_view.dart';

class AsthmaMasterPage extends StatefulWidget {
  const AsthmaMasterPage({super.key});

  @override
  State<AsthmaMasterPage> createState() => _AsthmaMasterPageState();
}

class _AsthmaMasterPageState extends State<AsthmaMasterPage> {
  int currentView = 0;

  void _onSwitchView(int viewIndex) {
    setState(() {
      currentView = viewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      content: currentView == 0
          ? MasterView(onSwitchView: _onSwitchView)
          : MasterFormView(onSwitchView: _onSwitchView),
      bottomNavigation: const SizedBox.shrink(),
      bottomNavigationPadding: EdgeInsets.zero,
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
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '氣喘達人',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

}
