import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/app_page_container.dart';
import '../../services/api_service.dart';
import 'views/asthma_diary_view.dart';
import 'views/asthma_diary_form_view.dart';

class AsthmaDiaryPage extends StatefulWidget {
  const AsthmaDiaryPage({super.key});

  @override
  State<AsthmaDiaryPage> createState() => _AsthmaDiaryPageState();
}

class _AsthmaDiaryPageState extends State<AsthmaDiaryPage> {
  String measurementDate = '2025/12/10';
  bool isAssessmentCompleted = false;
  String? measurementTime;
  int currentView = 0; // 0: diary summary, 1: assessment form

  @override
  void initState() {
    super.initState();
    _loadDiaryStatus();
  }

  Future<void> _loadDiaryStatus() async {
    try {
      final data = await ApiService.getAsthmaDiaryStatus();
      setState(() {
        measurementDate = data['measurementDate'] ?? '2025/12/10';
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

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      content: currentView == 0
          ? AsthmaDiaryView(
              measurementDate: measurementDate,
              isAssessmentCompleted: isAssessmentCompleted,
              measurementTime: measurementTime,
              onSwitchView: _switchView,
            )
          : AsthmaDiaryFormView(
              measurementDate: measurementDate,
              isAssessmentCompleted: isAssessmentCompleted,
              onSwitchView: _switchView,
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
