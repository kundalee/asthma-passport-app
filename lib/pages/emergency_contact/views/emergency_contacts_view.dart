import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/emergency_contact_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../services/api_service.dart';

class EmergencyContactsView extends StatefulWidget {
  final Function(int) onSwitchTab;
  final List<ContactEntry> contacts;
  final VoidCallback onSaved;

  const EmergencyContactsView({
    super.key,
    required this.onSwitchTab,
    required this.contacts,
    required this.onSaved,
  });

  @override
  State<EmergencyContactsView> createState() => _EmergencyContactsViewState();
}

class _EmergencyContactsViewState extends State<EmergencyContactsView> {
  late List<Map<String, String>> contacts;

  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _phoneControllers = {};
  final Set<int> _editingIndexes = {};

  @override
  void initState() {
    super.initState();
    contacts = widget.contacts.map((c) => {'id': c.id?.toString() ?? '', 'name': c.name, 'phone': c.info}).toList();
  }

  @override
  void didUpdateWidget(EmergencyContactsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contacts != oldWidget.contacts) {
      contacts = widget.contacts.map((c) => {'id': c.id?.toString() ?? '', 'name': c.name, 'phone': c.info}).toList();
    }
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
        contacts.removeAt(index);
        _rebuildControllerKeys(index);
      }
    });
  }

  Future<void> _saveEditing(int index) async {
    final name = _nameControllers[index]?.text ?? '';
    final phone = _phoneControllers[index]?.text ?? '';
    if (name.isEmpty && phone.isEmpty) return;

    final existingId = contacts[index]['id'];
    String? savedId = existingId;

    final result = (existingId == null || existingId.isEmpty)
        ? await ApiService.addContact(contactType: 'emergency', name: name, info: phone)
        : await ApiService.updateContact(id: existingId, contactType: 'emergency', name: name, info: phone);
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗，請稍後再試')),
      );
      return;
    }
    savedId = result.data?.id?.toString() ?? existingId;
    widget.onSaved();

    _nameControllers[index]?.dispose();
    _phoneControllers[index]?.dispose();
    _nameControllers.remove(index);
    _phoneControllers.remove(index);
    setState(() {
      contacts[index] = {'id': savedId ?? '', 'name': name, 'phone': phone};
      _editingIndexes.remove(index);
    });
  }

  Future<void> _deleteContact(int index) async {
    final existingId = contacts[index]['id'];

    if (existingId != null && existingId.isNotEmpty) {
      final result = await ApiService.deleteContact(id: existingId, contactType: 'emergency');
      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除失敗，請稍後再試')),
        );
        return;
      }
      widget.onSaved();
    }

    _nameControllers[index]?.dispose();
    _phoneControllers[index]?.dispose();
    _nameControllers.remove(index);
    _phoneControllers.remove(index);
    _editingIndexes.remove(index);
    setState(() {
      contacts.removeAt(index);
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
      contacts.add({'id': '', 'name': '', 'phone': ''});
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
        spacing: 12,
        children: [
          _buildHeader(),
          ...List.generate(contacts.length, (index) => _buildContactItem(index)),
          CustomButton(
            text: '+ 新增緊急聯絡人',
            onPressed: _addContact,
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset(
          'assets/icons/parent.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
        ),
        const Text(
          '緊急醫療救護專線',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
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
        spacing: 8,
        children: [
          if (isEditing) ...[
            CustomTextField(
              hintText: '緊急聯絡對象名稱',
              controller: _nameControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
            ),
            CustomTextField(
              hintText: '請輸入聯絡事項',
              controller: _phoneControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]'))],
            ),
          ] else ...[
            Text(
              contacts[index]['name'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
            ),
            Text(
              contacts[index]['phone'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.primaryGreen, height: 1.6),
            ),
          ],
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: CustomButton(
                  text: isEditing ? '取消編輯' : '刪除資料',
                  onPressed: () => isEditing ? _cancelEditing(index) : _deleteContact(index),
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  height: 37,
                ),
              ),
              Expanded(
                child: CustomButton(
                  text: isEditing ? '儲存編輯' : '編輯資料',
                  onPressed: () => isEditing ? _saveEditing(index) : _startEditing(index),
                  backgroundColor: AppColors.primaryGreen,
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
