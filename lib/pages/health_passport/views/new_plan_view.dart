import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/passport_models.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_dropdown.dart';
import '../../../components/card_container.dart';

const List<String> _doseOptions = ['1次', '2次', '3次'];

class _MedicationEntry {
  String? medicationName;
  String? daytimeDose;
  String? nighttimeDose;
  final TextEditingController notesController = TextEditingController();

  void dispose() {
    notesController.dispose();
  }
}

class NewPlanView extends StatefulWidget {
  final PassportInfo info;
  final Function(int) onSwitchView;
  final ValueChanged<bool>? onPreviewChanged;

  const NewPlanView({
    super.key,
    required this.info,
    required this.onSwitchView,
    this.onPreviewChanged,
  });

  @override
  State<NewPlanView> createState() => _NewPlanViewState();
}

class _NewPlanViewState extends State<NewPlanView> {
  late TextEditingController dateController;
  String? selectedLevel;
  bool isLevelExpanded = false;

  final Map<String, String> levelDescriptions = {
    'full': '氣喘完全控制',
    'partial': '氣喘部分控制',
    'poor': '氣喘控制不佳',
    'acute': '氣喘急性發作',
  };

  final Map<String, List<String>> resultPoints = {
    'full': [
      '需要氣喘緩解症狀的藥物每週不超過 2 天。',
      '夜間無氣喘症狀。',
      '白天沒有氣喘症狀。',
      '我能完成我的所有活動。',
    ],
    'partial': [
      '需要氣喘SABA緩解藥物比平常多或每週超過 2 天。',
      '半夜會因氣喘醒來。',
      '白天有氣喘症狀。',
      '因氣喘而使活動受限。',
    ],
    'poor': [
      '氣喘SABA緩解藥物效果未達3小時。',
      '夜間經常因氣喘症狀醒來。',
      '白天有氣喘症狀。',
      '感覺呼吸困難。',
    ],
    'acute': [
      '氣喘SABA緩解藥物完全無效。',
      '無法說完整一句話。',
      '呼吸極度困難。',
      '感覺氣喘已失控。',
      '嘴唇發紫。',
    ],
  };

  final Map<String, Color> resultColors = {
    'full': AppColors.secondaryGreen,
    'partial': AppColors.secondaryYellow,
    'poor': AppColors.secondaryOrange,
    'acute': AppColors.secondaryRed,
  };

  final Map<String, Color> resultIconColors = {
    'full': AppColors.primaryGreen,
    'partial': AppColors.primaryYellow,
    'poor': AppColors.primaryOrange,
    'acute': AppColors.primaryRed,
  };

