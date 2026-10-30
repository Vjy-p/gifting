import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../models/enquiry_model.dart';

class EnquiryTile extends StatelessWidget {
  final EnquiryModel enquiry;
  const EnquiryTile({super.key, required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  enquiry.referenceCode ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (enquiry.createdAt != null)
                Text(
                  DateFormat("dd-MMM-yyyy hh:mm a").format(enquiry.createdAt!),
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text('Occasion: ${enquiry.occasion}'),
          Text('Quantity: ${enquiry.quantity} units'),
          Text('Products: ${enquiry.products.length}'),
          if (enquiry.customisations.isEmpty)
            Text('Customisations: ${enquiry.customisations.join(", ")}'),
          // const Divider(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       enquiry.createdAt?.toString().split(' ').first ?? '',
          //       style: const TextStyle(color: Colors.grey, fontSize: 12),
          //     ),
          //     TextButton(
          //       onPressed: () {
          //         // Open enquiry details screen/sheet.
          //       },
          //       child: const Text('View details →'),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
