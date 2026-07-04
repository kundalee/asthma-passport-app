class LoginResult {
  final String token;
  final String userName;
  final bool isFirstLogin;

  const LoginResult({required this.token, required this.userName, required this.isFirstLogin});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['access_token'] as String,
      userName: json['user_name'] ?? '',
      isFirstLogin: json['is_first_login'] ?? false,
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String gender;
  final String birthday;
  final String age;
  final String height;
  final String weight;
  final String bmi;
  final String bloodType;
  final String avatarUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.birthday,
    required this.age,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.bloodType,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '未填寫',
      birthday: json['birthday'] ?? '未填寫',
      age: json['age']?.toString() ?? '-',
      height: json['height'] ?? '未填寫',
      weight: json['weight'] ?? '未填寫',
      bmi: json['bmi']?.toString() ?? '-',
      bloodType: json['blood_type'] ?? '未填寫',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}
