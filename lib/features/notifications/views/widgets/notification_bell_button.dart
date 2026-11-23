import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/features/notifications/controllers/notification_controller.dart';

class NotificationBellButton extends StatelessWidget {
  final Color? color;
  final double iconSize;

  const NotificationBellButton({
    super.key,
    this.color,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);

    return Obx(() {
      final count = controller.unreadCount.value;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Notifications',
            icon: Icon(
              count > 0
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_outlined,
              color: color,
              size: iconSize,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.notifications);
            },
          ),
          if (count > 0)
            Positioned(
              top: 8,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), // Vibrant Red
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
