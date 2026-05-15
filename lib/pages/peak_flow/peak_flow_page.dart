import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../services/api_service.dart';
import 'views/peak_flow_view.dart';
import 'views/peak_flow_form_view.dart';
import 'views/peak_flow_results_view.dart';

class PeakFlowPage extends StatefulWidget {
  const PeakFlowPage({super.key});

  @override
  State<PeakFlowPage> createState() => _PeakFlowPageState();
}

class _PeakFlowPageState extends State<PeakFlowPage> {
  String measurementDate = '2025/12/10';
  bool isDaytimeCompleted = false;
  bool isEveningCompleted = false;
  String? daytimeValue;
  String? eveningValue;
  int? daytimeStatus;
  int? eveningStatus;
  int currentView = 0; // 0: summary, 1: form, 2: results
  bool isDaytime = true;
  String? currentResultValue;
  int? currentResultStatus;

  @override
  void initState() {
    super.initState();
    _loadPeakFlowStatus();
  }

  Future<void> _loadPeakFlowStatus() async {
    try {
      final data = await ApiService.getPeakFlowStatus();
      setState(() {
        measurementDate = data['measurementDate'] ?? '2025/12/10';
        isDaytimeCompleted = data['isDaytimeCompleted'] ?? false;
        isEveningCompleted = data['isEveningCompleted'] ?? false;
        daytimeValue = data['daytimeValue']?.toString();
        daytimeStatus = data['daytimeStatus'];
        eveningValue = data['eveningValue']?.toString();
        eveningStatus = data['eveningStatus'];
      });
    } catch (e) {
      // Keep default values if API fails
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
        onSwitchView: _switchView,
        onViewDaytimeResults: _viewDaytimeResults,
        onViewEveningResults: _viewEveningResults,
      );
    } else {
      content = PeakFlowResultsView(
        measurementDate: measurementDate,
        isDaytime: isDaytime,
        measurementValue: currentResultValue ?? '',
        status: currentResultStatus,
        onSwitchView: _switchView,
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
