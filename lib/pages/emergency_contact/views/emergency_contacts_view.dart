import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../services/emergency_contact_service.dart';

class EmergencyContactsView extends StatefulWidget {
  final Function(int) onSwitchTab;

  const EmergencyContactsView({
    super.key,
    required this.onSwitchTab,
  });

  @override
  State<EmergencyContactsView> createState() => _EmergencyContactsViewState();
}

class _EmergencyContactsViewState extends State<EmergencyContactsView> {
  List<Map<String, String>> contacts = [];
  final EmergencyContactService _service = EmergencyContactService();

  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _phoneControllers = {};
  final Set<int> _editingIndexes = {};

  @override
  void initState() {
    super.initState();
    contacts = _service.getPersonalContacts();
  }

  void _startEditing(int index) {
    _nameControllers[index] = TextEditingController(text: contacts[index]['name'] ?? '');
    _phoneControllers[index] = TextEditingController(text: contacts[index]['phone'] ?? '');
    setState(() {
      _editingIndexes.add(index);
    });
  }

  void _cancelEditing(int index) {
    _nameControllers[index]?.dispose();
    _phoneControllers[index]?.dispose();
    _nameControllers.remove(index);
    _phoneControllers.remove(index);
    setState(() {
      _editingIndexes.remove(index);
      if (contacts[index]['name'] == '' && contacts[index]['phone'] == '') {
        contacts = _service.deletePersonalContact(index);
        _rebuildControllerKeys(index);
      }
    });
  }

  void _saveEditing(int index) {
    final name = _nameControllers[index]?.text ?? '';
    final phone = _phoneControllers[index]?.text ?? '';
    if (name.isEmpty && phone.isEmpty) return;

    _nameControllers[index]?.dispose();
    _phoneControllers[index]?.dispose();
    _nameControllers.remove(index);
    _phoneControllers.remove(index);
    setState(() {
      contacts = _service.updatePersonalContact(index, {'name': name, 'phone': phone});
      _editingIndexes.remove(index);
    });
  }

  void _deleteContact(int index) {
    _nameControllers[index]?.dispose();
    _phoneControllers[index]?.dispose();
    _nameControllers.remove(index);
    _phoneControllers.remove(index);
    _editingIndexes.remove(index);
    setState(() {
      contacts = _service.deletePersonalContact(index);
      _rebuildControllerKeys(index);
    });
  }

  void _rebuildControllerKeys(int deletedIndex) {
    final newEditing = <int>{};
    final newNames = <int, TextEditingController>{};
    final newPhones = <int, TextEditingController>{};
    for (final i in _editingIndexes) {
      if (i > deletedIndex) {
        newEditing.add(i - 1);
        newNames[i - 1] = _nameControllers[i]!;
        newPhones[i - 1] = _phoneControllers[i]!;
      } else if (i < deletedIndex) {
        newEditing.add(i);
        newNames[i] = _nameControllers[i]!;
        newPhones[i] = _phoneControllers[i]!;
      }
    }
    _editingIndexes..clear()..addAll(newEditing);
    _nameControllers..clear()..addAll(newNames);
    _phoneControllers..clear()..addAll(newPhones);
  }

  void _addContact() {
    setState(() {
      contacts = _service.addPersonalContact({'name': '', 'phone': ''});
      final newIndex = contacts.length - 1;
      _nameControllers[newIndex] = TextEditingController();
      _phoneControllers[newIndex] = TextEditingController();
      _editingIndexes.add(newIndex);
    });
  }

  @override
  void dispose() {
    for (final c in _nameControllers.values) { c.dispose(); }
    for (final c in _phoneControllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          ...List.generate(
            contacts.length,
            (index) => Column(
              children: [
                _buildContactItem(index),
                if (index < contacts.length - 1) const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: '+ 新增緊急聯絡人',
            onPressed: _addContact,
            backgroundColor: AppColors.funGreen,
            foregroundColor: Colors.white,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/parent.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              '緊急醫療救護專線',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(int index) {
    final isEditing = _editingIndexes.contains(index);

    return CardContainer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            CustomTextField(
              hintText: '緊急聯絡對象名稱',
              controller: _nameControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: '請輸入聯絡事項',
              controller: _phoneControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
            ),
          ] else ...[
            Text(
              contacts[index]['name'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              contacts[index]['phone'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.funGreen, height: 1.6),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: isEditing ? '取消編輯' : '刪除資料',
                  onPressed: () => isEditing ? _cancelEditing(index) : _deleteContact(index),
                  backgroundColor: AppColors.strongRed,
                  foregroundColor: Colors.white,
                  height: 37,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: isEditing ? '儲存編輯' : '編輯資料',
                  onPressed: () => isEditing ? _saveEditing(index) : _startEditing(index),
                  backgroundColor: AppColors.funGreen,
                  foregroundColor: Colors.white,
                  height: 37,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
