import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../services/auth_service.dart';
import 'password_changed_page.dart';

class ResetPasswordPage extends StatefulWidget {
  // Issued by /user/verify once the emailed code checks out; authorizes
  // /user/reset for that account.
  final String resetToken;

  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = false;
  bool _obscureConfirmPassword = false;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });
    _confirmPasswordController.addListener(() {
      if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 6-20 letters/digits with at least one uppercase letter, per the hint below the field.
  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])[A-Za-z0-9]{6,20}$').hasMatch(password);
  }

  Future<void> _handleSubmit() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final passwordError = _isValidPassword(password) ? null : '您輸入的密碼格式有誤，請重新輸入';
    final confirmPasswordError = password == confirmPassword ? null : '您輸入的密碼不符，請重新輸入';
    setState(() {
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });
    if (passwordError != null || confirmPasswordError != null) return;

    setState(() => _isLoading = true);
    final result = await AuthService.resetPassword(widget.resetToken, password, confirmPassword);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.success) {
      setState(() => _passwordError = result.message);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PasswordChangedPage()),
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
            '設定新密碼',
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
              _buildLabel('請輸入您的新密碼'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPasswordField(
                    controller: _passwordController,
                    hintText: '新密碼',
                    obscureText: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                    errorText: _passwordError,
                  ),
                  const Text(
                    '．需為 6-20 位英數組合，且含至少 1 個大寫字母',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              _buildLabel('請再次輸入您的新密碼'),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: '確認新密碼',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                errorText: _confirmPasswordError,
              ),
            ],
          ),
          ListenableBuilder(
            listenable: Listenable.merge([_passwordController, _confirmPasswordController]),
            builder: (context, _) {
              final canSubmit = _passwordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty;
              return CustomButton(
                text: '送出',
                onPressed: canSubmit ? _handleSubmit : null,
                backgroundColor: AppColors.primaryGreen,
                isLoading: _isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
        children: const [
          TextSpan(text: '*', style: TextStyle(color: AppColors.primaryRed)),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: SvgPicture.asset(
        'assets/icons/password.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      ),
      isPassword: true,
      obscureText: obscureText,
      onToggleVisibility: onToggleVisibility,
      errorText: errorText,
    );
  }
}
