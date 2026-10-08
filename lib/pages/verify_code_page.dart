import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import 'reset_password_page.dart';

class VerifyCodePage extends StatefulWidget {
  // The address the code was sent to, for verifying it with the backend.
  final String email;

  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController _codeController = TextEditingController();
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      if (_codeError != null) setState(() => _codeError = null);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // TODO: verify the code via the forgot-password API once the backend
    // provides it; until then 123456 is the only accepted test code.
    if (_codeController.text.trim() != '123456') {
      setState(() => _codeError = '您輸入的驗證碼有誤，請重新輸入');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage(email: widget.email)),
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
            '輸入驗證碼',
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
                  text: '請輸入收到的驗證碼',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                  children: [
                    TextSpan(text: '*', style: TextStyle(color: AppColors.primaryRed)),
                  ],
                ),
              ),
              CustomTextField(
                controller: _codeController,
                hintText: '驗證碼',
                errorText: _codeError,
              ),
            ],
          ),
          ListenableBuilder(
            listenable: _codeController,
            builder: (context, _) {
              return CustomButton(
                text: '送出',
                onPressed: _codeController.text.trim().isNotEmpty ? _handleSubmit : null,
                backgroundColor: AppColors.primaryGreen,
              );
            },
          ),
        ],
      ),
    );
  }
}
