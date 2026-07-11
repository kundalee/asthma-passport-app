import '../models/act_models.dart';
import '../models/diary_models.dart';
import '../models/emergency_contact_models.dart';
import '../models/master_models.dart';
import '../models/passport_models.dart';
import '../models/patient_info_models.dart';
import '../models/peak_flow_models.dart';
import '../models/weather_models.dart';
import 'api_client.dart';

class ApiService {
  static Future<ApiResult<WeatherInfo>> getWeather(String stationName) async {
    final (statusCode, data) = await ApiClient.send('GET', '/weather/info?station_name=$stationName');

    if (statusCode == 200) {
      return ApiResult.success(WeatherInfo.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法取得天氣資訊');
  }

  static Future<ApiResult<ContactList>> getContacts() async {
    final (statusCode, data) = await ApiClient.send('GET', '/contact/load', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(ContactList.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法取得聯絡資訊', authenticated: true);
  }

  // /contact/save only creates new contacts - there's no update endpoint yet.
  static Future<ApiResult<ContactEntry>> addContact({
    required String contactType,
    required String name,
    required String info,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/contact/save',
      body: {'contact_type': contactType, 'name': name, 'info': info},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(ContactEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法儲存聯絡資訊', authenticated: true);
  }

  static Future<ApiResult<ContactEntry>> updateContact({
    required String id,
    required String contactType,
    required String name,
    required String info,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'PUT',
      '/contact/update?target=$id',
      body: {'contact_type': contactType, 'name': name, 'info': info},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(ContactEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法更新聯絡資訊', authenticated: true);
  }

  static Future<ApiResult<void>> deleteContact({
    required String id,
    required String contactType,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'DELETE',
      '/contact/delete?target=$id&contact_type=$contactType',
      authenticated: true,
    );

    if (statusCode == 200) {
      return const ApiResult.success();
    }

    return ApiClient.failure(statusCode, data, '無法刪除聯絡資訊', authenticated: true);
  }

  static Future<ApiResult<List<AllergenEntry>>> getAllergens() async {
    final (statusCode, data) = await ApiClient.send('GET', '/allergen/load', authenticated: true);

    if (statusCode == 200) {
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((a) => AllergenEntry.fromJson(a as Map<String, dynamic>))
          .toList();
      return ApiResult.success(list);
    }

    return ApiClient.failure(statusCode, data, '無法取得過敏原清單', authenticated: true);
  }

  static Future<ApiResult<AllergenEntry>> saveAllergen(String allergen) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/allergen/save',
      body: {'allergens': [allergen]},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(AllergenEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法儲存過敏原', authenticated: true);
  }

  static Future<ApiResult<AllergenEntry>> updateAllergen({
    required String id,
    required String name,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'PUT',
      '/allergen/update?target=$id&new_name=$name',
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(AllergenEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法更新過敏原', authenticated: true);
  }

  static Future<ApiResult<void>> deleteAllergen(String id) async {
    final (statusCode, data) = await ApiClient.send(
      'DELETE',
      '/allergen/delete?target=$id',
      authenticated: true,
    );

    if (statusCode == 200) {
      return const ApiResult.success();
    }

    return ApiClient.failure(statusCode, data, '無法刪除過敏原', authenticated: true);
  }

  static Future<ApiResult<List<MedicationEntry>>> getMedications() async {
    final (statusCode, data) = await ApiClient.send('GET', '/medication/load', authenticated: true);

    if (statusCode == 200) {
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((m) => MedicationEntry.fromJson(m as Map<String, dynamic>))
          .toList();
      return ApiResult.success(list);
    }

    return ApiClient.failure(statusCode, data, '無法取得用藥清單', authenticated: true);
  }

  static Future<ApiResult<MedicationEntry>> saveMedication(String medication) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/medication/save',
      body: {'medications': [medication]},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(MedicationEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法儲存用藥資訊', authenticated: true);
  }

  static Future<ApiResult<MedicationEntry>> updateMedication({
    required String id,
    required String name,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'PUT',
      '/medication/update?target=$id&new_name=$name',
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(MedicationEntry.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法更新用藥資訊', authenticated: true);
  }

  static Future<ApiResult<void>> deleteMedication(String id) async {
    final (statusCode, data) = await ApiClient.send(
      'DELETE',
      '/medication/delete?target=$id',
      authenticated: true,
    );

    if (statusCode == 200) {
      return const ApiResult.success();
    }

    return ApiClient.failure(statusCode, data, '無法刪除用藥資訊', authenticated: true);
  }

  static String _todayDateStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<List<Map<String, dynamic>>> getTodayTests() async {
    final dateStr = _todayDateStr();

    final diaryFuture = getDiaryStatus(dateStr);
    final peakFlowFuture = getPeakFlowStatus(dateStr);
    final actFuture = getActStatus(dateStr);

    final diaryResult = await diaryFuture;
    final peakFlowResult = await peakFlowFuture;
    final actResult = await actFuture;

    final isDiaryDone = diaryResult.data?.isCompleted ?? false;
    final isPeakFlowDone = (peakFlowResult.data?.morning.isCompleted ?? false) && (peakFlowResult.data?.night.isCompleted ?? false);
    final isActDone = actResult.data?.isCompleted ?? false;

    return [
      {'id': 1, 'name': '氣喘日記', 'status': isDiaryDone ? 1 : 0},
      {'id': 2, 'name': '尖峰吐氣流量', 'status': isPeakFlowDone ? 1 : 0},
      {'id': 3, 'name': '氣喘控制測驗', 'status': isActDone ? 1 : 0},
    ];
  }

  static Future<ApiResult<PassportStatus>> getPassport(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/passport/load?date_str=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(PassportStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得健康護照資料', authenticated: true);
  }

  static Future<ApiResult<MedicationOptions>> getMedicationOptions() async {
    final (statusCode, data) = await ApiClient.send('GET', '/passport/list', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(MedicationOptions.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法取得藥物清單', authenticated: true);
  }

  static Future<ApiResult<DiaryStatus>> getDiaryStatus(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/diary/load?date_str=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(DiaryStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得氣喘日記資料', authenticated: true);
  }

  static Future<ApiResult<DiarySaveResult>> saveDiary({
    required String dateStr,
    required List<DiaryQuestion> questions,
    required List<int?> selectedOptionIds,
  }) async {
    final answers = <Map<String, dynamic>>[];
    for (int i = 0; i < questions.length && i < selectedOptionIds.length; i++) {
      final selectedId = selectedOptionIds[i];
      if (selectedId == null) continue;
      final option = questions[i].options.firstWhere(
        (o) => o.id == selectedId,
        orElse: () => const DiaryOption(id: -1, order: 0, text: '', score: 0),
      );
      answers.add({'question_id': questions[i].id, 'selected_value': option.score});
    }

    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/diary/save',
      body: {'record_date': dateStr, 'answers': answers},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(DiarySaveResult.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '儲存失敗', authenticated: true);
  }

  static Future<ApiResult<PeakFlowStatus>> getPeakFlowStatus(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/pefr/load?date_str=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(PeakFlowStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得尖峰吐氣流量資料', authenticated: true);
  }

  // 1: good control, 2: moderate control, 3: poor control
  static int peakFlowStatusForValue(double value) {
    if (value >= 280) return 1;
    if (value >= 240) return 2;
    return 3;
  }

  static Future<ApiResult<PeakFlowSaveResult>> savePeakFlowMeasurement({
    required String dateStr,
    required bool isDaytime,
    required double value,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/pefr/save',
      body: {
        'record_date': dateStr,
        'pefr_value': value.round(),
        'time_day': isDaytime ? 'm' : 'n',
      },
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(PeakFlowSaveResult.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '儲存失敗', authenticated: true);
  }

  static Future<ApiResult<ActStatus>> getActStatus(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/act/load?date_str=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(ActStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得氣喘控制測驗資料', authenticated: true);
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

  static Future<ApiResult<MasterQuiz>> getMasterQuestions() async {
    final (statusCode, data) = await ApiClient.send('GET', '/quiz/load', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(MasterQuiz.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得測驗題目', authenticated: true);
  }

  static Future<ApiResult<MasterQuizResult>> saveMasterQuiz(List<Map<String, dynamic>> answers) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/quiz/save',
      body: {'answers': answers},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(MasterQuizResult.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法儲存測驗結果', authenticated: true);
  }

  static Future<List<String>> getHistoryMonths() async {
    // TODO: Replace with actual API call
    // GET /api/history/months
    return [
      '2026/05',
      '2026/04',
      '2026/03',
      '2026/02',
      '2026/01',
      '2025/12',
      '2025/11',
    ];
  }

  static Future<Map<String, dynamic>> getHistorySummary(String month) async {
    return {
      'recordedDays': 20,
      'averageScore': 2,
      'pefrAverage': 253,
      'actScore': 23,
    };
  }

  static Future<List<Map<String, dynamic>>> getHistoryChartData(String month) async {
    return [
      {'day': 1, 'score': 3},
      {'day': 2, 'score': 1},
      {'day': 3, 'score': 2},
      {'day': 4, 'score': 7},
      {'day': 5, 'score': 4},
      {'day': 6, 'score': 0},
      {'day': 7, 'score': 1},
      {'day': 8, 'score': 1},
      {'day': 9, 'score': 2},
      {'day': 10, 'score': 0},
      {'day': 11, 'score': 4},
      {'day': 12, 'score': 1},
      {'day': 13, 'score': 0},
      {'day': 14, 'score': 2},
      {'day': 15, 'score': 1},
      {'day': 16, 'score': 0},
      {'day': 17, 'score': 3},
      {'day': 18, 'score': 3},
      {'day': 19, 'score': 0},
      {'day': 20, 'score': 1},
    ];
  }
}
