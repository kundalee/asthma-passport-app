import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';
import '../models/patient_info_models.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const _genderOptions = ['男性', '女性', '不公開'];
  static const _bloodTypeOptions = ['A', 'B', 'AB', 'O'];
  // Placeholder values UserProfile falls back to when a field isn't set;
  // they're for display only and shouldn't populate the edit form.
  static const _placeholderValues = {'未填寫', '-'};

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emailController;
  final TextEditingController _allergyInputController = TextEditingController();
  final TextEditingController _medicationInputController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthDate;
  String avatarUrl = '';

  List<AllergenEntry> _allergens = [];
  List<MedicationEntry> _medications = [];
  List<String> _editAllergens = [];
  List<String> _editMedications = [];

  // Becomes true after the first save attempt, so required-field errors
  // only appear once the user has tried to submit, and stay live as they
  // fix each field (the controller listener below re-renders on typing).
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '')..addListener(_handleRequiredFieldChanged);
    _heightController = TextEditingController(text: '')..addListener(_handleRequiredFieldChanged);
    _weightController = TextEditingController(text: '')..addListener(_handleRequiredFieldChanged);
    _emailController = TextEditingController(text: '');
    _selectedGender = null;
    _selectedBloodType = null;
    _selectedBirthDate = null;
    _loadProfile();
    _loadAllergensAndMedications();
  }

  // Keeps the inline "此欄位必填" errors in sync as the user types, once a
  // save attempt has revealed them.
  void _handleRequiredFieldChanged() {
    if (_submitted) setState(() {});
  }

  String? _requiredError(bool isEmpty) => _submitted && isEmpty ? '此欄位必填' : null;

  Future<void> _loadProfile() async {
    final result = await AuthService.getProfile();
    if (!mounted) return;

    final profile = result.data;
    if (result.success && profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _heightController.text = _valueOrEmpty(profile.height);
        _weightController.text = _valueOrEmpty(profile.weight);
        _selectedGender = _genderOptions.contains(profile.gender) ? profile.gender : null;
        _selectedBloodType = _bloodTypeOptions.contains(profile.bloodType) ? profile.bloodType : null;
        _selectedBirthDate = _parseBirthday(profile.birthday);
        // Cache-bust: the backend serves the same URL per user across
        // re-uploads, so without this any CDN/proxy/local cache for that
        // URL can serve stale bytes on every subsequent profile load.
        avatarUrl = profile.avatarUrl.isEmpty
            ? profile.avatarUrl
            : '${profile.avatarUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
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
        _allergens = allergensResult.data!;
        _editAllergens = _allergens.map((a) => a.name).toList();
      }
      if (medicationsResult.success && medicationsResult.data != null) {
        _medications = medicationsResult.data!;
        _editMedications = _medications.map((m) => m.name).toList();
      }
    });
  }

  String _valueOrEmpty(String value) => _placeholderValues.contains(value) ? '' : value;

  // GET /user/profile returns birthday as "YYYY/MM/DD", not ISO 8601, so
  // DateTime.tryParse can't read it directly.
  DateTime? _parseBirthday(String value) {
    if (_placeholderValues.contains(value)) return null;
    final parts = value.split('/');
    if (parts.length != 3) return DateTime.tryParse(value);
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    _allergyInputController.dispose();
    _medicationInputController.dispose();
    super.dispose();
  }

  String get _displayName => _nameController.text.isNotEmpty ? _nameController.text : '尚未設定姓名';

  String get _genderSummary => _selectedGender ?? '未設定性別';

  String get _ageSummary {
    if (_selectedBirthDate == null) return '未知年齡';
    final now = DateTime.now();
    var age = now.year - _selectedBirthDate!.year;
    if (now.month < _selectedBirthDate!.month ||
        (now.month == _selectedBirthDate!.month && now.day < _selectedBirthDate!.day)) {
      age--;
    }
    return '$age歲';
  }

  void _addAllergen() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editAllergens.add(text);
      _allergyInputController.clear();
    });
  }

  void _removeAllergenAt(int index) {
    setState(() => _editAllergens.removeAt(index));
  }

  void _addMedication() {
    final text = _medicationInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editMedications.add(text);
      _medicationInputController.clear();
    });
  }

  void _removeMedicationAt(int index) {
    setState(() => _editMedications.removeAt(index));
  }

  // Diffs the edited allergen/medication name lists against what was
  // originally loaded from the server and applies only the changes, since
  // 加入/移除 only mutate local state until 儲存編輯 is pressed.
  Future<bool> _syncAllergensAndMedications() async {
    final originalAllergenNames = _allergens.map((a) => a.name).toList();
    final newAllergens = _editAllergens.where((a) => !originalAllergenNames.contains(a)).toList();
    final removedAllergens = _allergens.where((a) => !_editAllergens.contains(a.name)).toList();

    for (final name in newAllergens) {
      final result = await ApiService.saveAllergen(name);
      if (!mounted) return false;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '儲存過敏原失敗')),
        );
        return false;
      }
    }
    for (final entry in removedAllergens) {
      final result = await ApiService.deleteAllergen(entry.id.toString());
      if (!mounted) return false;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除過敏原失敗')),
        );
        return false;
      }
    }

    final originalMedicationNames = _medications.map((m) => m.name).toList();
    final newMedications = _editMedications.where((m) => !originalMedicationNames.contains(m)).toList();
    final removedMedications = _medications.where((m) => !_editMedications.contains(m.name)).toList();

    for (final name in newMedications) {
      final result = await ApiService.saveMedication(name);
      if (!mounted) return false;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '儲存過敏藥物失敗')),
        );
        return false;
      }
    }
    for (final entry in removedMedications) {
      final result = await ApiService.deleteMedication(entry.id.toString());
      if (!mounted) return false;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除過敏藥物失敗')),
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _handleAvatarSelected(XFile image) async {
    final result = await AuthService.updateAvatar(image);
    if (!mounted) return;

    if (result.success && result.data != null) {
      final newAvatarUrl = '${result.data!}?t=${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        avatarUrl = newAvatarUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '更新頭像失敗')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();

      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(
            '編輯相片',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.4),
              height: 1.38,
              letterSpacing: -0.08,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                final XFile? image = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _handleAvatarSelected(image);
                }
              },
              child: Text(
                '從圖庫選擇',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.azure,
                  height: 1.2,
                  letterSpacing: 0.38,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                final XFile? image = await imagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (image != null) {
                  await _handleAvatarSelected(image);
                }
              },
              child: Text(
                '開啟相機',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.azure,
                  height: 1.2,
                  letterSpacing: 0.38,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.azure,
                height: 1.2,
                letterSpacing: 0.38,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      content: Form(
        key: _formKey,
        child: Column(
          spacing: 12,
          children: [
            _buildIdentitySection(),
            _buildTagSection(
              title: '過敏原',
              items: _editAllergens,
              nameOf: (a) => a,
              emptyLabel: '尚無添加過敏原',
              inputLabel: '新增過敏原',
              inputHint: '例如：花生、塵蟎...',
              controller: _allergyInputController,
              chipColor: AppColors.secondaryRed,
              chipTextColor: AppColors.primaryRed,
              chipBorderColor: AppColors.darkRed,
              onAdd: _addAllergen,
              onRemove: _removeAllergenAt,
            ),
            _buildTagSection(
              title: '過敏藥物',
              items: _editMedications,
              nameOf: (m) => m,
              emptyLabel: '尚無添加過敏藥物',
              inputLabel: '新增過敏藥物',
              inputHint: '例如：阿斯匹靈、Seretide 125/25...',
              controller: _medicationInputController,
              chipColor: AppColors.secondaryYellow,
              chipTextColor: AppColors.primaryYellow,
              chipBorderColor: AppColors.darkYellow,
              onAdd: _addMedication,
              onRemove: _removeMedicationAt,
            ),
            _buildSaveButton(),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '會員帳號',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildIdentityRow(),
          const Divider(color: AppColors.secondaryGray2, thickness: 2, height: 2),
          _buildLabeledField(
            '姓名',
            _nameController,
            '請輸入您的姓名',
            required: true,
            errorText: _requiredError(_nameController.text.trim().isEmpty),
          ),
          _buildLabeledDatePicker(context, errorText: _requiredError(_selectedBirthDate == null)),
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLabeledDropdown(
                  '性別',
                  _selectedGender,
                  _genderOptions,
                  (value) => setState(() => _selectedGender = value),
                  '請選擇',
                  required: true,
                  errorText: _requiredError(_selectedGender == null),
                ),
              ),
              Expanded(
                child: _buildLabeledDropdown(
                  '血型',
                  _selectedBloodType,
                  _bloodTypeOptions,
                  (value) => setState(() => _selectedBloodType = value),
                  '請選擇',
                  required: true,
                  errorText: _requiredError(_selectedBloodType == null),
                ),
              ),
            ],
          ),
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLabeledField(
                  '身高(cm)',
                  _heightController,
                  '請輸入您的身高',
                  required: true,
                  errorText: _requiredError(_heightController.text.trim().isEmpty),
                ),
              ),
              Expanded(
                child: _buildLabeledField(
                  '體重(kg)',
                  _weightController,
                  '請輸入您的體重',
                  required: true,
                  errorText: _requiredError(_weightController.text.trim().isEmpty),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityRow() {
    return Row(
      spacing: 24,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryGrayW, width: 1),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl.startsWith('http') ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.startsWith('http')
                    ? null
                    : SvgPicture.asset('assets/icons/user2.svg', width: 64, height: 64),
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
            Text(
              '$_genderSummary　$_ageSummary',
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
      ],
    );
  }

  Widget _buildLabel(String label, {bool required = false}) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          height: 1.625,
          letterSpacing: 0,
        ),
        children: required
            ? const [
                TextSpan(text: '*', style: TextStyle(color: AppColors.primaryRed)),
              ]
            : null,
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, String placeholder, {bool required = false, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel(label, required: required),
        _buildFieldGroup(field: _buildTextField(controller, placeholder, errorText: errorText), errorText: errorText),
      ],
    );
  }

  Widget _buildLabeledDatePicker(BuildContext context, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel('生日', required: true),
        _buildFieldGroup(field: _buildDatePicker(context, errorText: errorText), errorText: errorText),
      ],
    );
  }

  Widget _buildLabeledDropdown(String label, String? value, List<String> items, Function(String?) onChanged, String placeholder, {bool required = false, String? errorText}) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel(label, required: required),
        _buildFieldGroup(
          errorText: errorText,
          field: CustomDropdown(
            value: value,
            items: items,
            onChanged: onChanged,
            placeholder: placeholder,
            backgroundColor: hasError ? AppColors.secondaryRed : AppColors.secondaryGray,
            borderColor: hasError ? AppColors.primaryRed : AppColors.secondaryGray2,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  // Groups a field with its own error message as a single unit, distinct
  // from the label-to-field gap above it.
  Widget _buildFieldGroup({required Widget field, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        if (errorText != null) _buildErrorText(errorText),
      ],
    );
  }

  Widget _buildErrorText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryRed, height: 1.5, letterSpacing: 0),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {String? errorText}) {
    final hasError = errorText != null;
    final borderSide = BorderSide(color: hasError ? AppColors.primaryRed : AppColors.secondaryGray2, width: 2);
    return SizedBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.625,
            letterSpacing: 0,
          ),
          filled: true,
          fillColor: hasError ? AppColors.secondaryRed : AppColors.secondaryGray,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: borderSide),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: borderSide),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: borderSide),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          isDense: true,
        ),
      ),
    );
  }


  Widget _buildDatePicker(BuildContext context, {String? errorText}) {
    final hasError = errorText != null;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedBirthDate = picked);
        }
      },
      child: SizedBox(
        height: 54,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: hasError ? AppColors.secondaryRed : AppColors.secondaryGray,
            border: Border.all(color: hasError ? AppColors.primaryRed : AppColors.secondaryGray2, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.year}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
                      : '請選擇您的出生年月日',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/arrow-down.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagSection<T>({
    required String title,
    required List<T> items,
    required String Function(T) nameOf,
    required String emptyLabel,
    required String inputLabel,
    required String inputHint,
    required TextEditingController controller,
    required Color chipColor,
    required Color chipTextColor,
    required Color chipBorderColor,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.625,
              letterSpacing: 0,
            ),
          ),
          const Divider(color: AppColors.secondaryGray2, thickness: 2, height: 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.isEmpty
                ? [_buildEmptyChip(emptyLabel)]
                : List.generate(
                    items.length,
                    (index) => _buildChip(
                      text: nameOf(items[index]),
                      chipColor: chipColor,
                      chipTextColor: chipTextColor,
                      chipBorderColor: chipBorderColor,
                      onRemove: () => onRemove(index),
                    ),
                  ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _buildLabel(inputLabel),
              _buildTextField(controller, inputHint),
              CustomButton(
                text: '加入',
                onPressed: onAdd,
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                borderRadius: 4,
                height: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkMidGray, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkMidGray, height: 1.625, letterSpacing: 0),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: chipTextColor, height: 1.625, letterSpacing: 0),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: SvgPicture.asset(
                'assets/icons/undone.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(chipTextColor, BlendMode.srcIn),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateRequiredFields() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedBirthDate != null &&
        _selectedGender != null &&
        _selectedBloodType != null &&
        _heightController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty;
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: '儲存編輯',
      onPressed: () async {
        setState(() => _submitted = true);
        if (_validateRequiredFields()) {
          final result = await AuthService.updateProfile(
            name: _nameController.text,
            gender: _selectedGender,
            birthday: _selectedBirthDate,
            height: _heightController.text,
            weight: _weightController.text,
            bloodType: _selectedBloodType,
          );
          if (!mounted) return;
          if (!result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.message ?? '更新個人資料失敗')),
            );
            return;
          }
          final syncedTags = await _syncAllergensAndMedications();
          if (!mounted) return;
          if (syncedTags) {
            Navigator.pop(context);
          }
        }
      },
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      borderRadius: 4,
      height: 40,
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return CustomButton(
      text: '取消編輯',
      onPressed: () => Navigator.pop(context),
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      borderRadius: 4,
      height: 40,
    );
  }
}
