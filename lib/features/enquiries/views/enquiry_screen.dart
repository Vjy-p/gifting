import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/widgets/retry_widget.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/views/enquiry_tile.dart';

class EnquiryScreen extends GetView<EnquiryController> {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Enquiries')),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'View and manage your corporate gifting requests.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
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
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No enquiries found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your enquiries will appear here.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    // return ListView.separated(
                    //   itemCount: items.length,
                    //   physics: BouncingScrollPhysics(),
                    //   separatorBuilder: (_, _) =>
                    //       const SizedBox(height: 12),
                    //   itemBuilder: (context, index) {
                    //     return EnquiryTile(enquiry: items[index]);
                    //   },
                    // );
                    return GridView.builder(
                      itemCount: items.length,
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTab
                            ? 2
                            : isMobile
                            ? 1
                            : 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 190,
                        // childAspectRatio: isTab
                        //     ? 1.8
                        //     : isMobile
                        //     ? 2.5
                        //     : 2,
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
  }
}
