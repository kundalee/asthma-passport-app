import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/app_page_container.dart';
import '../services/api_service.dart';
import 'asthma_control_test/views/act_view.dart';
import 'asthma_control_test/views/act_selection_view.dart';
import 'asthma_control_test/views/act_form_view.dart';

class AsthmaControlTestPage extends StatefulWidget {
  const AsthmaControlTestPage({super.key});

  @override
  State<AsthmaControlTestPage> createState() => _AsthmaControlTestPageState();
}

class _AsthmaControlTestPageState extends State<AsthmaControlTestPage> {
  String measurementDate = '2025/12';
  bool isAssessmentCompleted = false;
  String? measurementTime;
  int? totalScore;
  int? controlLevel;
  bool isAdultTest = true;
  int currentView = 0; // 0: summary, 1: selection, 2: form

  @override
  void initState() {
    super.initState();
    _loadActStatus();
  }

  Future<void> _loadActStatus() async {
    try {
      final data = await ApiService.getActStatus();
      setState(() {
        measurementDate = data['measurementDate'] ?? '2025/12';
        isAssessmentCompleted = data['selfAssessment'] ?? false;
        measurementTime = data['measurementTime'];
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

  void _handleAssessmentCalculated(Map<String, dynamic> result) {
    setState(() {
      totalScore = result['totalScore'];
      controlLevel = result['controlLevel'];
    });
  }

  Future<void> _submitAssessment() async {
    try {
      final response = await ApiService.submitAssessment(
        isAdultTest: isAdultTest,
        totalScore: totalScore ?? 0,
        controlLevel: controlLevel ?? 1,
      );

      if (response['success'] == true) {
        setState(() {
          isAssessmentCompleted = true;
          measurementTime = response['measurementDate'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _selectTestType(bool isAdult) {
    setState(() {
      isAdultTest = isAdult;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (currentView == 0) {
      content = ActView(
        measurementDate: measurementDate,
        isAssessmentCompleted: isAssessmentCompleted,
        measurementTime: measurementTime,
        onSwitchView: _switchView,
      );
    } else if (currentView == 1) {
      content = ActSelectionView(
        onSwitchView: _switchView,
        onSelectTestType: _selectTestType,
      );
    } else {
      content = ActFormView(
        measurementDate: measurementDate,
        isAdultTest: isAdultTest,
        onSwitchView: _switchView,
        onAssessmentCalculated: _handleAssessmentCalculated,
        onSubmitAssessment: _submitAssessment,
      );
    }

    return AppPageContainer(
      header: _buildHeader(context),
      content: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    String headerTitle = '氣喘控制測驗';

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
              } else if (currentView == 3) {
                _switchView(0);
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
