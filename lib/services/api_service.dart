import 'package:flutter/foundation.dart';

import '../models/act_models.dart';
import '../models/diary_models.dart';
import '../models/emergency_contact_models.dart';
import '../models/history_models.dart';
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

    if (statusCode == 201) {
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

    if (statusCode == 201) {
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

    if (statusCode == 201) {
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

    // Each status fetch is isolated so a failure parsing one (e.g. a
    // backend contract change) shows that single item as not-done instead
    // of blanking out the whole "今日檢測" section.
    final isDiaryDone = await _isTestDone(() async => (await getDiaryStatus(dateStr)).data?.isCompleted ?? false, '氣喘日記');
    final isPeakFlowDone = await _isTestDone(() async {
      final status = (await getPeakFlowStatus(dateStr)).data;
      return (status?.morning.isCompleted ?? false) && (status?.night.isCompleted ?? false);
    }, '尖峰吐氣流量');
    final isActDone = await _isTestDone(() async => (await getActStatus(dateStr)).data?.isCompleted ?? false, '氣喘控制測驗');

    return [
      {'id': 1, 'name': '氣喘日記', 'status': isDiaryDone ? 1 : 0},
      {'id': 2, 'name': '尖峰吐氣流量', 'status': isPeakFlowDone ? 1 : 0},
      {'id': 3, 'name': '氣喘控制測驗', 'status': isActDone ? 1 : 0},
    ];
  }

  static Future<bool> _isTestDone(Future<bool> Function() fetch, String label) async {
    try {
      return await fetch();
    } catch (e) {
      debugPrint('getTodayTests: $label status failed to load: $e');
      return false;
    }
  }

  static Future<ApiResult<PassportStatus>> getPassport(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/passport/load?target_date=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(PassportStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得健康護照資料', authenticated: true);
  }

  static Future<ApiResult<SavePlanResult>> savePassportPlan({
    required String recordDate,
    required int? statusLevel,
    required String? notes,
    required String? doctorName,
    required List<Map<String, dynamic>> medications,
  }) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/passport/save',
      body: {
        'record_date': recordDate,
        'status_level': statusLevel,
        'notes': notes,
        'doctor_name': doctorName,
        'medications': medications,
      },
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(SavePlanResult.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法儲存行動計畫', authenticated: true);
  }

  static Future<ApiResult<MedicationOptions>> getMedicationOptions() async {
    final (statusCode, data) = await ApiClient.send('GET', '/passport/list', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(MedicationOptions.fromJson(data['data']));
    }

    return ApiClient.failure(statusCode, data, '無法取得藥物清單', authenticated: true);
  }

  static Future<ApiResult<DiaryStatus>> getDiaryStatus(String dateStr) async {
    final (statusCode, data) = await ApiClient.send('GET', '/diary/load?target_date=$dateStr', authenticated: true);

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
    final (statusCode, data) = await ApiClient.send('GET', '/pefr/load?target_date=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(PeakFlowStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得尖峰吐氣流量資料', authenticated: true);
  }

  // 1: good control, 2: moderate control, 3: poor control
  // 尖峰呼氣流速預估值 (predicted personal-best PEFR), per the standard formulas:
  //   adult male   (height in m):  [((height x 5.48) + 1.58) - (age x 0.041)] x 60
  //   adult female (height in m):  [((height x 3.72) + 2.24) - (age x 0.03)] x 60
  //   child        (height in cm): (height - 100) x 5 + 100
  // Adult/child split at 18 years old. Returns null if age/height aren't
  // valid numbers (e.g. profile not filled in yet).
  static int? predictedPeakFlow({
    required String age,
    required String height,
    required String gender,
  }) {
    final ageValue = double.tryParse(age);
    final heightCm = double.tryParse(height);
    if (ageValue == null || heightCm == null) return null;

    if (ageValue < 18) {
      return ((heightCm - 100) * 5 + 100).round();
    }

    final heightM = heightCm / 100;
    final value = gender == '女性'
        ? ((heightM * 3.72) + 2.24 - (ageValue * 0.03)) * 60
        : ((heightM * 5.48) + 1.58 - (ageValue * 0.041)) * 60;
    return value.round();
  }

  // Classifies a measurement against the user's predicted best value, per
  // 比對量測結果: >80% green (1), 60-80% yellow (2), <60% red (3). Returns
  // null if the best value isn't known, since no comparison can be made.
  static int? peakFlowStatusForValue(double value, double? bestValue) {
    if (bestValue == null || bestValue <= 0) return null;
    final percentage = value / bestValue * 100;
    if (percentage > 80) return 1;
    if (percentage >= 60) return 2;
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
    final (statusCode, data) = await ApiClient.send('GET', '/act/load?target_date=$dateStr', authenticated: true);

    if (statusCode == 200) {
      return ApiResult.success(ActStatus.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法取得氣喘控制測驗資料', authenticated: true);
  }

  static Future<ApiResult<SaveActResult>> saveAct(String recordDate, List<Map<String, dynamic>> answers) async {
    final (statusCode, data) = await ApiClient.send(
      'POST',
      '/act/save',
      body: {'record_date': recordDate, 'answers': answers},
      authenticated: true,
    );

    if (statusCode == 200) {
      return ApiResult.success(SaveActResult.fromJson(data));
    }

    return ApiClient.failure(statusCode, data, '無法儲存氣喘控制測驗結果', authenticated: true);
  }

  static Future<ApiResult<List<HistoryDay>>> getDiaryHistory({
    required int year,
    required int month,
  }) async {
    final (statusCode, data) = await ApiClient.getRaw('/diary/history?year=$year&month=$month', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => HistoryDay.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得氣喘日記歷史紀錄', authenticated: true);
  }

  static Future<ApiResult<List<PeakFlowStatus>>> getPeakFlowHistory({
    required int year,
    required int month,
  }) async {
    final (statusCode, data) = await ApiClient.getRaw('/pefr/history?year=$year&month=$month', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => PeakFlowStatus.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得尖峰吐氣流量歷史紀錄', authenticated: true);
  }

  static Future<ApiResult<List<HistoryDay>>> getActHistory({
    required int year,
    required int month,
  }) async {
    final (statusCode, data) = await ApiClient.getRaw('/act/history?year=$year&month=$month', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => HistoryDay.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得氣喘控制測驗歷史紀錄', authenticated: true);
  }

  static Future<ApiResult<List<AvailableMonth>>> getDiaryAvailableMonths() async {
    final (statusCode, data) = await ApiClient.getRaw('/diary/available-months', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => AvailableMonth.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得氣喘日記可用月份', authenticated: true);
  }

  static Future<ApiResult<List<AvailableMonth>>> getPeakFlowAvailableMonths() async {
    final (statusCode, data) = await ApiClient.getRaw('/pefr/available-months', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => AvailableMonth.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得尖峰吐氣流量可用月份', authenticated: true);
  }

  static Future<ApiResult<List<AvailableMonth>>> getActAvailableMonths() async {
    final (statusCode, data) = await ApiClient.getRaw('/act/available-months', authenticated: true);

    if (statusCode == 200 && data is List) {
      return ApiResult.success(data.map((e) => AvailableMonth.fromJson(e as Map<String, dynamic>)).toList());
    }

    return ApiClient.failure(statusCode, data is Map<String, dynamic> ? data : {}, '無法取得氣喘控制測驗可用月份', authenticated: true);
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
}
