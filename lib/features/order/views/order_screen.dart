import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/widgets/custom_back_button.dart';
import 'package:gifting/features/cart/views/cart_bell_button.dart';
import 'package:gifting/features/notifications/views/widgets/notification_bell_button.dart';
import 'package:gifting/features/order/controllers/order_controller.dart';
import 'package:gifting/features/order/models/order_status.dart';
import 'package:gifting/features/order/views/widgets/order_card.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        centerTitle: false,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          CartBellButton(),
          NotificationBellButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Filter Pills using OrderStatus.allFilters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: OrderStatus.allFilters.map((filter) {
                  final int count;
                  if (filter == 'All') {
                    count = controller.orders.length;
                  } else {
                    final status = OrderStatus.fromString(filter);
                    count = controller.orders
                        .where((o) => o.status == status)
                        .length;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterTab(
                      label: '$filter ($count)',
                      filterKey: filter,
                      controller: controller,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Content List or Empty State
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final uid = controller.orders.isNotEmpty
                      ? controller.orders.first.userId
                      : null;
                  if (uid != null) controller.startListeningToOrders(uid);
                },
                child: controller.filteredOrders.isEmpty
                    ? _buildEmptyOrders(context, controller)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.filteredOrders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final order = controller.filteredOrders[index];
                          return OrderCard(order: order);
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String filterKey,
    required OrderController controller,
  }) {
    final isSelected =
        controller.selectedFilter.value.toLowerCase() ==
        filterKey.toLowerCase();

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFilter(filterKey),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.secondaryText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context, OrderController controller) {
    final isFiltered = controller.selectedFilter.value.toLowerCase() != 'all';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No Orders in this category' : 'No Orders Yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try selecting a different filter above to view your orders.'
                  : 'Looks like you have not placed any orders yet. Discover thoughtful corporate gifts in our catalogue!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (isFiltered) {
                  controller.setFilter('All');
                } else {
                  Get.toNamed(AppRoutes.catalogue);
                }
              },
              icon: Icon(
                isFiltered
                    ? Icons.filter_alt_off_outlined
                    : Icons.storefront_outlined,
              ),
              label: Text(isFiltered ? 'View All Orders' : 'Explore Catalogue'),
            ),
          ],
        ),
      ),
    );
  }
}
