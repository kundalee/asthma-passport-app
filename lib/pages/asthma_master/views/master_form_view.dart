import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/master_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/form_card.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../services/api_service.dart';

class MasterFormView extends StatefulWidget {
  final Function(int) onSwitchView;
  final VoidCallback? onSubmitQuiz;

  const MasterFormView({
    super.key,
    required this.onSwitchView,
    this.onSubmitQuiz,
  });

  @override
  State<MasterFormView> createState() => _MasterFormViewState();
}

class _MasterFormViewState extends State<MasterFormView> {
  List<MasterQuestion> masterQuestions = [];
  List<Map<String, dynamic>> questionsData = [];
  MasterQuizResult? quizResult;
  List<int?>? _submittedAnswers;
  bool _showingReview = false;
  // Bumped every time 查看作答結果 is pressed, so the FormCard key below
  // always changes and remounts fresh even when already in review mode
  // (otherwise a second press reuses the FormCard state left on its own
  // result screen from the previous review pass).
  int _reviewToken = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result = await ApiService.getMasterQuestions();
    if (result.success && result.data != null) {
      setState(() {
        masterQuestions = result.data!.questions;
        questionsData = masterQuestions
          .map((q) => {
            'title': q.text,
            'options': q.options.map((o) => {'id': o.id, 'label': o.text}).toList(),
          })
          .toList();
      });
    }
  }

  Future<void> _submitQuiz(List<int?> answers) async {
    final payload = <Map<String, dynamic>>[];
    for (int i = 0; i < masterQuestions.length && i < answers.length; i++) {
      final selectedId = answers[i];
      if (selectedId == null) continue;
      final option = masterQuestions[i].options.firstWhere(
        (o) => o.id == selectedId,
        orElse: () => const MasterOption(id: -1, code: '', text: ''),
      );
      payload.add({'question_id': masterQuestions[i].id, 'selected_option_code': option.code});
    }

    final result = await ApiService.saveMasterQuiz(payload);
    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        quizResult = result.data;
        _submittedAnswers = answers;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗')),
      );
    }
  }

  bool get _isMaster {
    final result = quizResult;
    return result != null && masterQuestions.isNotEmpty && result.correctAnswersCount == masterQuestions.length;
  }

  @override
  Widget build(BuildContext context) {
    if (questionsData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormCard(
      key: ValueKey('$_showingReview-$_reviewToken'),
      questionsData: questionsData,
      resultWidget: _buildResultWidget(),
      onSubmit: (answers) async {
        await _submitQuiz(answers);
      },
      initialAnswers: _showingReview ? _submittedAnswers : null,
      readOnly: _showingReview,
    );
  }

  Widget _buildResultWidget() {
    return SingleChildScrollView(
      child: CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        borderRadius: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            _buildResultIcon(),
            _buildResultTitleAndSubtitle(),
            _buildScoreSection(),
            _buildReturnButton(),
            _buildRetestButton(),
            _buildViewAnswersButton(),
            _buildFooterText(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    final iconColor = _isMaster ? AppColors.mustardGold : AppColors.digitalRed;
    final iconPath = _isMaster ? 'assets/icons/crown.svg' : 'assets/icons/alert-info.svg';

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 40,
          height: 40,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildResultTitleAndSubtitle() {
    return Column(
      spacing: 12,
      children: [
        Text(
          quizResult?.summaryTitle ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.0,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          quizResult?.summarySubtitle ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        spacing: 12,
        children: [
          const Text(
            '最終成績',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          Text(
            '${quizResult?.finalScore ?? 0} 分',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: '返回首頁',
        onPressed: () {
          widget.onSubmitQuiz?.call();
          Navigator.of(context).pushReplacementNamed('/');
        },
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryGreen,
        height: 37,
        borderRadius: 4,
      ),
    );
  }

  Widget _buildRetestButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: '再測一次',
        onPressed: () {
          setState(() {
            quizResult = null;
            _submittedAnswers = null;
            _showingReview = false;
          });
          _loadQuestions();
          widget.onSwitchView(0);
        },
        foregroundColor: Colors.white,
        backgroundColor: AppColors.sportyBlue,
        height: 37,
        borderRadius: 4,
      ),
    );
  }

  Widget _buildViewAnswersButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: '查看作答結果',
        onPressed: () => setState(() {
          _showingReview = true;
          _reviewToken++;
        }),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        border: BorderSide(color: AppColors.secondaryGray2, width: 1),
        height: 37,
        borderRadius: 4,
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      '本測驗僅供衛教參考，如有醫療需求請諮詢專業醫師',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.hydrocarbon,
        height: 1.71,
        letterSpacing: 0,
      ),
      textAlign: TextAlign.center,
    );
  }
}
