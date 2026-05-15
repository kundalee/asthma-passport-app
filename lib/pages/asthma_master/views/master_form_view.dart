import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<Map<String, dynamic>> questionsData = [];
  int? totalScore;
  int? resultLevel;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await ApiService.getMasterQuestions();
      setState(() {
        questionsData = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      // Keep default values if API fails
    }
  }

  Future<void> _submitQuiz(List<int?> answers) async {
    try {
      final result = await ApiService.calculateMasterResult(answers: answers);
      setState(() {
        totalScore = result['totalScore'];
        resultLevel = result['resultLevel'];
      });
    } catch (e) {
      // Handle error
    }
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
        await _submitQuiz(answers);
      },
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
            _buildFooterText(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    final iconColor = resultLevel == 1 ? AppColors.mustardGold : AppColors.digitalRed;
    final iconPath = resultLevel == 1 ? 'assets/icons/crown.svg' : 'assets/icons/alert-info.svg';

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
          _getResultTitle(),
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
          _getResultSubtitle(),
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
            '${totalScore ?? 0} 分',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w500,
              color: AppColors.funGreen,
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
        backgroundColor: AppColors.funGreen,
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
            totalScore = null;
            resultLevel = null;
          });
          _loadQuestions();
          widget.onSwitchView(0);
        },
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        border: BorderSide(color: AppColors.whiteMarble, width: 1),
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

  String _getResultTitle() {
    return resultLevel == 1 ? '恭喜！氣喘達人' : '差一點就是達人了！';
  }

  String _getResultSubtitle() {
    return resultLevel == 1
        ? '你對氣喘防護有著頂尖的認識！'
        : '你對氣喘防護的認識還不夠全面！';
  }
}
