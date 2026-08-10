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
  final bool isAssessmentCompleted;
  final int? totalScore;
  final int? statusColor;
  final String? statusSummary;
  final Function(int) onSwitchView;
  final Function(Map<String, dynamic>) onAssessmentCalculated;

  const ActFormView({
    super.key,
    required this.measurementDate,
    required this.recordDate,
    required this.isAdultTest,
    required this.questions,
    required this.isAssessmentCompleted,
    required this.totalScore,
    required this.statusColor,
    required this.statusSummary,
    required this.onSwitchView,
    required this.onAssessmentCalculated,
  });

  @override
  State<ActFormView> createState() => _ActFormViewState();
}

class _ActFormViewState extends State<ActFormView> {
  late int? totalScore;
  late int? statusColor;
  late String? statusSummary;

  @override
  void initState() {
    super.initState();
    totalScore = widget.totalScore;
    statusColor = widget.statusColor;
    statusSummary = widget.statusSummary;
  }

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
    if (widget.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormCard(
      questionsData: questionsData,
      resultWidget: _buildResultWidget(),
      // Already recorded today: walk through the same questions with the
      // saved answers locked in, instead of presenting a blank test to redo.
      initialAnswers: widget.isAssessmentCompleted ? widget.questions.map((q) => q.selectedOptionId).toList() : null,
      readOnly: widget.isAssessmentCompleted,
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
            text: widget.isAssessmentCompleted ? '返回首頁' : '完成紀錄',
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
              color: _getControlLevelBgColor(statusColor),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _getControlLevelBorderColor(statusColor), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                SvgPicture.asset(
                  _getControlLevelIcon(statusColor),
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(_getStatusTextColor(statusColor), BlendMode.srcIn),
                ),
                Flexible(
                  child: Text(
                    statusSummary ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getStatusTextColor(statusColor),
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

    final result = await ApiService.saveAct(widget.recordDate, widget.isAdultTest ? 'adult' : 'child', payload);
    if (!mounted) return;

    if (result.success && result.data != null) {
      final calculated = {
        'totalScore': result.data!.totalScore,
        'statusColor': result.data!.statusColor,
        'statusSummary': result.data!.statusSummary,
      };
      setState(() {
        totalScore = calculated['totalScore'] as int?;
        statusColor = calculated['statusColor'] as int?;
        statusSummary = calculated['statusSummary'] as String?;
      });
      widget.onAssessmentCalculated(calculated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗')),
      );
    }
  }

  Color _getControlLevelBgColor(int? level) {
    switch (level) {
      case 0:
        return AppColors.honeydew;
      case 1:
        return AppColors.secondaryYellow;
      case 2:
        return AppColors.babysBottom;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getControlLevelBorderColor(int? level) {
    switch (level) {
      case 0:
        return AppColors.lightPastelMint;
      case 1:
        return AppColors.darkYellow;
      case 2:
        return AppColors.spicyPastelPink;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(int? level) {
    switch (level) {
      case 0:
        return AppColors.primaryGreen;
      case 1:
        return AppColors.windsorTan;
      case 2:
        return AppColors.digitalRed;
      default:
        return Colors.black;
    }
  }

  String _getControlLevelIcon(int? level) {
    switch (level) {
      case 0:
        return 'assets/icons/check.svg';
      case 1:
        return 'assets/icons/alert-info.svg';
      case 2:
        return 'assets/icons/undone.svg';
      default:
        return 'assets/icons/check.svg';
    }
  }
}
