import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import './card_container.dart';
import './custom_button.dart';

class FormCard extends StatefulWidget {
  final List<Map<String, dynamic>> questionsData;
  final Widget resultWidget;
  final Function(List<int?>) onSubmit;
  final List<int?>? initialAnswers;
  final bool readOnly;

  const FormCard({
    super.key,
    required this.questionsData,
    required this.resultWidget,
    required this.onSubmit,
    this.initialAnswers,
    this.readOnly = false,
  });

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  late List<int?> answers;
  int currentStep = 0;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    answers = widget.initialAnswers != null
        ? List<int?>.from(widget.initialAnswers!)
        : List<int?>.filled(widget.questionsData.length, null);
  }

  bool _isAnswered(int index) {
    return answers[index] != null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          _buildProgressIndicator(),
          isSubmitted ? _buildResultsSection() : _buildQuestionSection(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      height: 54,
      child: CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            widget.questionsData.length * 2 - 1,
            (index) {
              final isCircle = index.isEven;
              final questionIndex = index ~/ 2;

              if (isCircle) {
                return SvgPicture.asset(
                  questionIndex <= currentStep ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryGreen,
                    BlendMode.srcIn,
                  ),
                );
              } else {
                return Expanded(
                  child: Container(
                    height: 4,
                    color: AppColors.primaryGreen,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          _buildQuestion(),
          const Divider(color: AppColors.sweetGrey, thickness: 2),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    if (widget.questionsData.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentQuestionData = widget.questionsData[currentStep];
    final questionOptions = List<Map<String, dynamic>>.from(currentQuestionData['options'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Text(
          currentQuestionData['title'] ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
        ...List.generate(
          questionOptions.length,
          (index) => _buildOption(
            questionOptions[index]['label'] ?? '',
            questionOptions[index]['id'] ?? (index + 1),
            answers[currentStep],
            widget.readOnly
                ? null
                : (value) {
                    setState(() {
                      answers[currentStep] = value;
                    });
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String label, int value, int? selectedValue, Function(int)? onChanged) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged(value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 37),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.honeydew : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.secondaryGrayW,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    final isLastQuestion = currentStep == widget.questionsData.length - 1;
    return Column(
      spacing: 12,
      children: [
        CustomButton(
          text: isLastQuestion ? '完成作答' : '下一題',
          onPressed: _isAnswered(currentStep)
              ? () {
                  if (isLastQuestion) {
                    if (!widget.readOnly) {
                      widget.onSubmit(answers);
                    }
                    setState(() {
                      isSubmitted = true;
                    });
                  } else {
                    setState(() {
                      currentStep++;
                    });
                  }
                }
              : null,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          height: 37,
          borderRadius: 4,
        ),
        CustomButton(
          text: '上一題',
          onPressed: currentStep > 0
              ? () {
                  setState(() {
                    currentStep--;
                  });
                }
              : null,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          border: BorderSide(color: AppColors.secondaryGrayW, width: 1),
          height: 37,
          borderRadius: 4,
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return widget.resultWidget;
  }
}
