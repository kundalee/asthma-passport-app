import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import 'terms_bottom_sheet.dart';
import '../services/auth_service.dart';
import '../pages/home_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = false;
  bool obscureConfirmPassword = false;
  bool isLoading = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController.addListener(_onNameChanged);
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (nameController.text.isNotEmpty && nameError != null) {
      setState(() => nameError = null);
    }
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

  void _onConfirmPasswordChanged() {
    if (confirmPasswordController.text.isNotEmpty && confirmPasswordError != null) {
      setState(() => confirmPasswordError = null);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  void _showTermsAndRegister() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TermsBottomSheet(
        title: 'APP使用條款及隱私權保護聲明',
        onConfirm: () {
          Navigator.pop(context);
          _handleRegister();
        },
      ),
    );
  }

  void _handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    String? newNameError;
    String? newEmailError;
    String? newPasswordError;
    String? newConfirmPasswordError;

    if (name.isEmpty) {
      newNameError = '此欄位為必填';
    }
    if (email.isEmpty) {
      newEmailError = '此欄位為必填';
    } else if (!_isValidEmail(email)) {
      newEmailError = '您輸入的信箱格式有誤，請重新輸入';
    }
    if (password.isEmpty) {
      newPasswordError = '此欄位為必填';
    }
    if (confirmPassword.isEmpty) {
      newConfirmPasswordError = '此欄位為必填';
    } else if (password != confirmPassword) {
      newConfirmPasswordError = '您輸入的密碼不符，請重新輸入';
    }

    if (newNameError != null || newEmailError != null || newPasswordError != null || newConfirmPasswordError != null) {
      setState(() {
        nameError = newNameError;
        emailError = newEmailError;
        passwordError = newPasswordError;
        confirmPasswordError = newConfirmPasswordError;
      });
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.register(
      name,
      email,
      password,
      confirmPassword,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '註冊失敗')),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // Name Field
        CustomTextField(
          controller: nameController,
          hintText: '姓名',
          prefixIcon: SvgPicture.asset(
            'assets/icons/user.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          errorText: nameError,
        ),
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
          obscureText: obscurePassword,
          onToggleVisibility: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
          errorText: passwordError,
        ),
        // Confirm Password Field
        CustomTextField(
          controller: confirmPasswordController,
          hintText: '確認密碼',
          prefixIcon: SvgPicture.asset(
            'assets/icons/password.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          isPassword: true,
          obscureText: obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              obscureConfirmPassword = !obscureConfirmPassword;
            });
          },
          errorText: confirmPasswordError,
        ),
        // Register Button
        CustomButton(
          text: '註冊',
          onPressed: _showTermsAndRegister,
          backgroundColor: AppColors.funGreen,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
