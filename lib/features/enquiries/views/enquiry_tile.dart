import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/enquiries/views/enquiry_details_screen.dart';
import 'package:intl/intl.dart';

import '../models/enquiry_model.dart';

class EnquiryTile extends StatelessWidget {
  final EnquiryModel enquiry;
  const EnquiryTile({super.key, required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  enquiry.referenceCode ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (enquiry.createdAt != null)
                Text(
                  DateFormat('dd-MMM-yyyy hh:mm a').format(enquiry.createdAt!),
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Text(
            enquiry.company,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text(
            'Occasion: ${enquiry.occasion}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Quantity: ${enquiry.quantity} units',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Products: ${enquiry.products.length}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // if (enquiry.customisations.isEmpty)
          //   Text(
          //     'Customisations: ${enquiry.customisations.join(", ")}',
          //     maxLines: 1,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          const Divider(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                enquiry.createdAt?.toString().split(' ').first ?? '',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
              TextButton(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Get.dialog(
                    barrierColor: AppColors.isDark
                        ? Colors.black.withValues(alpha: 0.7)
                        : AppColors.darkGreen.withValues(alpha: 0.4),
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.surface,
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: EnquiryDetailsScreen(enquiry: enquiry),
                    ),
                  );
                },
                child: const Text('View details →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
