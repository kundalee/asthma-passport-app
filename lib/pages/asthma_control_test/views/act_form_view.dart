import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../services/api_service.dart';

class ActFormView extends StatefulWidget {
  final String measurementDate;
  final bool isAdultTest;
  final Function(int) onSwitchView;
  final Function(Map<String, dynamic>) onAssessmentCalculated;
  final VoidCallback? onSubmitAssessment;

  const ActFormView({
    super.key,
    required this.measurementDate,
    required this.isAdultTest,
    required this.onSwitchView,
    required this.onAssessmentCalculated,
    this.onSubmitAssessment,
  });

  @override
  State<ActFormView> createState() => _ActFormViewState();
}

class _ActFormViewState extends State<ActFormView> {
  List<int?> answers = [];
  List<Map<String, dynamic>> questionsData = [];
  int currentQuestion = 0;
  bool isSubmitted = false;
  int? totalScore;
  int? controlLevel;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await ApiService.getActQuestions(widget.isAdultTest);
      setState(() {
        questionsData = List<Map<String, dynamic>>.from(data);
        answers = List<int?>.filled(questionsData.length, null);
      });
    } catch (e) {
      // Keep default values if API fails
    }
  }

  bool _isAnswered(int index) {
    return answers[index] != null;
  }

  @override
  Widget build(BuildContext context) {
    if (questionsData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 12),
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
            questionsData.length * 2 - 1,
            (index) {
              final isCircle = index.isEven;
              final questionIndex = index ~/ 2;

              if (isCircle) {
                return SvgPicture.asset(
                  questionIndex <= currentQuestion ? 'assets/icons/select-on.svg' : 'assets/icons/select-off.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
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
        children: [
          _buildQuestion(),
          const SizedBox(height: 20),
          const Divider(color: AppColors.photoBackground, thickness: 2),
          const SizedBox(height: 20),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    if (questionsData.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentQuestionData = questionsData[currentQuestion];
    final questionOptions = List<Map<String, dynamic>>.from(currentQuestionData['options'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 20),
        ...List.generate(
          questionOptions.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < questionOptions.length - 1 ? 20 : 0),
            child: _buildOption(
              questionOptions[index]['label'] ?? '',
              questionOptions[index]['id'] ?? (index + 1),
              answers[currentQuestion],
              (value) {
                setState(() {
                  answers[currentQuestion] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String label, int value, int? selectedValue, Function(int) onChanged) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 37,
        // padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.resultGoodBg : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.inputBorder,
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
                style: TextStyle(
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

  Future<void> _submitTest() async {
    try {
      final result = await ApiService.calculateActResult(
        isAdultTest: widget.isAdultTest,
        answers: answers,
      );
      setState(() {
        totalScore = result['totalScore'];
        controlLevel = result['controlLevel'];
        isSubmitted = true;
      });
      widget.onAssessmentCalculated(result);
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildNavigation() {
    final isLastQuestion = currentQuestion == questionsData.length - 1;
    return Column(
      children: [
        CustomButton(
          text: isLastQuestion ? '提交測驗' : '下一題',
          onPressed: _isAnswered(currentQuestion)
              ? () {
                  if (isLastQuestion) {
                    _submitTest();
                  } else {
                    setState(() {
                      currentQuestion++;
                    });
                  }
                }
              : () {},
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          height: 37,
          borderRadius: 4,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: '上一題',
          onPressed: currentQuestion > 0
              ? () {
                  setState(() {
                    currentQuestion--;
                  });
                }
              : () {},
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          border: BorderSide(color: AppColors.inputBorder, width: 1),
          height: 37,
          borderRadius: 4,
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultsTitle(),
          const SizedBox(height: 20),
          _buildScoreAndStatusBox(),
          const SizedBox(height: 20),
          _buildCompleteButton(),
        ],
      ),
    );
  }

  Color _getControlLevelBgColor() {
    if (widget.isAdultTest) {
      switch (controlLevel) {
        case 1:
          return AppColors.resultGoodBg;
        case 2:
          return AppColors.resultModerateBg;
        case 3:
          return AppColors.resultSevereBg;
        default:
          return Colors.grey.shade100;
      }
    } else {
      // Child test colors - only 2 levels
      switch (controlLevel) {
        case 1:
          return AppColors.resultGoodBg;
        case 2:
          return AppColors.resultModerateBg;
        default:
          return Colors.grey.shade100;
      }
    }
  }

  Color _getControlLevelBorderColor() {
    if (widget.isAdultTest) {
      switch (controlLevel) {
        case 1:
          return AppColors.statusGoodBorder;
        case 2:
          return AppColors.statusModerateBorder;
        case 3:
          return AppColors.statusSevereBorder;
        default:
          return Colors.grey;
      }
    } else {
      // Child test colors - only 2 levels
      switch (controlLevel) {
        case 1:
          return AppColors.statusGoodBorder;
        case 2:
          return AppColors.statusModerateBorder;
        default:
          return Colors.grey;
      }
    }
  }

  Color _getStatusTextColor() {
    if (widget.isAdultTest) {
      switch (controlLevel) {
        case 1:
          return AppColors.statusGoodText;
        case 2:
          return AppColors.statusModerateText;
        case 3:
          return AppColors.statusSevereText;
        default:
          return Colors.black;
      }
    } else {
      // Child test colors - only 2 levels
      switch (controlLevel) {
        case 1:
          return AppColors.statusGoodText;
        case 2:
          return AppColors.statusModerateText;
        default:
          return Colors.black;
      }
    }
  }

  String _getControlLevelIcon() {
    if (widget.isAdultTest) {
      switch (controlLevel) {
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
      // Child test icons
      switch (controlLevel) {
        case 1:
          return 'assets/icons/check.svg';
        case 2:
          return 'assets/icons/alert-info.svg';
        default:
          return 'assets/icons/check.svg';
      }
    }
  }

  String _getControlLevelAdvice() {
    if (widget.isAdultTest) {
      switch (controlLevel) {
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
      // Child test messages
      switch (controlLevel) {
        case 1:
          return '您的小孩氣喘控制良好';
        case 2:
          return '您的小孩氣喘並未獲得良好的控制。建議與醫師一起討論結果，詢問是否需要改變氣喘治療計劃';
        default:
          return '';
      }
    }
  }

  Widget _buildCompleteButton() {
    return CustomButton(
      text: '完成紀錄',
      onPressed: () {
        widget.onSubmitAssessment?.call();
        widget.onSwitchView(0);
      },
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryGreen,
      height: 37,
      borderRadius: 4,
    );
  }

  Widget _buildResultsTitle() {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/document.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreBox(),
          const SizedBox(height: 12),
          _buildAdviceBox(),
        ],
      ),
    );
  }

  Widget _buildScoreBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '總分',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.menuSubtitle,
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
    );
  }

  Widget _buildAdviceBox() {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _getControlLevelBgColor(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getControlLevelBorderColor(), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            _getControlLevelIcon(),
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(_getStatusTextColor(), BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _getControlLevelAdvice(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getStatusTextColor(),
                height: 1.71,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
