import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppPageContainer extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Widget? bottomNavigation;
  final EdgeInsets contentPadding;
  final EdgeInsets bottomNavigationPadding;
  final bool scrollable;

  const AppPageContainer({
    super.key,
    required this.header,
    required this.content,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.bottomNavigation,
    this.bottomNavigationPadding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(
              child: Container(
                color: AppColors.harp,
                child: scrollable
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: contentPadding,
                          child: content,
                        ),
                      )
                    : Padding(
                        padding: contentPadding,
                        child: content,
                      ),
              ),
            ),
            if (bottomNavigation != null)
              Padding(
                padding: bottomNavigationPadding,
                child: bottomNavigation!,
              ),
          ],
        ),
      ),
    );
  }
}
