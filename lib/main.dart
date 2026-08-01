import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/line_auth_config.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/health_passport/health_passport_page.dart';
import 'pages/asthma_diary/asthma_diary_page.dart';
import 'pages/peak_flow/peak_flow_page.dart';
import 'pages/asthma_control_test/asthma_control_test_page.dart';
import 'pages/asthma_knowledge/asthma_knowledge_page.dart';
import 'pages/history_records/history_records_page.dart';
import 'pages/asthma_master/asthma_master_page.dart';
import 'pages/system_settings_page.dart';
import 'pages/about_page.dart';
import 'pages/emergency_contact/emergency_contact_page.dart';
import 'services/navigation_service.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LineSDK.instance.setup(LineAuthConfig.channelId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '氣喘健康護照',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontFamilyFallback: [GoogleFonts.notoSansTc().fontFamily!],
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/health-passport': (context) => const HealthPassportPage(),
        '/asthma-diary': (context) => const AsthmaDiaryPage(),
        '/peak-flow': (context) => const PeakFlowPage(),
        '/asthma-control-test': (context) => const AsthmaControlTestPage(),
        '/asthma-knowledge': (context) => const AsthmaKnowledgePage(),
        '/history-records': (context) => const HistoryRecordsPage(),
        '/asthma-master': (context) => const AsthmaMasterPage(),
        '/system-settings': (context) => const SystemSettingsPage(),
        '/emergency-contact': (context) => const EmergencyContactPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
