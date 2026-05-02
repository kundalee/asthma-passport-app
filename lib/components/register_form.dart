import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import '../services/api_service.dart';
import '../pages/home_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密碼不相符')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.register(
        nameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('註冊失敗: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
        const SizedBox(height: 16),

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
          obscureText: obscurePassword,
          onToggleVisibility: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
          hideIcon: SvgPicture.asset(
            'assets/icons/hide-on.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          showIcon: SvgPicture.asset(
            'assets/icons/hide-off.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 16),

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
          hideIcon: SvgPicture.asset(
            'assets/icons/hide-on.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          showIcon: SvgPicture.asset(
            'assets/icons/hide-off.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 16),

        // Register Button
        CustomButton(
          text: '註冊',
          onPressed: _handleRegister,
          backgroundColor: AppColors.primaryGreen,
          isLoading: isLoading,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
