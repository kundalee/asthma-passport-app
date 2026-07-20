import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../models/auth_models.dart';
import '../../models/peak_flow_models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'views/peak_flow_view.dart';
import 'views/peak_flow_form_view.dart';
import 'views/peak_flow_results_view.dart';

class PeakFlowPage extends StatefulWidget {
  const PeakFlowPage({super.key});

  @override
  State<PeakFlowPage> createState() => _PeakFlowPageState();
}

class _PeakFlowPageState extends State<PeakFlowPage> {
  final DateTime _today = DateTime.now();
  PeakFlowStatus? peakFlowStatus;
  UserProfile? userProfile;
  int currentView = 0; // 0: summary, 1: form, 2: results
  bool isDaytime = true;
  String? currentResultValue;
  int? currentResultStatus;

  String get _dateStr {
    return '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';
  }

  String get measurementDate {
    return '${_today.year}/${_today.month.toString().padLeft(2, '0')}/${_today.day.toString().padLeft(2, '0')}';
  }

  bool get isDaytimeCompleted => peakFlowStatus?.morning.isCompleted ?? false;
  bool get isEveningCompleted => peakFlowStatus?.night.isCompleted ?? false;

  String? get daytimeValue => _formatValue(peakFlowStatus?.morning.value);
  String? get eveningValue => _formatValue(peakFlowStatus?.night.value);

  int? get _predictedPeakFlow => ApiService.predictedPeakFlow(
        age: userProfile?.age ?? '',
        height: userProfile?.height ?? '',
        gender: userProfile?.gender ?? '',
      );

  int? get daytimeStatus => peakFlowStatus?.morning.statusSummary;

  int? get eveningStatus => peakFlowStatus?.night.statusSummary;

  String? _formatValue(double? value) {
    return value?.toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    _loadPeakFlowStatus();
    _loadUserProfile();
  }

  Future<void> _loadPeakFlowStatus() async {
    final result = await ApiService.getPeakFlowStatus(_dateStr);
    if (result.success && result.data != null) {
      setState(() {
        peakFlowStatus = result.data;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final result = await AuthService.getProfile();
    if (result.success && result.data != null) {
      setState(() {
        userProfile = result.data;
      });
    }
  }

  void _switchView(int view) {
    setState(() {
      currentView = view;
    });
  }

  void _viewDaytimeResults() {
    setState(() {
      currentView = 2;
      isDaytime = true;
      currentResultValue = daytimeValue;
      currentResultStatus = daytimeStatus;
    });
  }

  void _viewEveningResults() {
    setState(() {
      currentView = 2;
      isDaytime = false;
      currentResultValue = eveningValue;
      currentResultStatus = eveningStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (currentView == 0) {
      content = PeakFlowView(
        measurementDate: measurementDate,
        isDaytimeCompleted: isDaytimeCompleted,
        isEveningCompleted: isEveningCompleted,
        onSwitchView: _switchView,
      );
    } else if (currentView == 1) {
      content = PeakFlowFormView(
        measurementDate: measurementDate,
        isDaytimeCompleted: isDaytimeCompleted,
        isEveningCompleted: isEveningCompleted,
        daytimeValue: daytimeValue,
        eveningValue: eveningValue,
        userName: userProfile?.name ?? '',
        age: userProfile?.age ?? '-',
        height: userProfile?.height ?? '未填寫',
        weight: userProfile?.weight ?? '未填寫',
        gender: userProfile?.gender ?? '未填寫',
        onSwitchView: _switchView,
        onViewDaytimeResults: _viewDaytimeResults,
        onViewEveningResults: _viewEveningResults,
      );
    } else {
      content = PeakFlowResultsView(
        dateStr: _dateStr,
        measurementDate: measurementDate,
        isDaytime: isDaytime,
        measurementValue: currentResultValue ?? '',
        status: currentResultStatus,
        bestValue: _predictedPeakFlow?.toDouble(),
        onSwitchView: _switchView,
        onSaved: _loadPeakFlowStatus,
      );
    }

    return AppPageContainer(
      header: _buildHeader(context),
      content: content,
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
            '尖峰吐氣流量',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
