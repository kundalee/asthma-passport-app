import 'package:flutter/material.dart';
import '../components/custom_toggle_switch.dart';
import '../components/login_form.dart';
import '../components/register_form.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;


  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: Container(
        height: 44,
        color: Colors.white,
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            // Logo/Title area
            const Center(
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    '氣喘健康護照',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.375,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    'Asthma Passport',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            // Main Card
            CardContainer(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              showBorder: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  // Toggle
                  CustomToggleSwitch(
                    isLeftSelected: isLogin,
                    leftText: '登入',
                    rightText: '註冊',
                    onChanged: (value) => setState(() => isLogin = value),
                    activeColor: AppColors.funGreen,
                  ),
                  // Forms
                  isLogin ? const LoginForm() : const RegisterForm(),
                  // Terms and Privacy
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.71,
                          letterSpacing: 0,
                        ),
                        children: [
                          TextSpan(text: '繼續使用即表示您同意我們的 '),
                          TextSpan(
                            text: '服務條款',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.funGreen,
                              height: 1.71,
                              letterSpacing: 0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' 和 '),
                          TextSpan(
                            text: '隱私政策',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.funGreen,
                              height: 1.71,
                              letterSpacing: 0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
