import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../components/app_page_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  List<Map<String, dynamic>> todayTests = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserName();
    _loadWeatherData();
    _loadTodayTests();
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiService.getToken();
    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<void> _loadUserName() async {
    final name = await ApiService.getUserName();
    setState(() {
      userName = name ?? '';
    });
  }

  Future<void> _loadWeatherData() async {
    try {
      final data = await ApiService.getWeather('taipei');
      setState(() {
        aqi = data['aqi'] ?? 0;
        temperature = (data['temperature'] ?? 0).toDouble();
        humidity = data['humidity'] ?? 0;
        pm25 = (data['pm25'] ?? 0).toDouble();
      });
    } catch (e) {
      // Weather data failed to load, keep default values
    }
  }

  Future<void> _loadTodayTests() async {
    try {
      final tests = await ApiService.getTodayTests();
      setState(() {
        todayTests = tests;
      });
    } catch (e) {
      // Today tests failed to load, keep empty list
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AQI and Weather Card
            _buildAQICard(),
            const SizedBox(height: 12),

            // Today's Tests Section
            _buildTodayTestsSection(),
            const SizedBox(height: 12),

            // Feature Buttons Grid
            _buildFeatureButtonsGrid(),
            const SizedBox(height: 52),
          ],
        ),
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
            onTap: isLoggedIn ? null : () => Navigator.of(context).pushReplacementNamed('/login'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (isLoggedIn)
                    SvgPicture.asset(
                      'assets/icons/user.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  if (isLoggedIn) const SizedBox(width: 12),
                  Text(
                    isLoggedIn ? userName : '登入',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAQICard() {
    return SizedBox(
      height: 240,
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
                      children: [
                        const Text(
                          'AQI',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$aqi',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                    child: _buildWeatherItem('PM2.5', pm25.toStringAsFixed(1), 'μg/m3', unitStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.primaryGreen)),
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
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
        const SizedBox(height: 4),
        if (unitStyle != null)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Transform.translate(
                    offset: const Offset(0, 6),
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGreen,
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
      {'name': '尖峰呼氣流量', 'icon': 'assets/icons/wind.svg'},
      {'name': '氣喘控制測驗', 'icon': 'assets/icons/exam.svg'},
    ];

    final allTestsDone = todayTests.isNotEmpty && todayTests.every((test) => test['status'] == 1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/diary.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                '今日檢測',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (allTestsDone)
            _buildTestItem('太棒了，今日檢測皆已完成！', '', 1, showArrow: false)
          else
            ...List.generate(
              todayTests.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < todayTests.length - 1 ? 8 : 0),
                child: _buildTestItem(
                  todayTests[index]['name'] ?? '',
                  todayTests[index]['icon'] ?? testItems[index % 3]['icon'] ?? '',
                  todayTests[index]['status'] ?? 0,
                ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.inputBorder, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primaryGreen : Colors.transparent,
                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: SvgPicture.asset(
                    isDone ? 'assets/icons/check.svg' : iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(isDone ? Colors.white : AppColors.primaryGreen, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (showArrow)
              SvgPicture.asset(
                'assets/icons/arrow-right.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButtonsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureButton(
                '健康護照',
                'assets/icons/passport.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.healthPassportGradientStart, AppColors.healthPassportGradientEnd],
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
                onTap: () => Navigator.of(context).pushNamed('/health-passport'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureButton(
                '氣喘知識',
                'assets/icons/book.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.healthPassportGradientStart, AppColors.healthPassportGradientEnd],
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureButton(
                '歷史紀錄',
                'assets/icons/calendar.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.historyGradientStart, AppColors.historyGradientEnd],
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildFeatureButton(
                '氣喘達人',
                'assets/icons/student-bold.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.asthmaExpertGradientStart, AppColors.asthmaExpertGradientEnd],
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildFeatureButton(
                '智能管家',
                'assets/icons/ai-robot.svg',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.smartAssistantGradientStart, AppColors.smartAssistantGradientEnd],
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.all(8),
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
    required TextStyle textStyle,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isLoggedIn
          ? onTap
          : () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        height: 140,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textStyle,
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
        border: Border.all(color: AppColors.inputBorder, width: 1),
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
        children: [
          _buildNavButton('個人首頁', 'assets/icons/home.svg', AppColors.primaryGreen, true),
          const SizedBox(width: 24),
          _buildNavButton('系統設定', 'assets/icons/setting.svg', AppColors.primaryGreen, false),
          const SizedBox(width: 24),
          _buildNavButton('緊急聯絡', 'assets/icons/emergency.svg', Colors.red, false),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, String iconPath, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: isActive ? color : Colors.transparent,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(isActive ? Colors.white : color, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
