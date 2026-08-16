import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/emergency_contact_models.dart';
import '../../services/api_service.dart';
import '../../components/app_page_container.dart';
import '../../components/custom_tab_bar.dart';
import 'views/medical_resources_view.dart';
import 'views/emergency_contacts_view.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  int selectedTabIndex = 0;
  final List<String> tabs = ['醫療聯絡資源', '緊急連絡人'];
  ContactList? contactList;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final result = await ApiService.getContacts();
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() {
        contactList = result.data;
      });
    }
  }

  void _switchTab(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      content: Column(
        spacing: 8,
        children: [
          _buildTabButtons(),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            '緊急聯絡',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return CustomTabBar(
      tabs: tabs,
      selectedTabIndex: selectedTabIndex,
      onTabChanged: _switchTab,
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return MedicalResourcesView(
          onSwitchTab: _switchTab,
          contacts: contactList?.medical ?? [],
          onSaved: _loadContacts,
        );
      case 1:
        return EmergencyContactsView(
          onSwitchTab: _switchTab,
          contacts: contactList?.emergency ?? [],
          onSaved: _loadContacts,
        );
      default:
        return const SizedBox.shrink();
    }
  }

}
