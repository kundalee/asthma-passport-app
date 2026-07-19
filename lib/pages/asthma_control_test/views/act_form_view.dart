import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/act_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/form_card.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../services/api_service.dart';

class ActFormView extends StatefulWidget {
  final String measurementDate;
  final String recordDate;
  final bool isAdultTest;
  final List<ActQuestion> questions;
  final Function(int) onSwitchView;
  final Function(Map<String, dynamic>) onAssessmentCalculated;

  const ActFormView({
    super.key,
    required this.measurementDate,
    required this.recordDate,
    required this.isAdultTest,
    required this.questions,
    required this.onSwitchView,
    required this.onAssessmentCalculated,
  });

  @override
  State<ActFormView> createState() => _ActFormViewState();
}

class _ActFormViewState extends State<ActFormView> {
  int? totalScore;
  int? controlLevel;

  List<Map<String, dynamic>> get questionsData {
    return widget.questions
        .map((q) => {
              'title': q.text,
              'options': q.options.map((o) => {'id': o.id, 'label': o.text}).toList(),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (questionsData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormCard(
      questionsData: questionsData,
      resultWidget: _buildResultWidget(),
      onSubmit: (answers) async {
        await _submitTest(answers);
      },
    );
  }

  Widget _buildResultWidget() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          _buildResultsTitle(),
          _buildScoreAndStatusBox(),
          CustomButton(
            text: '完成紀錄',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryGreen,
            height: 37,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTitle() {
    return SizedBox(
      height: 24,
      child: Row(
        spacing: 8,
        children: [
          SvgPicture.asset(
            'assets/icons/document.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
          ),
          const Text(
            '測驗結果',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndStatusBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '總分',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hydrocarbon,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
              Text(
                '${totalScore ?? 0} 分',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: _getControlLevelBgColor(controlLevel),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _getControlLevelBorderColor(controlLevel), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                SvgPicture.asset(
                  _getControlLevelIcon(controlLevel),
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(_getStatusTextColor(controlLevel), BlendMode.srcIn),
                ),
                Flexible(
                  child: Text(
                    _getControlLevelAdvice(controlLevel),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getStatusTextColor(controlLevel),
                      height: 1.71,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest(List<int?> answers) async {
    final payload = <Map<String, dynamic>>[];
    for (var i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selectedOptionId = answers[i];
      final selectedOption = question.options.firstWhere((o) => o.id == selectedOptionId);
      payload.add({'question_id': question.id, 'selected_value': selectedOption.score});
    }

    final result = await ApiService.saveAct(widget.recordDate, payload);
    if (!mounted) return;

    if (result.success && result.data != null) {
      final calculated = {
        'totalScore': result.data!.totalScore,
        'controlLevel': result.data!.statusSummary,
      };
      setState(() {
        totalScore = calculated['totalScore'];
        controlLevel = calculated['controlLevel'];
      });
      widget.onAssessmentCalculated(calculated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗')),
      );
    }
  }

  Color _getControlLevelBgColor(int? level) {
    if (widget.isAdultTest) {
      switch (level) {
        case 1:
          return AppColors.honeydew;
        case 2:
          return AppColors.secondaryYellow;
        case 3:
          return AppColors.babysBottom;
        default:
          return Colors.grey.shade100;
      }
    } else {
      switch (level) {
        case 1:
          return AppColors.honeydew;
        case 2:
          return AppColors.secondaryYellow;
        default:
          return Colors.grey.shade100;
      }
    }
  }

  Color _getControlLevelBorderColor(int? level) {
    if (widget.isAdultTest) {
      switch (level) {
        case 1:
          return AppColors.lightPastelMint;
        case 2:
          return AppColors.darkYellow;
        case 3:
          return AppColors.spicyPastelPink;
        default:
          return Colors.grey;
      }
    } else {
      switch (level) {
        case 1:
          return AppColors.lightPastelMint;
        case 2:
          return AppColors.darkYellow;
        default:
          return Colors.grey;
      }
    }
  }

  Color _getStatusTextColor(int? level) {
    if (widget.isAdultTest) {
      switch (level) {
        case 1:
          return AppColors.primaryGreen;
        case 2:
          return AppColors.windsorTan;
        case 3:
          return AppColors.digitalRed;
        default:
          return Colors.black;
      }
    } else {
      switch (level) {
        case 1:
          return AppColors.primaryGreen;
        case 2:
          return AppColors.windsorTan;
        default:
          return Colors.black;
      }
    }
  }

  String _getControlLevelIcon(int? level) {
    if (widget.isAdultTest) {
      switch (level) {
        case 1:
          return 'assets/icons/check.svg';
        case 2:
          return 'assets/icons/alert-info.svg';
        case 3:
          return 'assets/icons/undone.svg';
        default:
          return 'assets/icons/check.svg';
      }
    } else {
      switch (level) {
        case 1:
          return 'assets/icons/check.svg';
        case 2:
          return 'assets/icons/alert-info.svg';
        default:
          return 'assets/icons/check.svg';
      }
    }
  }

  String _getControlLevelAdvice(int? level) {
    if (widget.isAdultTest) {
      switch (level) {
        case 1:
          return '在過去4週中，氣喘得到全面控制';
        case 2:
          return '在過去4週中，氣喘控制良好，但尚未全面獲得控制';
        case 3:
          return '在過去4週中，氣喘未受到控制';
        default:
          return '';
      }
    } else {
      switch (level) {
        case 1:
          return '您的小孩氣喘控制良好';
        case 2:
          return '您的小孩氣喘並未獲得良好的控制。建議與醫師一起討論結果，詢問是否需要改變氣喘治療計劃';
        default:
          return '';
      }
    }
  }

}
