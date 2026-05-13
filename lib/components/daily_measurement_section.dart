import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'card_container.dart';
import 'custom_button.dart';

class DailyMeasurementSection extends StatelessWidget {
  final DateTime selectedDate;
  final String label1;
  final String status1;
  final String label2;
  final String status2;

  const DailyMeasurementSection({
    super.key,
    required this.selectedDate,
    required this.label1,
    required this.status1,
    required this.label2,
    required this.status2,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, size: 24, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                '每日量測：${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF5DB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label1,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    Text(
                      status1,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label2,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    Text(
                      status2,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: '開始紀錄',
            onPressed: () {},
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            borderRadius: 4,
            height: 45,
          ),
        ],
      ),
    );
  }
}
