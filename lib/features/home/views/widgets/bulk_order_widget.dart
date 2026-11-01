import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';

class BulkOrderWidget extends StatelessWidget {
  const BulkOrderWidget({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 56,
      ),
      color: Theme.of(context).colorScheme.surface,
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
            onPressed: () {
              Get.toNamed(AppRoutes.createEnquiry);
            },
            child: const Text('Request a Bulk Quote'),
          ),
        ],
      ),
    );
  }
}
