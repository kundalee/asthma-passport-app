import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

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
  bool _basicExpanded = false;
  bool _allergyExpanded = false;
  bool _medicationExpanded = false;
  bool _isEditing = false;

  Map<String, String> _basicInfo = {
    '姓名': '',
    '性別': '',
    '生日': '',
    '年齡': '',
    '身高': '',
    '體重': '',
    '血型': '',
  };

  List<String> _allergies = [];
  List<String> _medications = [];
  Map<String, String> _allergenIds = {};
  Map<String, String> _medicationIds = {};

  late List<String> _editAllergies;
  late List<String> _editMedications;

  final TextEditingController _allergyInputController = TextEditingController();
  final TextEditingController _medicationInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAllergensAndMedications();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getProfile();
    if (!mounted) return;
    if (result.success && result.data != null) {
      final profile = result.data!;
      setState(() {
        _basicInfo = {
          '姓名': profile.name,
          '性別': profile.gender,
          '生日': profile.birthday,
          '年齡': profile.age,
          '身高': profile.height,
          '體重': profile.weight,
          '血型': profile.bloodType,
        };
      });
    }
  }

  Future<void> _loadAllergensAndMedications() async {
    final allergensFuture = ApiService.getAllergens();
    final medicationsFuture = ApiService.getMedications();

    final allergensResult = await allergensFuture;
    final medicationsResult = await medicationsFuture;
    if (!mounted) return;

    setState(() {
      if (allergensResult.success && allergensResult.data != null) {
        _allergies = allergensResult.data!.map((a) => a.name).toList();
        _allergenIds = {for (final a in allergensResult.data!) a.name: a.id.toString()};
      }
      if (medicationsResult.success && medicationsResult.data != null) {
        _medications = medicationsResult.data!.map((m) => m.name).toList();
        _medicationIds = {for (final m in medicationsResult.data!) m.name: m.id.toString()};
      }
    });
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

  Future<void> _saveEditing() async {
    final newAllergies = _editAllergies.where((a) => !_allergies.contains(a)).toList();
    final removedAllergies = _allergies.where((a) => !_editAllergies.contains(a)).toList();

    for (final allergen in newAllergies) {
      final result = await ApiService.saveAllergen(allergen);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '儲存過敏原失敗，請稍後再試')),
        );
        return;
      }
    }

    for (final allergen in removedAllergies) {
      final id = _allergenIds[allergen];
      if (id == null) continue;
      final result = await ApiService.deleteAllergen(id);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除過敏原失敗，請稍後再試')),
        );
        return;
      }
    }

    final newMedications = _editMedications.where((m) => !_medications.contains(m)).toList();
    final removedMedications = _medications.where((m) => !_editMedications.contains(m)).toList();

    for (final medication in newMedications) {
      final result = await ApiService.saveMedication(medication);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '儲存用藥資訊失敗，請稍後再試')),
        );
        return;
      }
    }

    for (final medication in removedMedications) {
      final id = _medicationIds[medication];
      if (id == null) continue;
      final result = await ApiService.deleteMedication(id);
      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除用藥資訊失敗，請稍後再試')),
        );
        return;
      }
    }

    setState(() {
      _isEditing = false;
    });
    await _loadAllergensAndMedications();
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

  void _showAddTagDialog({
    required String title,
    required TextEditingController controller,
    required VoidCallback onAdd,
  }) {
    controller.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.whiteMarble, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black, height: 1.6, letterSpacing: 0),
              ),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                decoration: InputDecoration(
                  hintText: '請輸入新增項目',
                  hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.625, letterSpacing: 0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  filled: true,
                  fillColor: AppColors.powder,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2)),
                ),
                onSubmitted: (_) {
                  onAdd();
                  Navigator.pop(dialogContext);
                },
              ),
              Column(
                spacing: 12,
                children: [
                  CustomButton(
                    text: '新增',
                    onPressed: () {
                      onAdd();
                      Navigator.pop(dialogContext);
                    },
                    backgroundColor: AppColors.funGreen,
                    foregroundColor: Colors.white,
                    height: 44,
                    borderRadius: 4,
                  ),
                  CustomButton(
                    text: '取消',
                    onPressed: () => Navigator.pop(dialogContext),
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    height: 44,
                    borderRadius: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            backgroundColor: AppColors.secondaryRed,
            items: _isEditing ? _editAllergies : _allergies,
            chipColor: AppColors.secondaryRed,
            chipTextColor: AppColors.primaryRed,
            chipBorderColor: AppColors.darkRed,
            onRemoveTag: (index) { setState(() => _editAllergies.removeAt(index)); },
            onAddTagPressed: () => _showAddTagDialog(
              title: '新增過敏原',
              controller: _allergyInputController,
              onAdd: _addAllergyTag,
            ),
          ),
          _buildChipSection(
            title: '目前用藥',
            expanded: _medicationExpanded,
            onTap: () => setState(() => _medicationExpanded = !_medicationExpanded),
            backgroundColor: AppColors.secondaryYellow,
            items: _isEditing ? _editMedications : _medications,
            chipColor: AppColors.secondaryYellow,
            chipTextColor: AppColors.primaryYellow,
            chipBorderColor: AppColors.darkYellow,
            onRemoveTag: (index) { setState(() => _editMedications.removeAt(index)); },
            onAddTagPressed: () => _showAddTagDialog(
              title: '新增用藥',
              controller: _medicationInputController,
              onAdd: _addMedicationTag,
            ),
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
                  backgroundColor: AppColors.primaryRed,
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
            bottom: BorderSide(color: AppColors.whiteMarble, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.mirage,
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
        border: Border.all(color: AppColors.whiteMarble, width: 1),
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
    void Function(int)? onRemoveTag,
    VoidCallback? onAddTagPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteMarble, width: 1),
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
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(items.length, (index) {
                        return _buildChip(
                          text: items[index],
                          chipColor: chipColor,
                          chipTextColor: chipTextColor,
                          chipBorderColor: chipBorderColor,
                          onRemove: _isEditing ? () => onRemoveTag?.call(index) : null,
                        );
                      }),
                      if (_isEditing) _buildAddTagChip(onTap: onAddTagPressed),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color chipColor,
    required Color chipTextColor,
    required Color chipBorderColor,
    VoidCallback? onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipBorderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: chipTextColor,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: SvgPicture.asset(
                'assets/icons/undone.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(chipTextColor, BlendMode.srcIn),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddTagChip({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.midGray, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Text(
              '新增',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.midGray, height: 1.625, letterSpacing: 0),
            ),
            SvgPicture.asset(
              'assets/icons/add.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(AppColors.midGray, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
