import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../components/custom_dropdown.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
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
                  children: [
                    _buildLabeledField('姓名', _nameController, '請輸入您的姓名'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledDropdown('性別', _selectedGender, ['男性', '女性'], (value) {
                            setState(() => _selectedGender = value);
                          }, '請選擇'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabeledDropdown('血型', _selectedBloodType, ['A型', 'B型', 'AB型', 'O型'], (value) {
                            setState(() => _selectedBloodType = value);
                          }, '請選擇'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledField('身高', _heightController, '請輸入您的身高'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabeledField('體重', _weightController, '請輸入您的體重'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledDatePicker(context),
                    const SizedBox(height: 16),
                    _buildSaveButton(),
                    const SizedBox(height: 16),
                    _buildCancelButton(context),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
          const SizedBox(width: 24),
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
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        _buildTextField(controller, placeholder),
      ],
    );
  }

  Widget _buildLabeledDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('生日'),
        const SizedBox(height: 8),
        _buildDatePicker(context),
      ],
    );
  }

  Widget _buildLabeledDropdown(String label, String? value, List<String> items, Function(String?) onChanged, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
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
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
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
            color: AppColors.inputBackground,
            border: Border.all(color: AppColors.inputBorder, width: 2),
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
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // TODO: Save profile data
          Navigator.pop(context);
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
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      borderRadius: 4,
      height: 40,
    );
  }
}
