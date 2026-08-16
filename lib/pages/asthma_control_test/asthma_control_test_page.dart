import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../models/act_models.dart';
import '../../services/api_service.dart';
import 'views/act_view.dart';
import 'views/act_selection_view.dart';
import 'views/act_form_view.dart';

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
  int? statusColor;
  String? statusSummary;
  bool isAdultTest = true;
  int currentView = 0; // 0: summary, 1: selection, 2: form
  String? targetGroup;
  String recordDate = '';
  List<ActQuestion> actQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActStatus();
  }

  Future<void> _loadActStatus() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final displayMonth = '${now.year}/${now.month.toString().padLeft(2, '0')}';

    final result = await ApiService.getActStatus(dateStr);
    if (!mounted) return;

    if (result.success && result.data != null) {
      // Prefer the API's own record_date (the date the test was actually
      // completed on) over today's date, so a test taken earlier in the
      // month still shows its real completion date rather than "now".
      final apiRecordDate = result.data!.recordDate;
      setState(() {
        measurementDate = apiRecordDate != null && apiRecordDate.length >= 7
            ? apiRecordDate.substring(0, 7)
            : displayMonth;
        isAssessmentCompleted = result.data!.isCompleted;
        measurementTime = result.data!.isCompleted ? (apiRecordDate ?? displayMonth) : null;
        targetGroup = result.data!.targetGroup;
        isAdultTest = result.data!.targetGroup != 'child';
        recordDate = dateStr;
        actQuestions = result.data!.questions;
        totalScore = result.data!.totalScore;
        statusColor = result.data!.statusColor;
        statusSummary = result.data!.statusSummary;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
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
      statusColor = result['statusColor'];
      statusSummary = result['statusSummary'];
    });
  }

  void _selectTestType(bool isAdult) {
    setState(() {
      isAdultTest = isAdult;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (currentView == 0) {
      content = ActView(
        measurementDate: measurementDate,
        isAssessmentCompleted: isAssessmentCompleted,
        measurementTime: measurementTime,
        onSwitchView: _switchView,
      );
    } else if (currentView == 1) {
      content = ActSelectionView(
        targetGroup: targetGroup,
        onSwitchView: _switchView,
        onSelectTestType: _selectTestType,
      );
    } else {
      content = ActFormView(
        measurementDate: measurementDate,
        recordDate: recordDate,
        isAdultTest: isAdultTest,
        questions: actQuestions,
        isAssessmentCompleted: isAssessmentCompleted,
        totalScore: totalScore,
        statusColor: statusColor,
        statusSummary: statusSummary,
        onSwitchView: _switchView,
        onAssessmentCalculated: _handleAssessmentCalculated,
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
