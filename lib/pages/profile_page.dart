import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String gender = '未填寫';
  String birthday = '未填寫';
  String age = '-';
  String height = '未填寫';
  String weight = '未填寫';
  String bmi = '-';
  String bloodType = '未填寫';
  String avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getUserName();
    setState(() {
      userName = name ?? '';
    });

    final result = await AuthService.getProfile();
    if (!mounted) return;

    final profile = result.data;
    if (result.success && profile != null) {
      setState(() {
        userName = profile.name.isNotEmpty ? profile.name : userName;
        gender = profile.gender;
        birthday = _formatBirthday(profile.birthday);
        age = profile.age == '-' ? profile.age : '${profile.age}歲';
        height = profile.height;
        weight = profile.weight;
        bmi = profile.bmi;
        bloodType = profile.bloodType;
        // Cache-bust: the backend serves the same URL per user across
        // re-uploads, so without this any CDN/proxy/local cache for that
        // URL can serve stale bytes on every subsequent profile load.
        avatarUrl = profile.avatarUrl.isEmpty
            ? profile.avatarUrl
            : '${profile.avatarUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  // GET /user/profile returns birthday as ISO "YYYY-MM-DD"; normalize to the
  // app's "YYYY/MM/DD" display convention (used by the edit page's picker).
  // Falls back to the raw value for placeholders like "未填寫".
  String _formatBirthday(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.year.toString().padLeft(4, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      content: Column(
        spacing: 20,
        children: [
          _buildProfileSection(),
          _buildAccountInfoSection(),
        ],
      ),
      bottomNavigation: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildLogoutButton(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '會員帳號',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteMarble, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl.startsWith('http') ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.startsWith('http') ? null : const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleAvatarSelected(XFile image) async {
    final result = await AuthService.updateAvatar(image);
    if (!mounted) return;

    if (result.success && result.data != null) {
      // The backend serves the same URL per user across re-uploads, so a
      // cache-busting param is needed to bypass any CDN/proxy caching of
      // that URL, not just Flutter's own image cache.
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
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                // TODO: Handle remove image
              },
              child: Text(
                '移除圖片',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
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

  Widget _buildAccountInfoSection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      borderRadius: 10,
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
                colorFilter: const ColorFilter.mode(AppColors.solidBlue, BlendMode.srcIn),
              ),
              Text(
                '帳號資訊',
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
          _buildInfoFields(),
          const Divider(color: AppColors.sweetGrey, thickness: 2, height: 2),
          _buildInfoRowWithBadge('編輯個人資料'),
        ],
      ),
    );
  }

  Widget _buildInfoFields() {
    final fields = [
      ('姓名', userName),
      ('性別', gender),
      ('生日', birthday),
      ('年齡', age),
      ('身高', height),
      ('體重', weight),
      ('BMI', bmi),
      ('血型', bloodType),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 8,
        children: List.generate(
          fields.length,
          (index) => _buildInfoField(fields[index].$1, fields[index].$2),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileEditPage()),
          );
          if (mounted) _loadUserData();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/arrow-right.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.primaryGreen, BlendMode.srcIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CustomButton(
      text: '登出',
      onPressed: () async {
        await AuthService.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      borderRadius: 4,
      height: 37,
    );
  }
}
