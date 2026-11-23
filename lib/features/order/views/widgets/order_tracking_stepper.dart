import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/order/models/order_model.dart';

class OrderTrackingStepper extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingStepper({super.key, required this.order});

  static const List<_StepData> _steps = [
    _StepData(
      title: 'Order Placed',
      subtitle: 'We received your order and payment',
      icon: Icons.shopping_bag_outlined,
    ),
    _StepData(
      title: 'Processing',
      subtitle: 'Gifts are being customised, prepared & packed',
      icon: Icons.inventory_2_outlined,
    ),
    _StepData(
      title: 'Out For Delivery',
      subtitle: 'Courier partner is delivering your package',
      icon: Icons.local_shipping_outlined,
    ),
    _StepData(
      title: 'Delivered',
      subtitle: 'Package delivered successfully',
      icon: Icons.check_circle_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: order.statusBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: order.statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(order.statusIcon, color: order.statusColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: order.statusColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.statusNote?.isNotEmpty == true
                        ? order.statusNote!
                        : 'This order has been cancelled.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentStep = order.stepIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.statusBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: order.statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  order.formattedStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: order.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              final isCompleted = index <= currentStep;
              final isCurrent = index == currentStep;
              final isLast = index == _steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator column
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isCurrent
                                      ? order.statusColor
                                      : order.statusBackgroundColor)
                                : Theme.of(context).dividerColor
                                      .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color: order.statusColor.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 4,
                                  )
                                : null,
                          ),
                          child: Icon(
                            isCompleted && !isCurrent ? Icons.check : step.icon,
                            color: isCompleted
                                ? (isCurrent ? Colors.white : order.statusColor)
                                : AppColors.secondaryText.withValues(
                                    alpha: 0.4,
                                  ),
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2.5,
                              color: index < currentStep
                                  ? order.statusColor
                                  : Theme.of(context).dividerColor
                                        .withValues(alpha: 0.2),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Step title and subtitle
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCompleted
                                    ? AppColors.text
                                    : AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
