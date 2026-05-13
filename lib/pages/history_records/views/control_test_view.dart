import 'package:flutter/material.dart';
import '../../../components/status_container.dart';

class ControlTestView extends StatelessWidget {
  final List<String> availableMonths;

  const ControlTestView({
    super.key,
    required this.availableMonths,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableMonths.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final month = availableMonths[index];
        final monthParts = month.split('/');
        final monthDisplay = monthParts.length == 2 ? '${monthParts[1]}月' : month;
        // TODO: Get actual test data from API based on month
        // For now, using placeholder data
        final isCompleted = index == 1; // Simulate only second month as completed

        return StatusContainer(
          title: '每月測驗：$monthDisplay',
          items: [
            StatusItem(label: '自我評量', status: isCompleted ? '23 分' : '未完成'),
            StatusItem(label: '量測時間', status: isCompleted ? '2025/11/16' : '無紀錄'),
          ],
          onPressed: () {},
          isComplete: isCompleted,
        );
      },
    );
  }
}
