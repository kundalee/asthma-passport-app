class ApiService {
  static Future<Map<String, dynamic>> getWeather(String location) async {
    return {
      'aqi': 39,
      'temperature': 24.5,
      'humidity': 10,
      'pm25': 12.3,
    };
  }

  static Future<List<Map<String, dynamic>>> getTodayTests() async {
    return [
      {'id': 1, 'name': '氣喘日記', 'status': 0},
      {'id': 2, 'name': '尖峰吐氣流量', 'status': 0},
      {'id': 3, 'name': '氣喘控制測驗', 'status': 0},
    ];
  }

  static Future<Map<String, dynamic>> getPassport() async {
    return {
      'id': 'passport_123',
      'name': '王曉明',
      'dateOfBirth': '2024/01/15',
      'code': '123456',
      'sex': '男',
      'age': 9,
      'barcode': 'P<TAIWAN<SIAO<SMING<<<<<<<<<<<<<<<<<\nT23456<<<TWN2015081520300915<<<<<<<<<<',
    };
  }
}
