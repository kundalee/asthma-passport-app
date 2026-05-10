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

  static Future<Map<String, dynamic>> getPeakFlowStatus() async {
    return {
      'measurementDate': '2025/12/10',
      'isDaytimeCompleted': true,
      'isEveningCompleted': false,
      'daytimeValue': 350,
      'daytimeStatus': 1, // 1: good, 2: moderate, 3: severe
      'eveningValue': null,
      'eveningStatus': null,
    };
  }

  static Future<Map<String, dynamic>> getActStatus() async {
    final bool isCompleted = false; // toggle between true and false
    return {
      'measurementDate': '2025/12',
      'selfAssessment': isCompleted,
      'measurementTime': isCompleted ? '2025/12/10' : null,
    };
  }

  static Future<List<Map<String, dynamic>>> getActQuestions(bool isAdultTest) async {
    const adultQuestions = [
      {
        'number': 1,
        'title': '問題一：在過去4週內，您的氣喘會讓您無法完成一般的工作、課業或家事嗎？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '絕是如此', 'score': 1},
          {'id': 2, 'label': '經常無法', 'score': 2},
          {'id': 3, 'label': '有時候', 'score': 3},
          {'id': 4, 'label': '很少', 'score': 4},
          {'id': 5, 'label': '從來沒有', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 2,
        'title': '問題二：在過去4週內，您多常發生呼吸急促的情形？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '一天超過1次', 'score': 1},
          {'id': 2, 'label': '一天1次', 'score': 2},
          {'id': 3, 'label': '一週3至6次', 'score': 3},
          {'id': 4, 'label': '一週1至2次', 'score': 4},
          {'id': 5, 'label': '完全沒有發生過', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 3,
        'title': '問題三：在過去4週內，您多常因氣喘症狀(喘鳴、咳嗽、呼吸急促、胸悶或胸痛)讓您半夜醒來或提早醒來？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '一天4次或一週以上', 'score': 1},
          {'id': 2, 'label': '一週2或3次', 'score': 2},
          {'id': 3, 'label': '一週1次', 'score': 3},
          {'id': 4, 'label': '1或2次', 'score': 4},
          {'id': 5, 'label': '完全沒有發生過', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 4,
        'title': '問題四：在過去4週內，您多常使用急救性藥或噴霧型藥物(例如：Albuterol(舒坦寧)、Ventolin(泛得林)、Berotec(備勞喘)或Bricanyl(撲可喘)等氣喘藥物)？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '一天3次或3次以上', 'score': 1},
          {'id': 2, 'label': '一天1或2次', 'score': 2},
          {'id': 3, 'label': '一週2或3次', 'score': 3},
          {'id': 4, 'label': '一週1次或更少', 'score': 4},
          {'id': 5, 'label': '完全沒有使用過', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 5,
        'title': '問題五：在過去4週內，您認為自己的氣喘控制程度如何？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '完全沒有受到控制', 'score': 1},
          {'id': 2, 'label': '控制不好', 'score': 2},
          {'id': 3, 'label': '稍微控制', 'score': 3},
          {'id': 4, 'label': '控制良好', 'score': 4},
          {'id': 5, 'label': '完全控制', 'score': 5},
        ],
        'selected_option_id': null,
      },
    ];

    const childQuestions = [
      {
        'number': 1,
        'title': '問題一：今天你的氣喘狀況怎麼樣？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '非常不好', 'score': 0},
          {'id': 2, 'label': '不好', 'score': 1},
          {'id': 3, 'label': '好', 'score': 2},
          {'id': 4, 'label': '非常好', 'score': 3},
        ],
        'selected_option_id': null,
      },
      {
        'number': 2,
        'title': '問題二：當你跑步、運動或玩耍時，你的氣喘會造成你的問題嗎？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '我無法做，我想做的', 'score': 0},
          {'id': 2, 'label': '那是個問題，我並不喜歡', 'score': 1},
          {'id': 3, 'label': '是有一點問題，但還好', 'score': 2},
          {'id': 4, 'label': '並不會造成問題', 'score': 3},
        ],
        'selected_option_id': null,
      },
      {
        'number': 3,
        'title': '問題三：你會因為你的氣喘而咳喘嗎？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '會一直如此', 'score': 0},
          {'id': 2, 'label': '會大部分時候', 'score': 1},
          {'id': 3, 'label': '會有時候', 'score': 2},
          {'id': 4, 'label': '不會從來沒有', 'score': 3},
        ],
        'selected_option_id': null,
      },
      {
        'number': 4,
        'title': '問題四：你會因為你的氣喘在半夜醒來嗎？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '會一直如此', 'score': 0},
          {'id': 2, 'label': '會大部分時候', 'score': 1},
          {'id': 3, 'label': '會有時候', 'score': 2},
          {'id': 4, 'label': '不會從來沒有', 'score': 3},
        ],
        'selected_option_id': null,
      },
      {
        'number': 5,
        'title': '問題五：在過去4週，平均一個月內有幾天您的小孩在白天出現了氣喘症狀？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '每天都有', 'score': 0},
          {'id': 2, 'label': '19-24天', 'score': 1},
          {'id': 3, 'label': '11-18天', 'score': 2},
          {'id': 4, 'label': '4-10天', 'score': 3},
          {'id': 5, 'label': '1-3天', 'score': 4},
          {'id': 6, 'label': '完全沒有', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 6,
        'title': '問題六：在過去4週，平均一個月內有幾天您的小孩在白天出現了氣喘症狀？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '每天都有', 'score': 0},
          {'id': 2, 'label': '19-24天', 'score': 1},
          {'id': 3, 'label': '11-18天', 'score': 2},
          {'id': 4, 'label': '4-10天', 'score': 3},
          {'id': 5, 'label': '1-3天', 'score': 4},
          {'id': 6, 'label': '完全沒有', 'score': 5},
        ],
        'selected_option_id': null,
      },
      {
        'number': 7,
        'title': '問題七：在過去4週，平均一個月內有幾天您的小孩在白天出現了氣喘症狀？',
        'type': 'scale',
        'options': [
          {'id': 1, 'label': '每天都有', 'score': 0},
          {'id': 2, 'label': '19-24天', 'score': 1},
          {'id': 3, 'label': '11-18天', 'score': 2},
          {'id': 4, 'label': '4-10天', 'score': 3},
          {'id': 5, 'label': '1-3天', 'score': 4},
          {'id': 6, 'label': '完全沒有', 'score': 5},
        ],
        'selected_option_id': null,
      },
    ];

    return isAdultTest ? adultQuestions : childQuestions;
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

  static Future<int> submitPeakFlowMeasurement({
    required String measurementDate,
    required bool isDaytime,
    required String measurementValue,
  }) async {
    // TODO: Replace with actual API call
    // Sample logic: determine status based on measurement value
    final value = int.tryParse(measurementValue) ?? 0;
    if (value >= 280) {
      return 1; // Good control
    } else if (value >= 240) {
      return 2; // Moderate control
    } else {
      return 3; // Poor control
    }
  }

  static Future<Map<String, dynamic>> submitAssessment({
    required bool isAdultTest,
    required int totalScore,
    required int controlLevel,
  }) async {
    // TODO: Replace with actual API call to server
    final now = DateTime.now();
    final formattedDate = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    return {
      'success': true,
      'measurementDate': formattedDate,
    };
  }

  static Future<Map<String, dynamic>> calculateActResult({
    required bool isAdultTest,
    required List<int?> answers,
  }) async {
    // TODO: Replace with actual API call
    // Calculate total score based on answers
    int totalScore = 0;
    for (final answer in answers) {
      if (answer != null) {
        totalScore += answer;
      }
    }

    // Determine control level
    int controlLevel;
    if (isAdultTest) {
      if (totalScore >= 25) {
        controlLevel = 1; // Well controlled
      } else if (totalScore >= 20) {
        controlLevel = 2; // Partially controlled
      } else {
        controlLevel = 3; // Uncontrolled
      }
    } else {
      // Child test scoring - only 2 levels
      if (totalScore >= 20) {
        controlLevel = 1; // Well controlled
      } else {
        controlLevel = 2; // Not well controlled
      }
    }

    return {
      'totalScore': totalScore,
      'controlLevel': controlLevel,
      'measurementDate': DateTime.now().toString().split(' ')[0],
    };
  }
}
