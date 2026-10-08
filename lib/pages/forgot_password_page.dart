import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_dialog.dart';
import '../components/custom_text_field.dart';
import 'verify_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  void _handleSubmit() {
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = '您輸入的信箱有誤，請重新輸入');
      return;
    }
    // TODO: call the forgot-password API once the backend provides it.
    final email = _emailController.text.trim();
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        iconPath: 'assets/icons/checkup.svg',
        iconColor: null,
        iconBackgroundColor: AppColors.primaryGreen,
        content: '驗證碼已寄出。\n請確認您的電子信箱。',
        onButtonPressed: () {
          Navigator.pop(dialogContext);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyCodePage(email: email)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      header: _buildHeader(context),
      content: _buildContent(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '忘記密碼',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              const Text.rich(
                TextSpan(
                  text: '請輸入您註冊時的電子信箱',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                  children: [
                    TextSpan(text: '*', style: TextStyle(color: AppColors.primaryRed)),
                  ],
                ),
              ),
              CustomTextField(
                controller: _emailController,
                hintText: '電子信箱',
                prefixIcon: SvgPicture.asset(
                  'assets/icons/mail.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                errorText: _emailError,
              ),
            ],
          ),
          ListenableBuilder(
            listenable: _emailController,
            builder: (context, _) {
              return CustomButton(
                text: '送出',
                onPressed: _emailController.text.trim().isNotEmpty ? _handleSubmit : null,
                backgroundColor: AppColors.primaryGreen,
              );
            },
          ),
        ],
      ),
    );
  }
}
