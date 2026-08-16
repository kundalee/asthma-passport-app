import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';
import '../../../services/api_service.dart';

class PeakFlowResultsView extends StatefulWidget {
  final String dateStr;
  final String measurementDate;
  final bool isDaytime;
  final String measurementValue;
  final int? status;
  final double? bestValue;
  final Function(int) onSwitchView;
  final VoidCallback onSaved;

  const PeakFlowResultsView({
    super.key,
    required this.dateStr,
    required this.measurementDate,
    required this.isDaytime,
    required this.measurementValue,
    this.status,
    this.bestValue,
    required this.onSwitchView,
    required this.onSaved,
  });

  @override
  State<PeakFlowResultsView> createState() => _PeakFlowResultsViewState();
}

class _PeakFlowResultsViewState extends State<PeakFlowResultsView> {
  final TextEditingController _inputController = TextEditingController();
  late int? _statusResult;
  late bool _isEditingFromCompleted;
  bool _showCompletedButtons = false;

  @override
  void initState() {
    super.initState();
    _statusResult = widget.status;
    _isEditingFromCompleted = false;
    _inputController.text = widget.measurementValue;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Just computes the status locally to preview the result box; nothing is
  // saved yet, so 重新測量 can still freely redo the reading.
  void _previewMeasurement() {
    final value = double.tryParse(_inputController.text) ?? 0;
    setState(() => _statusResult = ApiService.peakFlowStatusForValue(value, widget.bestValue));
  }

  // Actually persists the reading once the user confirms the preview.
  Future<void> _confirmMeasurement() async {
    final value = double.tryParse(_inputController.text) ?? 0;
    final result = await ApiService.savePeakFlowMeasurement(
      dateStr: widget.dateStr,
      isDaytime: widget.isDaytime,
      value: value,
      statusColor: _statusResult,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() => _showCompletedButtons = true);
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '儲存失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _buildHeader(),
            _buildInstructionImage(),
            _buildInstructions(),
            _buildMeasurementInput(),
            _statusResult == null ? _buildResultsTable() : _buildStatusResult(),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset(
          widget.isDaytime ? 'assets/icons/sun.svg' : 'assets/icons/night.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.mustardGold, BlendMode.srcIn),
        ),
        Text(
          widget.isDaytime ? '白天量測' : '夜晚量測',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionImage() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        'assets/images/peak_flow_instruction.png',
        width: 280,
        height: 179,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      '步驟一、確保指針歸零。\n步驟二、站直深吸一口氣，緊閉嘴唇並用力呼氣，將吹嘴放入口中並用嘴唇緊密包住，快速且用力地將所有空氣在短時間內吹出，不要用舌頭堵住。\n步驟三、記下讀數後休息一下，重複 2-3 次，選取最高的數值點選完成紀錄。',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1.67,
        letterSpacing: 0,
      ),
    );
  }

  Widget _buildMeasurementInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            '請紀錄最高尖峰呼氣流速',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.71,
              letterSpacing: 0,
            ),
          ),
          TextField(
            controller: _inputController,
            enabled: (widget.status == null && _statusResult == null) || _isEditingFromCompleted,
            readOnly: !((widget.status == null && _statusResult == null) || _isEditingFromCompleted),
            showCursor: _statusResult == null && ((widget.status == null) || _isEditingFromCompleted),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: (widget.status == null || _isEditingFromCompleted) ? Colors.white : AppColors.secondaryGray,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1.0,
                  child: Text(
                    '(L/min)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.71,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.secondaryGrayW,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.secondaryGrayW,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.secondaryGrayW,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.secondaryGrayW,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(8),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            '比對測測結果',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.71,
              letterSpacing: 0,
            ),
          ),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableRow('區別', '最佳值之百分比', '代表意義', isHeader: true),
          _buildTableRow('PEFR值綠燈區', '80%以上', '情況穩定', backgroundColor: AppColors.lightGreen),
          _buildTableRow('PEFR值黃燈區', '60%~80%', '要小心', backgroundColor: AppColors.lightYellow),
          _buildTableRow('PEFR值紅燈區', '60%以下', '醫療警訊', backgroundColor: AppColors.lightPink),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String column1,
    String column2,
    String column3, {
    bool isHeader = false,
    Color? backgroundColor,
  }) {
    const textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      height: 2.67,
      letterSpacing: 0,
    );

    return Container(
      height: 32,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(column1, style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(column2, style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(column3, style: textStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusResult() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            '比對測測結果',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.71,
              letterSpacing: 0,
            ),
          ),
          _buildStatusBox(_statusResult!),
        ],
      ),
    );
  }

  Widget _buildStatusBox(int status) {
    late Color backgroundColor;
    late Color borderColor;
    late Color textColor;
    late String iconPath;
    late String statusText;

    switch (status) {
      case 0:
        backgroundColor = AppColors.honeydew;
        borderColor = AppColors.lightPastelMint;
        textColor = AppColors.primaryGreen;
        iconPath = 'assets/icons/check.svg';
        statusText = '控制良好，請繼續保持';
        break;
      case 1:
        backgroundColor = AppColors.secondaryYellow;
        borderColor = AppColors.darkYellow;
        textColor = AppColors.windsorTan;
        iconPath = 'assets/icons/alert-info.svg';
        statusText = '目前氣道不穩定，如合併有氣喘症狀請使用氣喘緊急用藥，並持續觀察氣喘狀況';
        break;
      case 2:
        backgroundColor = AppColors.babysBottom;
        borderColor = AppColors.spicyPastelPink;
        textColor = AppColors.digitalRed;
        iconPath = 'assets/icons/emergency.svg';
        statusText = '氣喘正處於急性發作，請立即使用氣喘緊急用藥，使用後若症狀無法緩解請盡快就醫';
        break;
      default:
        backgroundColor = AppColors.honeydew;
        borderColor = AppColors.lightPastelMint;
        textColor = AppColors.primaryGreen;
        iconPath = 'assets/icons/check.svg';
        statusText = '控制良好，請繼續保持';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
          Flexible(
            child: Text(
              statusText,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.71,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    if ((widget.status != null && !_isEditingFromCompleted) || _showCompletedButtons) {
      // Initial status provided and not editing, or showing completed buttons - show 3 buttons
      return Column(
        spacing: 12,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: '返回首頁',
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.all(12),
              borderRadius: 4,
              height: 37,
            ),
          ),
        ],
      );
    } else {
      // Recording new measurement
      return Column(
        spacing: 12,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _statusResult == null ? '確認' : '完成紀錄',
              onPressed: _statusResult == null ? _previewMeasurement : _confirmMeasurement,
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.all(12),
              borderRadius: 4,
              height: 37,
            ),
          ),
          if (_statusResult != null && !_showCompletedButtons)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '重新測量',
                onPressed: () {
                  setState(() {
                    _statusResult = null;
                    _inputController.clear();
                  });
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                border: const BorderSide(
                  color: AppColors.secondaryGrayW,
                  width: 1,
                ),
                padding: const EdgeInsets.all(12),
                borderRadius: 4,
                height: 37,
              ),
            ),
        ],
      );

    }
  }
}
