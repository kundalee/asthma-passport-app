import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';
import '../services/auth_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const _genderOptions = ['男性', '女性'];
  static const _bloodTypeOptions = ['A型', 'B型', 'AB型', 'O型'];
  // Placeholder values UserProfile falls back to when a field isn't set;
  // they're for display only and shouldn't populate the edit form.
  static const _placeholderValues = {'未填寫', '-'};

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emailController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _heightController = TextEditingController(text: '');
    _weightController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _selectedGender = null;
    _selectedBloodType = null;
    _selectedBirthDate = null;
    _loadProfile();
  }

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
      });
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _buildLabeledField('姓名', _nameController, '請輸入您的姓名'),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: _buildLabeledDropdown('性別', _selectedGender, _genderOptions, (value) {
                            setState(() => _selectedGender = value);
                          }, '請選擇'),
                        ),
                        Expanded(
                          child: _buildLabeledDropdown('血型', _selectedBloodType, _bloodTypeOptions, (value) {
                            setState(() => _selectedBloodType = value);
                          }, '請選擇'),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: _buildLabeledField('身高', _heightController, '請輸入您的身高'),
                        ),
                        Expanded(
                          child: _buildLabeledField('體重', _weightController, '請輸入您的體重'),
                        ),
                      ],
                    ),
                    _buildLabeledDatePicker(context),
                    _buildSaveButton(),
                    _buildCancelButton(context),
                  ],
                ),
              ),
            ],
          ),
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
            '編輯個人資料',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1.5,
        letterSpacing: 0,
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel(label),
        _buildTextField(controller, placeholder),
      ],
    );
  }

  Widget _buildLabeledDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel('生日'),
        _buildDatePicker(context),
      ],
    );
  }

  Widget _buildLabeledDropdown(String label, String? value, List<String> items, Function(String?) onChanged, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildLabel(label),
        CustomDropdown(
          value: value,
          items: items,
          onChanged: onChanged,
          placeholder: placeholder,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: 0,
          )
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder) {
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
          fillColor: AppColors.powder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.whiteMarble, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          isDense: true,
        ),
      ),
    );
  }


  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime.now(),
          firstDate: DateTime(1990),
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
            color: AppColors.powder,
            border: Border.all(color: AppColors.whiteMarble, width: 2),
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

  Widget _buildSaveButton() {
    return CustomButton(
      text: '儲存編輯',
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          final result = await AuthService.updateProfile(
            name: _nameController.text,
            gender: _selectedGender,
            birthday: _selectedBirthDate,
            height: _heightController.text,
            weight: _weightController.text,
            bloodType: _selectedBloodType,
          );
          if (!mounted) return;
          if (result.success) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.message ?? '更新個人資料失敗')),
            );
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
