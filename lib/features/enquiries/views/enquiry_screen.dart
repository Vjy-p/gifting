import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/core/widgets/retry_widget.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/views/enquiry_tile.dart';

class EnquiryScreen extends GetView<EnquiryController> {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Enquiries'),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [if (isMobile) const ThemeToggleButton()],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 750;
              final isTab =
                  constraints.maxWidth >= 750 && constraints.maxWidth < 1200;

              return Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Track your enquiries',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'View and manage your corporate gifting requests.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.error.value) {
                          return RetryWidget(
                            onPressed: () {
                              controller.loadEnquiries();
                            },
                          );
                        }

                        final items = controller.enquiries.toList();

                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 56,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No enquiries found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Your enquiries will appear here.',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile
                                    ? 1
                                    : isTab
                                    ? 2
                                    : 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 220,
                              ),
                          itemBuilder: (context, index) {
                            return EnquiryTile(enquiry: items[index]);
                          },
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
