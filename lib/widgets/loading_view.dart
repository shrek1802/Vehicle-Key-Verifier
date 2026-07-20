import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = "Loading...",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}
