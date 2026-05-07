import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import '../services/auth_service.dart';
import '../pages/home_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = false;
  bool isLoading = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (emailController.text.isNotEmpty && emailError != null) {
      setState(() => emailError = null);
    }
  }

  void _onPasswordChanged() {
    if (passwordController.text.isNotEmpty && passwordError != null) {
      setState(() => passwordError = null);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    String? newEmailError;
    String? newPasswordError;

    if (email.isEmpty) {
      newEmailError = '此欄位為必填';
    } else if (!_isValidEmail(email)) {
      newEmailError = '您輸入的信箱格式有誤，請重新輸入';
    }
    if (password.isEmpty) {
      newPasswordError = '此欄位為必填';
    }

    if (newEmailError != null || newPasswordError != null) {
      setState(() {
        emailError = newEmailError;
        passwordError = newPasswordError;
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
    });

    final response = await AuthService.login(email, password);
    if (!mounted) return;

    if (response['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() => passwordError = '您輸入的密碼有誤，請重新輸入');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        CustomTextField(
          controller: emailController,
          hintText: '電子信箱',
          prefixIcon: SvgPicture.asset(
            'assets/icons/mail.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          errorText: emailError,
        ),
        const SizedBox(height: 16),

        // Password Field
        CustomTextField(
          controller: passwordController,
          hintText: '密碼',
          prefixIcon: SvgPicture.asset(
            'assets/icons/password.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          isPassword: true,
          errorText: passwordError,
          obscureText: obscurePassword,
          onToggleVisibility: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        const SizedBox(height: 4),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '忘記密碼？',
              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Login Button
        CustomButton(
          text: '登入',
          onPressed: _handleLogin,
          backgroundColor: AppColors.primaryGreen,
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或使用以下方式',
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.black)),
          ],
        ),
        const SizedBox(height: 16),

        // LINE Login Button
        CustomButton(
          text: '使用 LINE 登入',
          onPressed: () {},
          backgroundColor: AppColors.lineGreen,
          icon: SvgPicture.asset(
            'assets/icons/line.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 16),

        // Google Login Button
        CustomButton(
          text: '使用 Google 登入',
          onPressed: () {},
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 24,
            height: 24,
          ),
          border: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
