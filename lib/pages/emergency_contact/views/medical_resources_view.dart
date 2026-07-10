import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/emergency_contact_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/card_container.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../services/api_service.dart';

class MedicalResourcesView extends StatefulWidget {
  final Function(int) onSwitchTab;
  final List<ContactEntry> contacts;
  final VoidCallback onSaved;

  const MedicalResourcesView({
    super.key,
    required this.onSwitchTab,
    required this.contacts,
    required this.onSaved,
  });

  @override
  State<MedicalResourcesView> createState() => _MedicalResourcesViewState();
}

class _MedicalResourcesViewState extends State<MedicalResourcesView> {
  late List<Map<String, String>> contacts;

  // track which indexes are in edit mode, with their controllers
  final Map<int, TextEditingController> _titleControllers = {};
  final Map<int, TextEditingController> _infoControllers = {};
  final Set<int> _editingIndexes = {};

  @override
  void initState() {
    super.initState();
    contacts = widget.contacts.map((c) => {'id': c.id?.toString() ?? '', 'title': c.name, 'contactInfo': c.info}).toList();
  }

  @override
  void didUpdateWidget(MedicalResourcesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contacts != oldWidget.contacts) {
      contacts = widget.contacts.map((c) => {'id': c.id?.toString() ?? '', 'title': c.name, 'contactInfo': c.info}).toList();
    }
  }

  void _startEditing(int index) {
    _titleControllers[index] = TextEditingController(text: contacts[index]['title'] ?? '');
    _infoControllers[index] = TextEditingController(text: contacts[index]['contactInfo'] ?? '');
    setState(() {
      _editingIndexes.add(index);
    });
  }

  void _cancelEditing(int index) {
    _titleControllers[index]?.dispose();
    _infoControllers[index]?.dispose();
    _titleControllers.remove(index);
    _infoControllers.remove(index);
    setState(() {
      _editingIndexes.remove(index);
      // if this was a newly added empty contact, remove it
      if (contacts[index]['title'] == '' && contacts[index]['contactInfo'] == '') {
        contacts.removeAt(index);
        _rebuildControllerKeys(index);
      }
    });
  }

  Future<void> _saveEditing(int index) async {
    final title = _titleControllers[index]?.text ?? '';
    final info = _infoControllers[index]?.text ?? '';
    if (title.isEmpty && info.isEmpty) return;

    final existingId = contacts[index]['id'];
    String? savedId = existingId;

    final result = (existingId == null || existingId.isEmpty)
        ? await ApiService.addContact(contactType: 'medical', name: title, info: info)
        : await ApiService.updateContact(id: existingId, contactType: 'medical', name: title, info: info);
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗，請稍後再試')),
      );
      return;
    }
    savedId = result.data?.id?.toString() ?? existingId;
    widget.onSaved();

    _titleControllers[index]?.dispose();
    _infoControllers[index]?.dispose();
    _titleControllers.remove(index);
    _infoControllers.remove(index);
    setState(() {
      contacts[index] = {'id': savedId ?? '', 'title': title, 'contactInfo': info};
      _editingIndexes.remove(index);
    });
  }

  Future<void> _deleteContact(int index) async {
    final existingId = contacts[index]['id'];

    if (existingId != null && existingId.isNotEmpty) {
      final result = await ApiService.deleteContact(id: existingId, contactType: 'medical');
      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '刪除失敗，請稍後再試')),
        );
        return;
      }
      widget.onSaved();
    }

    _titleControllers[index]?.dispose();
    _infoControllers[index]?.dispose();
    _titleControllers.remove(index);
    _infoControllers.remove(index);
    _editingIndexes.remove(index);
    setState(() {
      contacts.removeAt(index);
      _rebuildControllerKeys(index);
    });
  }

  // after deleting, shift controller keys above the deleted index down by 1
  void _rebuildControllerKeys(int deletedIndex) {
    final newEditing = <int>{};
    final newTitles = <int, TextEditingController>{};
    final newInfos = <int, TextEditingController>{};
    for (final i in _editingIndexes) {
      if (i > deletedIndex) {
        newEditing.add(i - 1);
        newTitles[i - 1] = _titleControllers[i]!;
        newInfos[i - 1] = _infoControllers[i]!;
      } else if (i < deletedIndex) {
        newEditing.add(i);
        newTitles[i] = _titleControllers[i]!;
        newInfos[i] = _infoControllers[i]!;
      }
    }
    _editingIndexes
      ..clear()
      ..addAll(newEditing);
    _titleControllers
      ..clear()
      ..addAll(newTitles);
    _infoControllers
      ..clear()
      ..addAll(newInfos);
  }

  void _addContact() {
    setState(() {
      contacts.add({'id': '', 'title': '', 'contactInfo': ''});
      final newIndex = contacts.length - 1;
      _titleControllers[newIndex] = TextEditingController();
      _infoControllers[newIndex] = TextEditingController();
      _editingIndexes.add(newIndex);
    });
  }

  @override
  void dispose() {
    for (final c in _titleControllers.values) { c.dispose(); }
    for (final c in _infoControllers.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        spacing: 12,
        children: [
          _buildEmergencyHotlineCard(),
          ...List.generate(contacts.length, (index) => _buildContactItem(index)),
          CustomButton(
            text: '+ 新增緊急醫療連絡',
            onPressed: _addContact,
            backgroundColor: AppColors.funGreen,
            foregroundColor: Colors.white,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHotlineCard() {
    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            SvgPicture.asset(
              'assets/icons/emergency.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            const Text(
              '緊急醫療救護專線',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5, letterSpacing: 0),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('緊急救護', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
              Text('119', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
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
              controller: _titleControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
            ),
            CustomTextField(
              hintText: '請輸入聯絡事項',
              controller: _infoControllers[index],
              backgroundColor: Colors.white,
              borderRadius: 4,
              dynamicBorderColor: false,
            ),
          ] else ...[
            Text(
              contacts[index]['title'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
            ),
            Text(
              contacts[index]['contactInfo'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.funGreen, height: 1.6),
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
