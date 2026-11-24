import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/notifications/controllers/notification_controller.dart';
import 'package:gifting/features/notifications/models/in_app_notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Unread

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);

    return Scaffold(
      appBar: AppBar(
        // leading: const CustomBackButton(),
        centerTitle: false,
        title: const Text(
          'Notifications',
          // style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            final cartController = Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController());
            final count = cartController.cart.length;
            return Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: IconButton(
                tooltip: 'Cart',
                iconSize: 20,
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Get.toNamed(AppRoutes.cart),
              ),
            );
          }),
          Obx(() {
            if (controller.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return TextButton.icon(
              onPressed: () {
                controller.markAllAsRead();
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            );
          }),
          PopupMenuButton<String>(
            // padding: const EdgeInsetsGeometry.only(right: 10),
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog(context, controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allItems = controller.notifications;
        final items = _selectedFilterIndex == 1
            ? allItems.where((n) => !n.isRead).toList()
            : allItems;

        return Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All (${allItems.length})',
                    isSelected: _selectedFilterIndex == 0,
                    onTap: () => setState(() => _selectedFilterIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Unread (${controller.unreadCount.value})',
                    isSelected: _selectedFilterIndex == 1,
                    onTap: () => setState(() => _selectedFilterIndex = 1),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content List or Empty State
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final notification = items[index];
                        return _buildNotificationTile(
                          context,
                          notification,
                          controller,
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
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

  Widget _buildNotificationTile(
    BuildContext context,
    InAppNotificationModel notification,
    NotificationController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFEF4444),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        controller.deleteNotification(notification.id);
      },
      child: Material(
        color: notification.isRead
            ? Colors.transparent
            : (isDark
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : const Color(0xFFF0FDF4)),
        child: InkWell(
          onTap: () {
            controller.markAsRead(notification.id);
            if (notification.orderId.isNotEmpty) {
              Get.toNamed(
                AppRoutes.orderDetails,
                arguments: notification.orderId,
              );
            } else if (Get.currentRoute != AppRoutes.order) {
              Get.toNamed(AppRoutes.order);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.iconData,
                    color: notification.statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notification.statusColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.formattedStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: notification.statusColor,
                              ),
                            ),
                          ),
                          if (notification.orderNumber.isNotEmpty) ...[
                            Expanded(
                              child: Text(
                                '#${notification.orderNumber}',
                                // maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                          Text(
                            notification.relativeTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread dot
                if (!notification.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
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
                Icons.notifications_none_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive real-time updates when your orders are placed, packed, picked, out for delivery, and delivered!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    NotificationController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text(
          'This will permanently remove all your order notification history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.clearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
