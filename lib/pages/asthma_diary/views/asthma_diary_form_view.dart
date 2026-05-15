import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';
import '../../../services/api_service.dart';

class AsthmaDiaryFormView extends StatefulWidget {
  final String measurementDate;
  final bool isAssessmentCompleted;
  final Function(int) onSwitchView;

  const AsthmaDiaryFormView({
    super.key,
    required this.measurementDate,
    required this.isAssessmentCompleted,
    required this.onSwitchView,
  });

  @override
  State<AsthmaDiaryFormView> createState() => _AsthmaDiaryFormViewState();
}

class _AsthmaDiaryFormViewState extends State<AsthmaDiaryFormView> {
  late List<int?> selectedAnswers;
  late Future<List<Map<String, dynamic>>> questionsFuture;
  bool isEditMode = false;
  bool isSubmitted = false;
  int? totalScore;
  int? controlLevel;
  String? controlStatus;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List<int?>.filled(5, null);
    questionsFuture = _loadQuestions();
  }

  Future<List<Map<String, dynamic>>> _loadQuestions() async {
    final questions = await ApiService.getAssessmentQuestions();
    if (mounted) {
      setState(() {
        for (int i = 0; i < questions.length; i++) {
          selectedAnswers[i] = questions[i]['selected_option_id'] ?? 0;
        }
      });
    }
    return questions;
  }

  Future<void> _saveAssessment() async {
    try {
      final result = await ApiService.calculateAssessmentResult(
        answers: selectedAnswers,
      );

      if (mounted) {
        setState(() {
          totalScore = result['totalScore'];
          controlLevel = result['controlLevel'];
          controlStatus = _getControlStatusMessage(result['controlLevel']);
          isSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: $e')),
        );
      }
    }
  }

  String _getControlStatusMessage(int level) {
    switch (level) {
      case 1:
        return '症狀控制良好，請繼續維持';
      case 2:
        return '控制不佳，建議用藥或回診';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildDateSection(),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final questions = snapshot.data ?? [];

              return CardContainer(
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
                            question['type'] == 'yes_no'
                                ? _buildYesNoQuestion(
                                    number: question['number'],
                                    title: question['title'],
                                    options: List<Map<String, dynamic>>.from(question['options'] ?? []),
                                    selectedValue: selectedAnswers[index],
                                    onChanged: (value) => setState(() => selectedAnswers[index] = value),
                                  )
                                : _buildScaleQuestion(
                                    number: question['number'],
                                    title: question['title'],
                                    options: List<Map<String, dynamic>>.from(question['options'] ?? []),
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
                          text: '儲存記錄',
                          onPressed: _saveAssessment,
                          backgroundColor: AppColors.funGreen,
                          padding: const EdgeInsets.all(12),
                          borderRadius: 4,
                          height: 37,
                        ),
                      ),
                    if (isSubmitted) _buildResultsSummary(),
                    if (widget.isAssessmentCompleted && !isEditMode && !isSubmitted) _buildResultsSummary(),
                  ],
                ),
              );
            },
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
    required List<Map<String, dynamic>> options,
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
                  selectedValue != null ? '$selectedValue 分' : '0 分',
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
                  onTap: () => onChanged(option['id'] as int),
                  child: Container(
                    height: 37,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedValue == option['id'] ? AppColors.honeydew : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selectedValue == option['id'] ? AppColors.funGreen : AppColors.whiteMarble,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      spacing: 24,
                      children: [
                        SvgPicture.asset(
                          selectedValue == option['id'] ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                          width: 24,
                          height: 24,
                        ),
                        Text(
                          option['label'] as String,
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
    required List<Map<String, dynamic>> options,
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
                  selectedValue != null ? '$selectedValue 分' : '0 分',
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
            for (int index = 0; index < 5; index++)
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
                      onTap: () => onChanged(index),
                      child: SvgPicture.asset(
                        selectedValue == index ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${options[index]['id']}',
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
                          options[index]['label'] as String,
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

  Widget _buildResultsSummary() {
    final isGood = controlLevel == 1;
    final statusColor = isGood ? AppColors.funGreen : Colors.red;
    final statusBgColor = isGood ? AppColors.honeydew : AppColors.babysBottom;
    final statusIcon = isGood ? 'assets/icons/check.svg' : 'assets/icons/undone.svg';
    final statusMessage = controlStatus ?? '';

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
                    '$totalScore 分',
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
                        statusMessage,
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
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '編輯記錄',
            onPressed: () => setState(() => isSubmitted = false),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            border: const BorderSide(color: AppColors.whiteMarble, width: 1),
            padding: const EdgeInsets.all(12),
            borderRadius: 4,
            height: 37,
          ),
        ),
      ],
    );
  }

}
