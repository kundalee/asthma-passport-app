import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../../../components/custom_button.dart';
import '../../../components/card_container.dart';

class PeakFlowFormView extends StatefulWidget {
  final String measurementDate;
  final bool isDaytimeCompleted;
  final bool isEveningCompleted;
  final String? daytimeValue;
  final String? eveningValue;
  final Function(int) onSwitchView;
  final Function()? onViewDaytimeResults;
  final Function()? onViewEveningResults;

  const PeakFlowFormView({
    super.key,
    required this.measurementDate,
    required this.isDaytimeCompleted,
    required this.isEveningCompleted,
    this.daytimeValue,
    this.eveningValue,
    required this.onSwitchView,
    this.onViewDaytimeResults,
    this.onViewEveningResults,
  });

  @override
  State<PeakFlowFormView> createState() => _PeakFlowFormViewState();
}

class _PeakFlowFormViewState extends State<PeakFlowFormView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _buildMeasurementInfoSection(),
          _buildMeasurementFormCard(
            icon: 'assets/icons/sun.svg',
            title: '白天量測',
            isComplete: widget.isDaytimeCompleted,
            measurementValue: widget.daytimeValue,
            onViewResults: widget.onViewDaytimeResults,
          ),
          _buildMeasurementFormCard(
            icon: 'assets/icons/night.svg',
            title: '夜晚量測',
            isComplete: widget.isEveningCompleted,
            measurementValue: widget.eveningValue,
            onViewResults: widget.onViewEveningResults,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementFormCard({
    required String icon,
    required String title,
    bool isComplete = false,
    String? measurementValue,
    Function()? onViewResults,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(
          color: AppColors.whiteMarble,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.mustardGold, BlendMode.srcIn),
              ),
              Text(
                title,
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
          _buildMeasurementInfo(
            isComplete: isComplete,
            value: measurementValue,
          ),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isComplete ? '查看測驗結果' : '開始紀錄',
              onPressed: onViewResults ?? () {},
              backgroundColor: isComplete ? AppColors.sportyBlue : AppColors.funGreen,
              padding: const EdgeInsets.all(12),
              borderRadius: 4,
              height: 37,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementInfoSection() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _buildMeasurementDateRow(),
          _buildBasicInfoSection(),
          _buildPredictedValueRow(),
        ],
      ),
    );
  }

  Widget _buildMeasurementDateRow() {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset(
          'assets/icons/document.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.funGreen, BlendMode.srcIn),
        ),
        Expanded(
          child: Text(
            '每日量測：${widget.measurementDate}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            '基本資料',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.71,
              letterSpacing: 0,
            ),
          ),
          _buildInfoRow('姓名', '王曉明'),
          _buildInfoRow('年齡', '13 歲'),
          _buildInfoRow('身高', '146 cm'),
          _buildInfoRow('體重', '42 kg'),
        ],
      ),
    );
  }

  Widget _buildPredictedValueRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.luxuryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '尖峰呼氣流速預估值',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          Text(
            '320 L/min',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.funGreen,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.71,
            letterSpacing: 0,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.71,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementInfo({required bool isComplete, String? value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isComplete ? AppColors.honeydew : AppColors.babysBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '自我評量',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                isComplete ? '完成' : '未完成',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '峰值呼氣流速',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
              Text(
                isComplete ? '${value ?? '0'} L/min' : '無紀錄',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.71,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
