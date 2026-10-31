import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/home/views/widgets/section_widget.dart';

class HowItWorksWidget extends StatelessWidget {
  const HowItWorksWidget({super.key, required this.isMobile});
  final bool isMobile;

  static const steps = [
    ('01', 'Browse Gifts', 'Discover gifts for your team and clients.'),
    ('02', 'Customise', 'Choose branding and personalisation.'),
    ('03', 'Submit Enquiry', 'Share your requirements for a quotation.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionWidget(
      title: 'Seamless from Curation to Delivery',
      subtitle: 'Three simple steps to get started.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 700 ? 1 : 3;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: columns == 1
                  ? 3
                  : constraints.maxWidth < 1000
                  ? 1.2
                  : 2,
            ),
            itemBuilder: (context, index) {
              final step = steps[index];

              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.$1,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.$2,
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(step.$3, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          );
          // return Wrap(
          //   spacing: 20,
          //   runSpacing: 20,
          //   alignment: WrapAlignment.start,
          //   runAlignment: WrapAlignment.start,
          //   crossAxisAlignment: WrapCrossAlignment.start,
          //   children: List.generate(steps.length, (index) {
          //     final step = steps[index];
          //     return Container(
          //       padding: const EdgeInsets.all(22),
          //       decoration: BoxDecoration(
          //         color: AppColors.surface,
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(color: AppColors.border),
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             step.$1,
          //             style: const TextStyle(
          //               color: AppColors.gold,
          //               fontSize: 24,
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //           const SizedBox(height: 12),
          //           Text(
          //             step.$2,
          //             style: const TextStyle(
          //               color: AppColors.darkGreen,
          //               fontSize: 17,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //           const SizedBox(height: 8),
          //           Text(step.$3, maxLines: 2, overflow: TextOverflow.ellipsis),
          //         ],
          //       ),
          //     );
          //   }),
          // );
        },
      ),
    );
  }
}
