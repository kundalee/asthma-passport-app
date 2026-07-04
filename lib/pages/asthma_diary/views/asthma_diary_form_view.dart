import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/diary_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';
import '../../../services/api_service.dart';

class AsthmaDiaryFormView extends StatefulWidget {
  final String dateStr;
  final String measurementDate;
  final bool isAssessmentCompleted;
  final List<DiaryQuestion> questions;
  final int? totalScore;
  final String? statusSummary;
  final Function(int) onSwitchView;
  final VoidCallback onSaved;

  const AsthmaDiaryFormView({
    super.key,
    required this.dateStr,
    required this.measurementDate,
    required this.isAssessmentCompleted,
    required this.questions,
    required this.totalScore,
    required this.statusSummary,
    required this.onSwitchView,
    required this.onSaved,
  });

  @override
  State<AsthmaDiaryFormView> createState() => _AsthmaDiaryFormViewState();
}

class _AsthmaDiaryFormViewState extends State<AsthmaDiaryFormView> {
  late List<int?> selectedAnswers;
  bool isEditMode = false;
  bool isSubmitted = false;
  int? totalScore;
  String? statusSummary;

  @override
  void initState() {
    super.initState();
    selectedAnswers = widget.questions.map((q) => q.selectedOptionId).toList();
  }

  Future<void> _saveDiary() async {
    final result = await ApiService.saveDiary(
      dateStr: widget.dateStr,
      questions: widget.questions,
      selectedOptionIds: selectedAnswers,
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        totalScore = result.data!.totalScore;
        statusSummary = result.data!.statusSummary;
        isSubmitted = true;
      });
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗')),
      );
    }
  }

  int _scoreForSelected(List<DiaryOption> options, int? selectedId) {
    if (selectedId == null) return 0;
    return options
        .firstWhere(
          (o) => o.id == selectedId,
          orElse: () => const DiaryOption(id: -1, order: 0, text: '', score: 0),
        )
        .score;
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildDateSection(),
          CardContainer(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            borderRadius: 10,
            child: Column(
              spacing: 16,
              children: [
                _buildFormHeaderContent(),
                ...List.generate(
                  questions.length,
                  (index) {
                    final question = questions[index];
                    return Column(
                      spacing: 16,
                      children: [
                        question.isYesNo
                            ? _buildYesNoQuestion(
                                number: question.order,
                                title: question.text,
                                options: question.options,
                                selectedValue: selectedAnswers[index],
                                onChanged: (value) => setState(() => selectedAnswers[index] = value),
                              )
                            : _buildScaleQuestion(
                                number: question.order,
                                title: question.text,
                                options: question.options,
                                selectedValue: selectedAnswers[index],
                                onChanged: (value) => setState(() => selectedAnswers[index] = value),
                              ),
                        if (index < questions.length - 1)
                          Divider(color: AppColors.sweetGrey, height: 2),
                      ],
                    );
                  },
                ),
                if (!isSubmitted && (!widget.isAssessmentCompleted || isEditMode))
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: '完成紀錄',
                      onPressed: _saveDiary,
                      backgroundColor: AppColors.funGreen,
                      padding: const EdgeInsets.all(12),
                      borderRadius: 4,
                      height: 37,
                    ),
                  ),
                if (isSubmitted) _buildResultsSummary(score: totalScore ?? 0, message: statusSummary ?? ''),
                if (widget.isAssessmentCompleted && !isEditMode && !isSubmitted)
                  _buildResultsSummary(score: widget.totalScore ?? 0, message: widget.statusSummary ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeaderContent() {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset(
          'assets/icons/document.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
        ),
        const Text(
          '症狀評分記錄表',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      borderRadius: 10,
      child: Row(
        spacing: 12,
        children: [
          SvgPicture.asset(
            'assets/icons/calendar.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
          ),
          Text(
            '測驗日期：${widget.measurementDate}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.mirage,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion({
    required int number,
    required String title,
    required List<DiaryOption> options,
    required int? selectedValue,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$number. $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.71,
                letterSpacing: 0,
              ),
            ),
            Container(
              width: 48,
              height: 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.zumthor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.crystalBlue, width: 1),
              ),
              child: Center(
                child: Text(
                  '${_scoreForSelected(options, selectedValue)} 分',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: List.generate(
            options.length,
            (index) {
              final option = options[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < options.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onChanged(option.id),
                  child: Container(
                    height: 37,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedValue == option.id ? AppColors.honeydew : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selectedValue == option.id ? AppColors.funGreen : AppColors.whiteMarble,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      spacing: 24,
                      children: [
                        SvgPicture.asset(
                          selectedValue == option.id ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                          width: 24,
                          height: 24,
                        ),
                        Text(
                          option.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.0,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScaleQuestion({
    required int number,
    required String title,
    required List<DiaryOption> options,
    required int? selectedValue,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        // Title and score
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$number. $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.71,
                letterSpacing: 0,
              ),
            ),
            Container(
              width: 48,
              height: 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.zumthor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.crystalBlue, width: 1),
              ),
              child: Center(
                child: Text(
                  '${_scoreForSelected(options, selectedValue)} 分',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 4,
          children: [
            for (int index = 0; index < options.length; index++)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(color: _getScaleBarColor(index)),
                    ),
                    GestureDetector(
                      onTap: () => onChanged(options[index].id),
                      child: SvgPicture.asset(
                        selectedValue == options[index].id ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${options[index].score}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.hydrocarbon,
                            height: 1.0,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          options[index].text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.hydrocarbon,
                            height: 1.0,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getScaleBarColor(int index) {
    final colors = [
      AppColors.funGreen,
      AppColors.conifer,
      AppColors.mustardGold,
      AppColors.comfortingLightRed,
      AppColors.digitalRed,
    ];
    return colors[index];
  }

  Widget _buildResultsSummary({required int score, required String message}) {
    final isGood = score <= 2;
    final statusColor = isGood ? AppColors.funGreen : Colors.red;
    final statusBgColor = isGood ? AppColors.honeydew : AppColors.babysBottom;
    final statusIcon = isGood ? 'assets/icons/check.svg' : 'assets/icons/undone.svg';

    return Column(
      spacing: 16,
      children: [
        CardContainer(
          padding: const EdgeInsets.all(16),
          backgroundColor: AppColors.luxuryWhite,
          borderRadius: 10,
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '總分',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.hydrocarbon,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    '$score 分',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isGood ? AppColors.lightPastelMint : AppColors.eva,
                    width: 2,
                  ),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    SvgPicture.asset(
                      statusIcon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
                    ),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '返回首頁',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            backgroundColor: AppColors.funGreen,
            padding: const EdgeInsets.all(12),
            borderRadius: 4,
            height: 37,
          ),
        ),
      ],
    );
  }
}
