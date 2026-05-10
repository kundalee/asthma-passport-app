import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/health_passport/health_passport_page.dart';
import 'pages/asthma_diary_page.dart';
import 'pages/peak_flow_page.dart';
import 'pages/asthma_control_test_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asthma Passport',
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
        '/health-passport': (context) => const HealthPassportPage(),
        '/asthma-diary': (context) => const AsthmaDiaryPage(),
        '/peak-flow': (context) => const PeakFlowPage(),
        '/asthma-control-test': (context) => const AsthmaControlTestPage(),
      },
    );
  }
}
