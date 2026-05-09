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

  static Future<Map<String, dynamic>> getAsthmaDiaryStatus() async {
    final bool isCompleted = false; // toggle between true and false
    return {
      'measurementDate': '2025/12/10',
      'selfAssessment': isCompleted,
      'measurementTime': isCompleted ? '2025/12/10' : null,
    };
  }

  static Future<List<Map<String, dynamic>>> getAssessmentQuestions() async {
    final bool isCompleted = false; // toggle between true and false
    final bool isGood = false; // toggle between true (good) and false (bad)

    final selectedAnswers = isCompleted
        ? (isGood ? [0, 1, 1, 0, 0] : [3, 1, 1, 3, 0])
        : [0, 0, 0, 0, 0];

    return [
      {
        'number': 1,
        'title': '夜間咳嗽',
        'type': 'scale',
        'options': [
          {'id': 0, 'label': '無症狀'},
          {'id': 1, 'label': '輕微'},
          {'id': 2, 'label': '中度'},
          {'id': 3, 'label': '嚴重'},
          {'id': 4, 'label': '極嚴重'},
        ],
        'selected_option_id': selectedAnswers[0],
      },
      {
        'number': 2,
        'title': '胸悶或深吸困難',
        'type': 'scale',
        'options': [
          {'id': 0, 'label': '無症狀'},
          {'id': 1, 'label': '輕微'},
          {'id': 2, 'label': '中度'},
          {'id': 3, 'label': '嚴重'},
          {'id': 4, 'label': '極嚴重'},
        ],
        'selected_option_id': selectedAnswers[1],
      },
      {
        'number': 3,
        'title': '白天咳嗽或呼吸困難',
        'type': 'scale',
        'options': [
          {'id': 0, 'label': '無症狀'},
          {'id': 1, 'label': '輕微'},
          {'id': 2, 'label': '中度'},
          {'id': 3, 'label': '嚴重'},
          {'id': 4, 'label': '極嚴重'},
        ],
        'selected_option_id': selectedAnswers[2],
      },
      {
        'number': 4,
        'title': '白天喘喘',
        'type': 'scale',
        'options': [
          {'id': 0, 'label': '無症狀'},
          {'id': 1, 'label': '輕微'},
          {'id': 2, 'label': '中度'},
          {'id': 3, 'label': '嚴重'},
          {'id': 4, 'label': '極嚴重'},
        ],
        'selected_option_id': selectedAnswers[3],
      },
      {
        'number': 5,
        'title': '運動後有喘喘嗎',
        'type': 'yes_no',
        'options': [
          {'id': 0, 'label': '否'},
          {'id': 1, 'label': '是'},
        ],
        'selected_option_id': selectedAnswers[4],
      },
    ];
  }
}
