import 'package:flutter/material.dart';
import '../../../models/passport_models.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../services/api_service.dart';
import 'plan_report_card.dart';

// Read-only view of the plan most recently saved via NewPlanView, fetched
// from /passport/load — separate from NewPlanView's own in-progress-form
// preview, which only works while a new plan is actively being filled out.
class PassportPlanView extends StatefulWidget {
  final String patientName;
  final String dateStr;
  final Function(int) onSwitchView;

  const PassportPlanView({
    super.key,
    required this.patientName,
    required this.dateStr,
    required this.onSwitchView,
  });

  @override
  State<PassportPlanView> createState() => _PassportPlanViewState();
}

class _PassportPlanViewState extends State<PassportPlanView> {
  bool isLoading = true;
  PassportPlan? plan;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final result = await ApiService.getPassportPlan(widget.dateStr);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      plan = result.data;
      errorMessage = result.success ? null : (result.message ?? '無法取得行動計畫');
    });
  }

  List<PlanMedicationDisplay> _toDisplayList(List<PassportPlanMedication> medications) {
    return medications
        .map((m) => PlanMedicationDisplay(name: m.name, morn: m.morn, even: m.even, info: m.info, note: m.note))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentPlan = plan;
    if (currentPlan == null || !currentPlan.isCompleted) {
      return _buildEmptyState();
    }

    return _buildPlanReport(currentPlan);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            errorMessage ?? '本月尚無已儲存的行動計畫',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.71),
          ),
          SizedBox(
            width: 200,
            child: CustomButton(
              text: '返回',
              onPressed: () => widget.onSwitchView(1),
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.all(12),
              borderRadius: 4,
              height: 37,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanReport(PassportPlan currentPlan) {
    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          PlanReportCard(
            patientName: widget.patientName,
            recordDate: currentPlan.recordDate ?? '-',
            statusLevel: currentPlan.statusLevel,
            controlMeds: _toDisplayList(currentPlan.controlMeds),
            reliefMeds: _toDisplayList(currentPlan.reliefMeds),
            notes: currentPlan.notes,
            doctorName: currentPlan.doctorName,
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 40),
            child: Column(
              spacing: 12,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: '返回',
                    onPressed: () => widget.onSwitchView(1),
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.all(12),
                    borderRadius: 4,
                    height: 37,
                  ),
                ),
                const Text(
                  '此報告僅供參考，實際治療請遵循醫師指示',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.hydrocarbon, height: 1.71, letterSpacing: 0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
