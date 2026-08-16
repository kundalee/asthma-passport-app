import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../components/custom_button.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
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
  List<String> allergens = [];
  List<String> medications = [];

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
        height = _formatMeasurement(profile.height, 'cm');
        weight = _formatMeasurement(profile.weight, 'kg');
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

    final allergensResult = await ApiService.getAllergens();
    final medicationsResult = await ApiService.getMedications();
    if (!mounted) return;
    setState(() {
      if (allergensResult.success && allergensResult.data != null) {
        allergens = allergensResult.data!.map((a) => a.name).toList();
      }
      if (medicationsResult.success && medicationsResult.data != null) {
        medications = medicationsResult.data!.map((m) => m.name).toList();
      }
    });
  }

  // GET /user/profile returns birthday as ISO "YYYY-MM-DD"; normalize to the
  // app's "YYYY/MM/DD" display convention (used by the edit page's picker).
  // Falls back to the raw value for placeholders like "未填寫".
  String _formatBirthday(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.year.toString().padLeft(4, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}';
  }

  // GET /user/profile returns height/weight as plain numbers (e.g. "135.0");
  // drop a trailing ".0" and append the unit. Falls back to the raw value
  // for placeholders like "未填寫".
  String _formatMeasurement(String value, String unit) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    final formatted = parsed == parsed.roundToDouble() ? parsed.toStringAsFixed(0) : parsed.toString();
    return '$formatted $unit';
  }

  String get _displayName => userName.isNotEmpty ? userName : '尚未設定姓名';

  String get _genderSummary => gender.isEmpty || gender == '未填寫' ? '未設定性別' : gender;

  String get _ageSummary => age == '-' || age.isEmpty ? '未知年齡' : age;

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      header: _buildHeader(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      content: Column(
        spacing: 12,
        children: [
          _buildAccountInfoSection(),
          _buildTagSection(
            title: '過敏原',
            items: allergens,
            emptyLabel: '尚無添加過敏原',
            headerColor: AppColors.secondaryRed,
            chipColor: AppColors.secondaryRed,
            chipTextColor: AppColors.primaryRed,
            chipBorderColor: AppColors.darkRed,
          ),
          _buildTagSection(
            title: '過敏藥物',
            items: medications,
            emptyLabel: '尚無添加過敏藥物',
            headerColor: AppColors.secondaryYellow,
            chipColor: AppColors.secondaryYellow,
            chipTextColor: AppColors.primaryYellow,
            chipBorderColor: AppColors.darkYellow,
          ),
        ],
      ),
      bottomNavigation: Container(
        color: AppColors.harp,
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 8,
          children: [
            _buildEditProfileButton(context),
            _buildLogoutButton(context),
          ],
        ),
      ),
      bottomNavigationPadding: EdgeInsets.zero,
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

  Widget _buildAccountInfoSection() {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      borderRadius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildIdentityRow(),
          const Divider(color: AppColors.secondaryGray2, thickness: 2, height: 2),
          _buildInfoFields(),
        ],
      ),
    );
  }

  Widget _buildIdentityRow() {
    return Row(
      spacing: 24,
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

  Widget _buildInfoFields() {
    final fields = [
      ('生日', birthday),
      ('身高(cm)', height),
      ('體重(kg)', weight),
      ('BMI', bmi),
      ('血型', bloodType),
    ];

    return Column(
      spacing: 8,
      children: List.generate(
        fields.length,
        (index) => _buildInfoField(fields[index].$1, fields[index].$2),
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
            height: 1.625,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.625,
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection({
    required String title,
    required List<String> items,
    required String emptyLabel,
    required Color headerColor,
    required Color chipColor,
    required Color chipTextColor,
    required Color chipBorderColor,
  }) {
    return CardContainer(
      padding: EdgeInsets.zero,
      borderRadius: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: headerColor,
                border: const Border(bottom: BorderSide(color: AppColors.secondaryGrayW, width: 1)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.625,
                  letterSpacing: 0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.isEmpty
                    ? [_buildEmptyChip(emptyLabel)]
                    : items
                        .map((item) => _buildChip(
                              text: item,
                              chipColor: chipColor,
                              chipTextColor: chipTextColor,
                              chipBorderColor: chipBorderColor,
                            ))
                        .toList(),
              ),
            ),
          ],
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipBorderColor, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: chipTextColor, height: 1.5, letterSpacing: 0),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return CustomButton(
      text: '編輯個人資料',
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileEditPage()),
        );
        if (mounted) _loadUserData();
      },
      backgroundColor: AppColors.sportyBlue,
      foregroundColor: Colors.white,
      borderRadius: 4,
      height: 37,
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
