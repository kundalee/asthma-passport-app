import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../services/emergency_contact_service.dart';

class PatientInfoView extends StatefulWidget {
  final Function(int) onSwitchTab;

  const PatientInfoView({
    super.key,
    required this.onSwitchTab,
  });

  @override
  State<PatientInfoView> createState() => _PatientInfoViewState();
}

class _PatientInfoViewState extends State<PatientInfoView> {
  final EmergencyContactService _service = EmergencyContactService();

  bool _basicExpanded = false;
  bool _allergyExpanded = false;
  bool _medicationExpanded = false;
  bool _isEditing = false;

  final Map<String, String> _basicInfo = {
    '姓名': '王小明',
    '性別': '男性',
    '生日': '2016/03/15',
    '年齡': '8歲',
    '身高': '135cm',
    '體重': '28kg',
    '血型': 'A型',
  };

  late List<String> _allergies;
  late List<String> _medications;

  late List<String> _editAllergies;
  late List<String> _editMedications;

  final TextEditingController _allergyInputController = TextEditingController();
  final TextEditingController _medicationInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allergies = _service.getAllergies();
    _medications = _service.getMedications();
  }

  @override
  void dispose() {
    _allergyInputController.dispose();
    _medicationInputController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editAllergies = List.from(_allergies);
      _editMedications = List.from(_medications);
      _allergyInputController.clear();
      _medicationInputController.clear();
      _allergyExpanded = true;
      _medicationExpanded = true;
      _isEditing = true;
    });
  }

  void _saveEditing() {
    _service.saveAllergies(_editAllergies);
    _service.saveMedications(_editMedications);
    setState(() {
      _allergies = List.from(_editAllergies);
      _medications = List.from(_editMedications);
      _isEditing = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      _allergyInputController.clear();
      _medicationInputController.clear();
      _isEditing = false;
    });
  }

  void _addAllergyTag() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editAllergies.add(text);
      _allergyInputController.clear();
    });
  }

  void _addMedicationTag() {
    final text = _medicationInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editMedications.add(text);
      _medicationInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                'assets/icons/user.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
              ),
              const Text(
                '病患基本資料',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          _buildBasicInfoSection(),
          _buildChipSection(
            title: '過敏史',
            expanded: _allergyExpanded,
            onTap: () => setState(() => _allergyExpanded = !_allergyExpanded),
            backgroundColor: AppColors.babysBottom,
            items: _isEditing ? _editAllergies : _allergies,
            chipColor: AppColors.babysBottom,
            chipTextColor: const Color(0xFF82181A),
            chipBorderColor: AppColors.spicyPastelPink,
            inputController: _allergyInputController,
            inputHint: '請輸入過敏原',
            onAddTag: _addAllergyTag,
            onRemoveTag: (index) { setState(() => _editAllergies.removeAt(index)); },
          ),
          _buildChipSection(
            title: '目前用藥',
            expanded: _medicationExpanded,
            onTap: () => setState(() => _medicationExpanded = !_medicationExpanded),
            backgroundColor: AppColors.butteryWhite2,
            items: _isEditing ? _editMedications : _medications,
            chipColor: AppColors.butteryWhite2,
            chipTextColor: AppColors.windsorTan,
            chipBorderColor: AppColors.brightCanaryYellow,
            inputController: _medicationInputController,
            inputHint: '請輸入使用藥物',
            onAddTag: _addMedicationTag,
            onRemoveTag: (index) { setState(() => _editMedications.removeAt(index)); },
          ),
          if (_isEditing)
            Column(
              spacing: 8,
              children: [
                CustomButton(
                  text: '儲存編輯',
                  onPressed: _saveEditing,
                  backgroundColor: AppColors.funGreen,
                  foregroundColor: Colors.white,
                  height: 44,
                ),
                CustomButton(
                  text: '取消編輯',
                  onPressed: _cancelEditing,
                  backgroundColor: AppColors.strongRed,
                  foregroundColor: Colors.white,
                  height: 44,
                ),
              ],
            )
          else
            CustomButton(
              text: '編輯基本資料',
              onPressed: _startEditing,
              backgroundColor: AppColors.funGreen,
              foregroundColor: Colors.white,
              height: 40,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                'assets/icons/arrow-down.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            _buildSectionHeader(
              title: '基本資料',
              expanded: _basicExpanded,
              onTap: () => setState(() => _basicExpanded = !_basicExpanded),
              backgroundColor: AppColors.zumthor,
            ),
            if (_basicExpanded) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  spacing: 8,
                  children: _basicInfo.entries.map(
                    (entry) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1.5,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Color backgroundColor,
    required List<String> items,
    required Color chipColor,
    required Color chipTextColor,
    required Color chipBorderColor,
    TextEditingController? inputController,
    String? inputHint,
    VoidCallback? onAddTag,
    void Function(int)? onRemoveTag,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            _buildSectionHeader(
              title: title,
              expanded: expanded,
              onTap: onTap,
              backgroundColor: backgroundColor,
            ),
            if (expanded) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    if (_isEditing && inputController != null)
                      TextField(
                        controller: inputController,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4A5565), height: 1.5, letterSpacing: 0),
                        decoration: InputDecoration(
                          hintText: inputHint,
                          hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4A5565), height: 1.5, letterSpacing: 0),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                        ),
                        onSubmitted: (_) => onAddTag?.call(),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: items.map((item) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: chipColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: chipBorderColor, width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: chipTextColor,
                                    height: 1.5,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
