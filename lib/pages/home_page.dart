import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../components/app_page_container.dart';
import '../components/custom_dialog.dart';

class HomePage extends StatefulWidget {
  final bool showFirstLoginDialog;

  const HomePage({super.key, this.showFirstLoginDialog = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  bool isLoggedIn = false;
  int aqi = 0;
  double temperature = 0;
  int humidity = 0;
  double pm25 = 0;
  double? latitude;
  double? longitude;
  List<Map<String, dynamic>> todayTests = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserName();
    _loadLocationAndWeather();
    _loadTodayTests();
    if (widget.showFirstLoginDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstLoginDialog();
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<void> _loadUserName() async {
    final name = await AuthService.getUserName();
    if (!mounted) return;
    setState(() {
      userName = name ?? '';
    });
  }

  Future<void> _loadLocationAndWeather() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      if (!mounted) return;
      setState(() {
        latitude = location.$1;
        longitude = location.$2;
      });
    }

    // TODO: Once station_name is resolved from (latitude, longitude), pass
    // it here instead of the fixed '萬華'.
    final result = await ApiService.getWeather('萬華');
    final weather = result.data;
    if (result.success && weather != null) {
      if (!mounted) return;
      setState(() {
        aqi = weather.aqi;
        temperature = weather.temperature;
        humidity = weather.humidity;
        pm25 = weather.pm25;
      });
    }
  }

  Future<void> _loadTodayTests() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final tests = await ApiService.getTodayTests();
      if (!mounted) return;
      setState(() {
        todayTests = tests;
      });
    } catch (e) {
      // Today tests failed to load, keep empty list
    }
  }

  void _handleTestItemTap(String testName) {
    if (testName == '氣喘日記') {
      Navigator.of(context).pushNamed('/asthma-diary');
    } else if (testName == '尖峰吐氣流量') {
      Navigator.of(context).pushNamed('/peak-flow');
    } else if (testName == '氣喘控制測驗') {
      Navigator.of(context).pushNamed('/asthma-control-test');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // AQI and Weather Card
          _buildAQICard(),
          // Today's Tests Section
          _buildTodayTestsSection(),
          // Feature Buttons Grid
          _buildFeatureButtonsGrid(),
        ],
      ),
      bottomNavigation: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: isLoggedIn
                ? () => Navigator.of(context).pushNamed('/profile')
                : () => Navigator.of(context).pushReplacementNamed('/login'),
            child: SizedBox(
              width: isLoggedIn ? null : 64,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.funGreen,
                  borderRadius: BorderRadius.circular(isLoggedIn ? 8 : 24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    if (isLoggedIn)
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    Text(
                      isLoggedIn ? userName : '登入',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500, height: 1.0, letterSpacing: 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAQICard() {
    return SizedBox(
      height: 200,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/01d.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // AQI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'AQI',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0),
                        ),
                        Text(
                          '$aqi',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.funGreen,
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // temperature, humidity, pm2.5
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildWeatherItem('溫度', temperature.toStringAsFixed(1), '°C'),
                  ),
                  Expanded(
                    child: _buildWeatherItem('濕度', '$humidity', '%'),
                  ),
                  Expanded(
                    child: _buildWeatherItem('PM2.5', pm25.toStringAsFixed(1), 'μg/m3', unitStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.funGreen, height: 2.25, letterSpacing: 0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem(
    String label,
    String value,
    String unit, {
    TextStyle? unitStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71, letterSpacing: 0)),
        if (unitStyle != null)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.funGreen,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Transform.translate(
                    offset: const Offset(0, 4),
                    child: Text(
                      unit,
                      style: unitStyle,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.funGreen,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.funGreen,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTodayTestsSection() {
    final testItems = [
      {'name': '氣喘日記', 'icon': 'assets/icons/note.svg'},
      {'name': '尖峰吐氣流量', 'icon': 'assets/icons/wind.svg'},
      {'name': '氣喘控制測驗', 'icon': 'assets/icons/exam.svg'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.whiteMarble, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/diary.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
              ),
              const Text(
                '今日檢測',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
              ),
            ],
          ),
          ...List.generate(
            todayTests.length,
            (index) => _buildTestItem(
              todayTests[index]['name'] ?? '',
              todayTests[index]['icon'] ?? testItems[index % 3]['icon'] ?? '',
              todayTests[index]['status'] ?? 0,
              onTap: () => _handleTestItemTap(todayTests[index]['name'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(String title, String iconPath, int status, {bool showArrow = true, VoidCallback? onTap}) {
    final isDone = status == 1;

    return GestureDetector(
      onTap: isLoggedIn ? onTap : () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.luxuryWhite,
          border: Border.all(color: AppColors.whiteMarble, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.funGreen : Colors.transparent,
                    border: Border.all(color: AppColors.funGreen, width: 2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: SvgPicture.asset(
                    isDone ? 'assets/icons/check-fill.svg' : iconPath,
                              width: 24,
                              height: 24,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.6, letterSpacing: 0),
                ),
              ],
            ),
            if (showArrow)
              SvgPicture.asset(
                'assets/icons/arrow-right.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButtonsGrid() {
    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _buildFeatureButton(
                '健康護照',
                'assets/icons/passport.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.philippineGreen, AppColors.jade],
                ),
                onTap: () => Navigator.of(context).pushNamed('/health-passport'),
                height: 80,
                isRow: true,
              ),
            ),
            Expanded(
              child: _buildFeatureButton(
                '氣喘知識',
                'assets/icons/book.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.philippineGreen, AppColors.jade],
                ),
                onTap: () => Navigator.of(context).pushNamed('/asthma-knowledge'),
                height: 80,
                isRow: true,
              ),
            ),
          ],
        ),
        Row(
          spacing: 4,
          children: [
            Expanded(
              child: _buildFeatureButton(
                '歷史紀錄',
                'assets/icons/calendar.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.royalAquamarine, AppColors.mermaid],
                ),
                onTap: () => Navigator.of(context).pushNamed('/history-records'),
                padding: const EdgeInsets.all(8),
                height: 108,
              ),
            ),
            Expanded(
              child: _buildFeatureButton(
                '氣喘達人',
                'assets/icons/student-bold.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.rawSienna, AppColors.metallicOrange],
                ),
                onTap: () => Navigator.of(context).pushNamed('/asthma-master'),
                padding: const EdgeInsets.all(8),
                height: 108,
              ),
            ),
            Expanded(
              child: _buildFeatureButton(
                '智能管家',
                'assets/icons/ai-robot.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.dodgerBlue, AppColors.adonis],
                ),
                onTap: () => _showDevelopmentDialog(),
                padding: const EdgeInsets.all(8),
                height: 108,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureButton(
    String title,
    String iconPath, {
    required Gradient gradient,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    VoidCallback? onTap,
    double height = 80,
    bool isRow = false,
  }) {
    return GestureDetector(
      onTap: isLoggedIn
          ? onTap
          : () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        width: double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isRow
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.6,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.6,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteMarble, width: 1),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          _buildNavButton('個人首頁', 'assets/icons/home.svg', AppColors.funGreen, true),
          _buildNavButton('系統設定', 'assets/icons/setting.svg', AppColors.funGreen, false),
          _buildNavButton('緊急聯絡', 'assets/icons/emergency.svg', Colors.red, false),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, String iconPath, Color color, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == '系統設定') {
          Navigator.of(context).pushNamed('/system-settings');
        } else if (title == '緊急聯絡') {
          Navigator.of(context).pushNamed('/emergency-contact');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: isActive ? color : Colors.transparent,
        ),
        child: Row(
          spacing: 4,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(isActive ? Colors.white : color, BlendMode.srcIn),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : color,
                height: 2,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFirstLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        iconPath: 'assets/icons/alert-info.svg',
        content: '請先完成會員資料設定來提供您全方位的氣喘保護措施',
        buttonText: '前往編輯',
        onButtonPressed: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed('/profile');
        },
      ),
    );
  }

  void _showDevelopmentDialog({
    String iconPath = 'assets/icons/alert.svg',
    String content = '功能開發中\n敬請期待',
    String buttonText = '確認',
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        iconPath: iconPath,
        content: content,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }
}