  final List<_MedicationEntry> controlMedicationEntries = [_MedicationEntry()];
  final List<_MedicationEntry> reliefMedicationEntries = [_MedicationEntry()];
  late TextEditingController notesController;
  late TextEditingController doctorNameController;
  List<String> controlMedications = [];
  List<String> reliefMedications = [];
  bool showPreview = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    dateController = TextEditingController(text: today);
    notesController = TextEditingController();
    doctorNameController = TextEditingController();
    _loadMedicationOptions();
  }

  Future<void> _loadMedicationOptions() async {
    final result = await ApiService.getMedicationOptions();
    if (result.success && result.data != null) {
      setState(() {
        controlMedications = result.data!.controlMedications;
        reliefMedications = result.data!.reliefMedications;
      });
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    notesController.dispose();
    doctorNameController.dispose();
    for (final medication in [
      ...controlMedicationEntries,
      ...reliefMedicationEntries
    ]) {
      medication.dispose();
    }
    super.dispose();
  }

  void _setShowPreview(bool value) {
    setState(() => showPreview = value);
    widget.onPreviewChanged?.call(value);
  }

  void _toggleLevelDropdown() {
    setState(() {
      isLevelExpanded = !isLevelExpanded;
    });
  }

  void _addControlMedication() {
    setState(() {
      controlMedicationEntries.add(_MedicationEntry());
    });
  }

  void _addReliefMedication() {
    setState(() {
      reliefMedicationEntries.add(_MedicationEntry());
    });
  }

  void _deleteControlMedication(int index) {
    setState(() {
      controlMedicationEntries.removeAt(index).dispose();
    });
  }

  void _deleteReliefMedication(int index) {
    setState(() {
      reliefMedicationEntries.removeAt(index).dispose();
    });
  }

  List<Map<String, dynamic>> _medicationPayload(
      String medType, List<_MedicationEntry> entries) {
    return entries
        .where((entry) => entry.medicationName != null)
        .map((entry) => {
              'med_type': medType,
              'name': entry.medicationName,
              'morn': entry.daytimeDose ?? '',
              'even': entry.nighttimeDose ?? '',
              'note': entry.notesController.text.isNotEmpty
                  ? entry.notesController.text
                  : null,
            })
        .toList();
  }

  Future<void> _submitPlan() async {
    setState(() => isSaving = true);

    final recordDate = dateController.text.replaceAll('/', '-');
    final medications = selectedLevel == 'acute'
        ? <Map<String, dynamic>>[]
        : [
            ..._medicationPayload('control', controlMedicationEntries),
            ..._medicationPayload('relief', reliefMedicationEntries),
          ];

    final result = await ApiService.savePassportPlan(
      recordDate: recordDate,
      statusLevel: levelDescriptions[selectedLevel],
      notes: notesController.text.isNotEmpty ? notesController.text : null,
      doctorName: doctorNameController.text.isNotEmpty
          ? doctorNameController.text
          : null,
      medications: medications,
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (result.success) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '無法儲存行動計畫')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showPreview) {
      return _buildPreviewReport();
    }
    return _buildForm();
  }

  Widget _buildForm() {
    final name = widget.info.name;

    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/document.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                          AppColors.primaryGreen, BlendMode.srcIn),
                    ),
                    const Text(
                      '填寫新的行動計畫',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mirage,
                          height: 1.5,
                          letterSpacing: 0),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text(
                      '病患姓名',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mirage,
                          height: 1.71,
                          letterSpacing: 0),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.sweetGrey,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: AppColors.whiteMarble, width: 1),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.71,
                            letterSpacing: 0),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text(
                      '填寫日期',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mirage,
                          height: 1.71,
                          letterSpacing: 0),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        hintText: 'YYYY/MM/DD',
                        hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.hydrocarbon,
                            height: 1.71,
                            letterSpacing: 0),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: AppColors.whiteMarble, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: AppColors.whiteMarble, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: AppColors.whiteMarble, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '查看常月份歷史紀錄',
                    onPressed: () => Navigator.of(context).pushNamed('/history-records'),
                    borderRadius: 4,
                    iconAlignment: MainAxisAlignment.start,
                    gradient: const LinearGradient(
                      colors: [AppColors.royalAquamarine, AppColors.mermaid],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      width: 24,
                      height: 24,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text(
                      '處理等級',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mirage,
                          height: 1.71,
                          letterSpacing: 0),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.whiteMarble),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedLevel != null
                                        ? levelDescriptions[selectedLevel] ??
                                            '請選擇評估等級'
                                        : '請選擇評估等級',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        height: 1.71,
                                        letterSpacing: 0),
                                  ),
                                  Transform.rotate(
                                    angle: isLevelExpanded ? 3.14159 : 0,
                                    child: SvgPicture.asset(
                                      'assets/icons/arrow-down.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.black, BlendMode.srcIn),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isLevelExpanded) ...[
                            Divider(
                                height: 2,
                                color: AppColors.sweetGrey,
                                indent: 12,
                                endIndent: 12),
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
                _buildResultSection(),
              ],
            ),
          ),
          if (selectedLevel == 'full' ||
              selectedLevel == 'partial' ||
              selectedLevel == 'poor') ...[
            _buildMedicationSection(
              title: '開立氣喘控制藥物',
              buttonText: '新增氣喘控制藥物',
              entries: controlMedicationEntries,
              options: controlMedications,
              onAdd: _addControlMedication,
              onDelete: _deleteControlMedication,
            ),
            _buildMedicationSection(
              title: '開立氣喘緩解藥物',
              buttonText: '新增氣喘緩解藥物',
              entries: reliefMedicationEntries,
              options: reliefMedications,
              onAdd: _addReliefMedication,
              onDelete: _deleteReliefMedication,
            ),
          ],
          if (selectedLevel == 'acute') _buildEmergencySection(),
          if (selectedLevel != null) ...[
            _buildNotesSection(),
            _buildDoctorConfirmationSection(),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '預覽行動計畫',
                onPressed: () => _setShowPreview(true),
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '取消填寫',
                onPressed: () => widget.onSwitchView(1),
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewReport() {
    final levelTitle = levelDescriptions[selectedLevel] ?? '';
    final levelBgColor = resultColors[selectedLevel] ?? AppColors.honeydew;
    final levelIconColor =
        resultIconColors[selectedLevel] ?? AppColors.primaryGreen;

    String levelIconPath;
    if (selectedLevel == 'partial') {
      levelIconPath = 'assets/icons/alert-info.svg';
    } else if (selectedLevel == 'poor') {
      levelIconPath = 'assets/icons/alert.svg';
    } else if (selectedLevel == 'acute') {
      levelIconPath = 'assets/icons/emergency.svg';
    } else {
      levelIconPath = 'assets/icons/check.svg';
    }

    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          CardContainer(
            padding: EdgeInsets.only(left: 11, top: 16, right: 16, bottom: 24),
            borderRadius: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    '行動計畫指派報告',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.0,
                        letterSpacing: 0),
                  ),
                ),
                const Divider(height: 4, thickness: 4, color: Colors.black),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        '基本資料',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                            letterSpacing: 0),
                      ),
                      _buildPreviewRow('病患姓名', widget.info.name),
                      _buildPreviewRow('填寫日期', dateController.text),
                    ],
                  ),
                ),
                const Divider(
                    height: 4, thickness: 4, color: AppColors.sweetGrey),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        '氣喘控制狀況',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                            letterSpacing: 0),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                            color: levelBgColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          spacing: 8,
                          children: [
                            SvgPicture.asset(
                              levelIconPath,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  levelIconColor, BlendMode.srcIn),
                            ),
                            Text(
                              levelTitle,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: levelIconColor,
                                  height: 1.5,
                                  letterSpacing: 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    height: 4, thickness: 4, color: AppColors.sweetGrey),
                if (selectedLevel == 'acute')
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/emergency_instruction.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          '控制藥物',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1.5,
                              letterSpacing: 0),
                        ),
                        for (int i = 0;
                            i < controlMedicationEntries.length;
                            i++)
                          _buildPreviewMedicationEntry(
                              controlMedicationEntries[i], i),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          '緩解藥物',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1.5,
                              letterSpacing: 0),
                        ),
                        for (int i = 0; i < reliefMedicationEntries.length; i++)
                          _buildPreviewMedicationEntry(
                              reliefMedicationEntries[i], i),
                      ],
                    ),
                  ),
                ],
                const Divider(
                    height: 4, thickness: 4, color: AppColors.sweetGrey),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        '備註事項',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                            letterSpacing: 0),
                      ),
                      Text(
                        notesController.text.isNotEmpty
                            ? notesController.text
                            : '無',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.71,
                            letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 4, thickness: 4, color: Colors.black),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      const Text(
                        '醫師確認：',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.71,
                            letterSpacing: 0),
                      ),
                      Text(
                        doctorNameController.text.isNotEmpty
                            ? doctorNameController.text
                            : '未確認',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1,
                          letterSpacing: 0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 40),
            child: Column(
              spacing: 12,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '確認送出',
                    onPressed: _submitPlan,
                    isLoading: isSaving,
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.all(12),
                    borderRadius: 4,
                    height: 37,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '返回修改',
                    onPressed: isSaving ? () {} : () => _setShowPreview(false),
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.all(12),
                    borderRadius: 4,
                    height: 37,
                  ),
                ),
                const Text(
                  '此報告僅供參考，實際治療請遵循醫師指示',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.hydrocarbon,
                      height: 1.71,
                      letterSpacing: 0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.71,
                letterSpacing: 0)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.71,
                letterSpacing: 0)),
      ],
    );
  }

  Widget _buildPreviewMedicationEntry(_MedicationEntry entry, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          '藥物 ${index + 1}',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.625,
              letterSpacing: 0),
        ),
        _buildPreviewRow('藥物名稱', entry.medicationName ?? '未指派'),
        if (entry.medicationName != null) ...[
          _buildPreviewRow('- 使用劑量：白天', entry.daytimeDose ?? '未指派'),
          _buildPreviewRow('- 使用劑量：夜晚', entry.nighttimeDose ?? '未指派'),
        ],
        if (entry.notesController.text.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const Text('備註',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.71,
                      letterSpacing: 0)),
              Text(entry.notesController.text,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.71,
                      letterSpacing: 0)),
            ],
          ),
      ],
    );
  }

  Widget _buildResultSection() {
    if (selectedLevel == null) {
      return const SizedBox.shrink();
    }

    final title = levelDescriptions[selectedLevel] ?? '';
    final points = resultPoints[selectedLevel] ?? [];
    final bgColor = resultColors[selectedLevel] ?? Colors.white;
    final iconColor = resultIconColors[selectedLevel] ?? Colors.grey;

    String iconPath;

    if (selectedLevel == 'partial') {
      iconPath = 'assets/icons/alert-info.svg';
    } else if (selectedLevel == 'poor') {
      iconPath = 'assets/icons/alert-info.svg';
    } else if (selectedLevel == 'acute') {
      iconPath = 'assets/icons/emergency.svg';
    } else {
      iconPath = 'assets/icons/check.svg';
    }

    return CardContainer(
      backgroundColor: bgColor,
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                    height: 1.5,
                    letterSpacing: 0),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: points
                .map((point) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AppColors.hydrocarbon,
                              height: 1.71,
                              letterSpacing: 0),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: AppColors.hydrocarbon,
                                height: 1.71,
                                letterSpacing: 0),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Prescribing a medication list has no backend yet, so this section is
  // local-only UI state (mirrors how the rest of this form isn't saved).
  Widget _buildMedicationSection({
    required String title,
    required String buttonText,
    required List<_MedicationEntry> entries,
    required List<String> options,
    required VoidCallback onAdd,
    required void Function(int) onDelete,
  }) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildMedicationSectionHeader(title),
          for (int i = 0; i < entries.length; i++) ...[
            _buildMedicationEntry(entries, options, i),
            if (i > 0) _buildDeleteMedicationButton(() => onDelete(i)),
            if (i < entries.length - 1)
              const Divider(height: 2, color: AppColors.sweetGrey),
          ],
          _buildAddMedicationButton(buttonText, onAdd),
        ],
      ),
    );
  }

  Widget _buildDeleteMedicationButton(VoidCallback onDelete) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: '刪除',
        onPressed: onDelete,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryRed,
        border: const BorderSide(color: AppColors.primaryRed, width: 1),
        padding: const EdgeInsets.all(12),
        borderRadius: 4,
        height: 37,
      ),
    );
  }

  Widget _buildMedicationSectionHeader(String title) {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset(
          'assets/icons/medic.svg',
          width: 24,
          height: 24,
        ),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.mirage,
              height: 1.5,
              letterSpacing: 0),
        ),
      ],
    );
  }

  Widget _buildAddMedicationButton(String buttonText, VoidCallback onAdd) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: buttonText,
        onPressed: onAdd,
        backgroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.all(12),
        borderRadius: 4,
        height: 37,
      ),
    );
  }

  Widget _buildMedicationEntry(
      List<_MedicationEntry> entries, List<String> options, int index) {
    final medication = entries[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          '藥物 ${index + 1}',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.mirage,
              height: 1.625,
              letterSpacing: 0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '藥物名稱',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mirage,
                  height: 1.71,
                  letterSpacing: 0),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                '藥物參考',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.71,
                    letterSpacing: 0),
              ),
            ),
          ],
        ),
        _buildSelectableDropdown(
          value: medication.medicationName,
          hint: '請選擇開立藥物',
          options: options,
          onChanged: (value) =>
              setState(() => medication.medicationName = value),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text(
                    '白天',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mirage,
                        height: 1.71,
                        letterSpacing: 0),
                  ),
                  _buildSelectableDropdown(
                    value: medication.daytimeDose,
                    hint: '次數',
                    options: _doseOptions,
                    onChanged: (value) =>
                        setState(() => medication.daytimeDose = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text(
                    '夜晚',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mirage,
                        height: 1.71,
                        letterSpacing: 0),
                  ),
                  _buildSelectableDropdown(
                    value: medication.nighttimeDose,
                    hint: '次數',
                    options: _doseOptions,
                    onChanged: (value) =>
                        setState(() => medication.nighttimeDose = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const Text(
              '備註',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mirage,
                  height: 1.71,
                  letterSpacing: 0),
            ),
            TextField(
              controller: medication.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '輸入其他事項...',
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hydrocarbon,
                    height: 1.71,
                    letterSpacing: 0),
                filled: true,
                fillColor: AppColors.powder,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppColors.whiteMarble, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppColors.whiteMarble, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppColors.whiteMarble, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableDropdown({
    required String? value,
    required String hint,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown(
      value: value,
      items: options,
      onChanged: onChanged,
      placeholder: hint,
      height: 40,
      backgroundColor: Colors.white,
      borderColor: AppColors.whiteMarble,
      borderWidth: 1,
      borderRadius: 4,
      textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          height: 1.71,
          letterSpacing: 0),
    );
  }

  Widget _buildEmergencySection() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/medic.svg',
                width: 24,
                height: 24,
              ),
              const Text(
                '緊急措施',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mirage,
                    height: 1.5,
                    letterSpacing: 0),
              ),
            ],
          ),
          Image.asset(
            'assets/images/emergency_instruction.png',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            '備註事項',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.mirage,
                height: 1.5,
                letterSpacing: 0),
          ),
          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '其他注意事項或特殊說明...',
              hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hydrocarbon,
                  height: 1.71,
                  letterSpacing: 0),
              filled: true,
              fillColor: AppColors.powder,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorConfirmationSection() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/pen.svg',
                width: 24,
                height: 24,
              ),
              const Text(
                '醫師確認',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mirage,
                    height: 1.5,
                    letterSpacing: 0),
              ),
            ],
          ),
          TextField(
            controller: doctorNameController,
            decoration: InputDecoration(
              hintText: '請點選此處輸入開立醫師名字',
              hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hydrocarbon,
                  height: 1.71,
                  letterSpacing: 0),
              filled: true,
              fillColor: AppColors.powder,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: AppColors.whiteMarble, width: 1),
              ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.71,
                        letterSpacing: 0),
                  ),
                  if (isSelected)
                    const Icon(Icons.check,
                        color: AppColors.primaryGreen, size: 20),
                ],
              ),
            ),
          ),
          if (!isLast)
            const Divider(
                height: 2,
                color: AppColors.sweetGrey,
                indent: 12,
                endIndent: 12),
        ],
      );
    });
  }
}
