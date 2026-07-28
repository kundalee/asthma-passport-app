import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/passport_models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../components/app_page_container.dart';
import 'views/passport_view.dart';
import 'views/report_view.dart';
import 'views/new_plan_view.dart';

class HealthPassportPage extends StatefulWidget {
  const HealthPassportPage({super.key});

  @override
  State<HealthPassportPage> createState() => _HealthPassportPageState();
}

class _HealthPassportPageState extends State<HealthPassportPage> {
  final DateTime _today = DateTime.now();
  PassportInfo? passportInfo;
  PassportHistorySummary? passportHistory;
  int currentView = 0; // 0: passport, 1: report, 2: new_plan
  bool isPlanPreview = false;

  String get _dateStr {
    return '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    final infoFuture = ApiService.getPassportInfo();
    final historyFuture = ApiService.getPassportHistory();
    final infoResult = await infoFuture;
    final historyResult = await historyFuture;

    if (infoResult.success && infoResult.data != null) {
      setState(() {
        passportInfo = infoResult.data;
      });
    }
    if (historyResult.success && historyResult.data != null) {
      setState(() {
        passportHistory = historyResult.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: currentView == 2 && isPlanPreview
          ? EdgeInsets.only(top: 12)
          : const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      content: passportInfo == null || passportHistory == null
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(passportInfo!, passportHistory!),
    );
  }

  Widget _buildContent(PassportInfo info, PassportHistorySummary history) {
    if (currentView == 0) {
      return HealthPassportView(info: info, onLogout: () => _logout(context), onMenuTap: _switchView);
    } else if (currentView == 1) {
      return HealthReportView(info: info, history: history, dateStr: _dateStr, onSwitchView: _switchView);
    } else {
      return NewPlanView(
        info: info,
        onSwitchView: _switchView,
        onPreviewChanged: (value) => setState(() => isPlanPreview = value),
      );
    }
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
                _switchView(currentView - 1);
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
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
}
