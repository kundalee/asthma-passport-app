import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../models/diary_models.dart';
import '../../services/api_service.dart';
import 'views/asthma_diary_view.dart';
import 'views/asthma_diary_form_view.dart';

class AsthmaDiaryPage extends StatefulWidget {
  const AsthmaDiaryPage({super.key});

  @override
  State<AsthmaDiaryPage> createState() => _AsthmaDiaryPageState();
}

class _AsthmaDiaryPageState extends State<AsthmaDiaryPage> {
  final DateTime _today = DateTime.now();
  DiaryStatus? diaryStatus;
  int currentView = 0; // 0: diary summary, 1: assessment form

  String get _dateStr {
    return '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';
  }

  String get measurementDate {
    return '${_today.year}/${_today.month.toString().padLeft(2, '0')}/${_today.day.toString().padLeft(2, '0')}';
  }

  bool get isAssessmentCompleted => diaryStatus?.isCompleted ?? false;

  @override
  void initState() {
    super.initState();
    _loadDiaryStatus();
  }

  Future<void> _loadDiaryStatus() async {
    final result = await ApiService.getDiaryStatus(_dateStr);
    if (result.success && result.data != null) {
      setState(() {
        diaryStatus = result.data;
      });
    }
  }

  void _switchView(int view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      content: currentView == 0
          ? AsthmaDiaryView(
              measurementDate: measurementDate,
              isAssessmentCompleted: isAssessmentCompleted,
              measurementTime: isAssessmentCompleted ? measurementDate : null,
              onSwitchView: _switchView,
            )
          : AsthmaDiaryFormView(
              dateStr: _dateStr,
              measurementDate: measurementDate,
              isAssessmentCompleted: isAssessmentCompleted,
              questions: diaryStatus?.questions ?? [],
              totalScore: diaryStatus?.totalScore,
              statusSummary: diaryStatus?.statusSummary,
              onSwitchView: _switchView,
              onSaved: _loadDiaryStatus,
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
            '氣喘日記',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
