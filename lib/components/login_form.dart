import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_colors.dart';
import 'custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';
import 'terms_bottom_sheet.dart';
import '../services/auth_service.dart';
import '../pages/home_page.dart';
import '../config/google_auth_config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = false;
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool isLineLoading = false;
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

  void _showTermsAndThirdPartyLogin(String provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TermsBottomSheet(
        title: 'APP使用條款及隱私權保護聲明',
        onConfirm: () {
          Navigator.pop(context);
          if (provider == 'Google') {
            _handleGoogleLogin();
          } else if (provider == 'LINE') {
            _handleLineLogin();
          }
        },
      ),
    );
  }

  void _handleGoogleLogin() async {
    setState(() => isGoogleLoading = true);

    try {
      // serverClientId is required on Android to receive a non-null idToken
      // (the Android Sign-In SDK only mints one when a web-application-type
      // client is specified as the audience). Doesn't affect iOS, whose
      // idToken audience is always its own iOS client ID regardless.
      final account = await GoogleSignIn(
        scopes: ['email'],
        serverClientId: GoogleAuthConfig.serverClientId,
      ).signIn();
      if (account == null) {
        // Also returned (instead of throwing) when Google Play Services is
        // missing/outdated/unreachable and can't resolve silently.
        debugPrint('Google sign-in returned null account (user cancelled, or Play Services unavailable)');
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        debugPrint('Google sign-in succeeded but idToken is null (email=${account.email})');
        _showError('登入失敗，請稍後再試');
        return;
      }

      final result = await AuthService.loginWithGoogle(idToken);
      if (!mounted) return;

      if (result.success) {
        final isFirstLogin = result.data?.isFirstLogin ?? false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(showFirstLoginDialog: isFirstLogin),
          ),
        );
      } else {
        _showError(result.message ?? '登入失敗，請稍後再試');
      }
    } on PlatformException catch (e) {
      debugPrint('Google sign-in failed: code=${e.code}, message=${e.message}, details=${e.details}');
      _showError('登入失敗，請稍後再試');
    } finally {
      if (mounted) {
        setState(() => isGoogleLoading = false);
      }
    }
  }

  void _handleLineLogin() async {
    setState(() => isLineLoading = true);

    try {
      final result = await LineSDK.instance.login(scopes: ['profile', 'openid', 'email']);
      final idToken = result.accessToken.idTokenRaw;
      if (idToken == null) {
        _showError('登入失敗，請稍後再試');
        return;
      }

      final loginResult = await AuthService.loginWithLine(idToken);
      if (!mounted) return;

      if (loginResult.success) {
        final isFirstLogin = loginResult.data?.isFirstLogin ?? false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(showFirstLoginDialog: isFirstLogin),
          ),
        );
      } else {
        _showError(loginResult.message ?? '登入失敗，請稍後再試');
      }
    } on PlatformException {
      // Covers user cancellation and native SDK errors alike — LINE's error
      // codes differ between iOS/Android, so there's no single reliable
      // "cancelled" code to special-case here.
      _showError('登入失敗，請稍後再試');
    } finally {
      if (mounted) {
        setState(() => isLineLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    final result = await AuthService.login(email, password);
    if (!mounted) return;

    if (result.success) {
      final isFirstLogin = result.data?.isFirstLogin ?? false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(showFirstLoginDialog: isFirstLogin),
        ),
      );
    } else if (result.message == '帳號不存在或此信箱尚未註冊') {
      setState(() => emailError = '您輸入的信箱有誤，請重新輸入');
    } else if (result.message == '帳號或密碼錯誤') {
      setState(() {
        emailError = '您輸入的信箱有誤，請重新輸入';
        passwordError = '您輸入的密碼有誤，請重新輸入';
      });
    } else {
      setState(() => passwordError = result.message ?? '您輸入的密碼有誤，請重新輸入');
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
        _buildPasswordSection(),
        // Login Button
        CustomButton(
          text: '登入',
          onPressed: _handleLogin,
          backgroundColor: AppColors.primaryGreen,
          isLoading: isLoading,
        ),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.black)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或使用以下方式',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black, height: 1.67, letterSpacing: 0),
              ),
            ),
            Expanded(child: Divider(color: Colors.black)),
          ],
        ),
        // LINE Login Button
        CustomButton(
          text: '使用 LINE 登入',
          onPressed: () => _showTermsAndThirdPartyLogin('LINE'),
          backgroundColor: AppColors.malachite,
          isLoading: isLineLoading,
          icon: SvgPicture.asset(
            'assets/icons/line.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        // Google Login Button
        CustomButton(
          text: '使用 Google 登入',
          onPressed: () => _showTermsAndThirdPartyLogin('Google'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          isLoading: isGoogleLoading,
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 24,
            height: 24,
          ),
          border: const BorderSide(color: AppColors.secondaryGrayW, width: 1),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryGreen, height: 1.71, letterSpacing: 0),
            ),
          ),
        ),
      ],
    );
  }
}
