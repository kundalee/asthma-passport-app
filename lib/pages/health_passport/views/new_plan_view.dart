import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';

class NewPlanView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(int) onSwitchView;

  const NewPlanView({
    super.key,
    required this.data,
    required this.onSwitchView,
  });

  @override
  State<NewPlanView> createState() => _NewPlanViewState();
}

class _NewPlanViewState extends State<NewPlanView> {
  late TextEditingController dateController;
  String? selectedLevel;
  bool isLevelExpanded = false;

  final Map<String, String> levelDescriptions = {
    'good': '控制良好',
    'warning': '症狀加重',
    'bad': '症狀嚴重',
  };

  final Map<String, String> levelDetails = {
    'good': '病患過去一個月狀況穩定',
    'warning': '病患過去一個月狀況不佳，需多加留意',
    'bad': '病患過去一個月症狀嚴重，需多加診斷',
  };

  final Map<String, String> resultTitles = {
    'good': '維持目前行動計畫',
    'warning': '請留意症狀變化',
    'bad': '需採取緊急措施',
  };

  final Map<String, List<String>> resultPoints = {
    'good': [
      'needing reliever medicine no more than 2 days/week',
      'no asthma at night',
      'no asthma when I wake up',
      'can do all my activities',
    ],
    'warning': [
      'needing reliever medicine more',
      'than usual OR more than 2 days/week',
      'woke up overnight with asthma',
      'had asthma when I woke up',
      'can\'t do all my activities',
    ],
    'bad': [
      'reliever medicine not working at all',
      'can\'t speak a full sentence',
      'extreme difficulty breathing',
      'feel asthma is out of control',
      'lips turning blue',
    ],
  };

  final Map<String, Color> resultColors = {
    'good': AppColors.resultGoodBg,
    'warning': AppColors.resultModerateBg,
    'bad': AppColors.resultSevereBg,
  };

  final Map<String, Color> resultIconColors = {
    'good': AppColors.resultGoodIcon,
    'warning': AppColors.resultModerateIcon,
    'bad': AppColors.resultSevereIcon,
  };

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  void _toggleLevelDropdown() {
    setState(() {
      isLevelExpanded = !isLevelExpanded;
    });
  }

  Widget _buildResultSection() {
    if (selectedLevel == null) {
      return const SizedBox.shrink();
    }

    final title = resultTitles[selectedLevel] ?? '';
    final points = resultPoints[selectedLevel] ?? [];
    final bgColor = resultColors[selectedLevel] ?? Colors.white;
    final iconColor = resultIconColors[selectedLevel] ?? Colors.grey;
    final isGood = selectedLevel == 'good';
    final isWarning = selectedLevel == 'warning';

    String iconPath;

    if (isGood) {
      iconPath = 'assets/icons/check.svg';
    } else if (isWarning) {
      iconPath = 'assets/icons/alert-info.svg';
    } else {
      iconPath = 'assets/icons/emergency.svg';
    }

    return CardContainer(
      backgroundColor: bgColor,
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                ...points.map((point) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle, height: 1.71),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLevelOptions() {
    final entries = levelDescriptions.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final key = entry.key;
      final title = entry.value;
      final detail = levelDetails[key] ?? '';
      final isSelected = selectedLevel == key;
      final isLast = index == entries.length - 1;

      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedLevel = key;
                isLevelExpanded = false;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
                    ],
                  ),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.menuSubtitle, height: 1.71),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast) const Divider(height: 2, color: AppColors.photoBackground, indent: 12, endIndent: 12),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.data['name'] ?? '').toString();

    return SingleChildScrollView(
        child: CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/document.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '填寫新的行動計畫',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.reportTitle),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '病患姓名',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.reportTitle),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.photoBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.inputBorder, width: 1),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '填寫日期',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.reportTitle),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: 'YYYY/MM/DD',
                      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.menuSubtitle),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: '查看常月份歷史紀錄',
                  onPressed: () {},
                  borderRadius: 8,
                  iconAlignment: MainAxisAlignment.start,
                  gradient: const LinearGradient(
                    colors: [AppColors.historyGradientStart, AppColors.historyGradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '處理等級',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.reportTitle),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _toggleLevelDropdown,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedLevel != null ? levelDescriptions[selectedLevel] ?? '請選擇' : '請選擇',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Transform.rotate(
                                  angle: isLevelExpanded ? 3.14159 : 0,
                                  child: SvgPicture.asset(
                                    'assets/icons/arrow-down.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLevelExpanded) ...[
                          Divider(height: 2, color: AppColors.photoBackground, indent: 12, endIndent: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildLevelOptions(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildResultSection(),
            ],
          ),
        ),
    );
  }
}

