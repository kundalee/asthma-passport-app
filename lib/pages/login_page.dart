import 'package:flutter/material.dart';
import '../components/custom_toggle_switch.dart';
import '../components/login_form.dart';
import '../components/register_form.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightMintBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Logo/Title area
                const Center(
                  child: Column(
                    children: [
                      Text(
                        '氣喘健康護照',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Asthma Passport',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Main Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle
                      CustomToggleSwitch(
                        isLeftSelected: isLogin,
                        leftText: '登入',
                        rightText: '註冊',
                        onChanged: (value) => setState(() => isLogin = value),
                        activeColor: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      
                      // Forms
                      isLogin ? const LoginForm() : const RegisterForm(),
                      
                      // Terms and Privacy
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                            children: [
                              TextSpan(text: '繼續使用即表示您同意我們的 '),
                              TextSpan(
                                text: '服務條款',
                                style: TextStyle(color: AppColors.primaryGreen, decoration: TextDecoration.underline),
                              ),
                              TextSpan(text: ' 和 '),
                              TextSpan(
                                text: '隱私政策',
                                style: TextStyle(color: AppColors.primaryGreen, decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
