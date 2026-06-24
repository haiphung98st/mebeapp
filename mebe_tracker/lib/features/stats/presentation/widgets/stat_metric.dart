import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_styles.dart';

/// A single labeled number used inside stats summary cards.
class StatMetric extends StatelessWidget {
  const StatMetric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.headingLg),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}
