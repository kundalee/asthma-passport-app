import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class InstructionsBox extends StatelessWidget {
  final List<String> instructions;
  final String title;

  const InstructionsBox({
    super.key,
    required this.instructions,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.resultModerateBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.instructionsBoxBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/heart.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.resultModerateIcon, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.resultModerateIcon,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < instructions.length; i++) ...[
                _InstructionItem(text: instructions[i]),
                if (i < instructions.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;

  const _InstructionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: const Center(
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
