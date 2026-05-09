import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppPageContainer extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Widget? bottomNavigation;
  final EdgeInsets contentPadding;

  const AppPageContainer({
    super.key,
    required this.header,
    required this.content,
    this.bottomNavigation,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                header,
                Expanded(
                  child: Container(
                    color: AppColors.lightMintBackground,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: contentPadding,
                        child: content,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (bottomNavigation != null)
              Positioned(
                bottom: 0,
                left: 12,
                right: 12,
                child: bottomNavigation!,
              ),
          ],
        ),
      ),
    );
  }
}
