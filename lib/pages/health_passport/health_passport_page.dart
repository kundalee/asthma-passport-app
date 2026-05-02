import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/api_service.dart';
import '../../components/app_page_container.dart';
import 'views/passport_view.dart';
import 'views/report_view.dart';

class HealthPassportPage extends StatefulWidget {
  const HealthPassportPage({super.key});

  @override
  State<HealthPassportPage> createState() => _HealthPassportPageState();
}

class _HealthPassportPageState extends State<HealthPassportPage> {
  late Future<Map<String, dynamic>> passportData;
  int currentView = 0; // 0: passport, 1: report

  @override
  void initState() {
    super.initState();
    passportData = ApiService.getPassport();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      content: FutureBuilder<Map<String, dynamic>>(
        future: passportData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          return currentView == 0
              ? HealthPassportView(data: data, onLogout: () => _logout(context), onMenuTap: _switchView)
              : HealthReportView(data: data, onSwitchView: _switchView);
        },
      ),
    );
  }

  void _switchView(int view) {
    setState(() {
      currentView = view;
    });
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
              if (currentView == 0) {
                Navigator.pop(context);
              } else {
                _switchView(0);
              }
            },
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '健康護照',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
}
