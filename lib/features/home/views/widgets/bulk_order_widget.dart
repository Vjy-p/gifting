import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';

class BulkOrderWidget extends StatelessWidget {
  const BulkOrderWidget({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      color: AppColors.sage,
      child: Column(
        children: [
          Text(
            'Planning a Bulk Gifting Order?',
            textAlign: TextAlign.center,
            style: isMobile
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Let us help you find the right gifts for your business.',
            style: isMobile
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Request a Bulk Quote'),
          ),
        ],
      ),
    );
  }
}
