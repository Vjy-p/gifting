import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/features/home/views/widgets/logout_dialog_box.dart';
import 'package:gifting/features/profile/controllers/profile_controller.dart';
import 'package:gifting/features/profile/views/widgets/profile_header_card.dart';
import 'package:gifting/features/profile/views/widgets/profile_menu_item.dart';

class ProfileDashboardScreen extends StatelessWidget {
  const ProfileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () => controller.loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Obx(() {
                final user = controller.user.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    ProfileHeaderCard(user: user),
                    const SizedBox(height: 18),

                    // Quick Stats Row
                    _buildStatsRow(context, controller),
                    const SizedBox(height: 22),

                    // Section: Orders & Enquiries
                    _buildSectionHeader(context, 'Orders & Activity'),
                    const SizedBox(height: 8),
                    _buildCardGroup(
                      context,
                      children: [
                        ProfileMenuItem(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          subtitle: 'Update your name, phone, and company',
                          onTap: () => Get.toNamed(AppRoutes.editProfile),
                        ),
                        _divider(context),
                        ProfileMenuItem(
                          icon: Icons.assignment_outlined,
                          title: 'My Enquiries',
                          subtitle: 'View submitted corporate gift enquiries',
                          onTap: () => Get.toNamed(AppRoutes.enquiry),
                        ),
                        _divider(context),
                        ProfileMenuItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Order Tracking & History',
                          subtitle:
                              'Live status: packed, picked, out for delivery',
                          onTap: () => Get.toNamed(AppRoutes.order),
                        ),
                        _divider(context),
                        ProfileMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Payment History',
                          subtitle: 'View invoices and transaction receipts',
                          onTap: () => Get.toNamed(AppRoutes.paymentHistory),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Section: Preferences & Support
                    _buildSectionHeader(context, 'Preferences & Support'),
                    const SizedBox(height: 8),
                    _buildCardGroup(
                      context,
                      children: [
                        ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications & Alerts',
                          subtitle: 'View real-time updates and push alerts',
                          onTap: () => Get.toNamed(AppRoutes.notifications),
                        ),
                        _divider(context),
                        ProfileMenuItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Toggle theme preference',
                          trailing: Obx(() {
                            final isDark = ThemeController.to.isDarkMode;
                            return Switch.adaptive(
                              value: isDark,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                ThemeController.to.toggleTheme();
                              },
                            );
                          }),
                          onTap: () {
                            ThemeController.to.toggleTheme();
                          },
                        ),
                        _divider(context),
                        ProfileMenuItem(
                          icon: Icons.headset_mic_outlined,
                          title: 'Customer Support',
                          subtitle:
                              'Chat directly with corporate gifting experts',
                          onTap: () => Get.toNamed(AppRoutes.support),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Section: Account Actions
                    _buildSectionHeader(context, 'Account'),
                    const SizedBox(height: 8),
                    _buildCardGroup(
                      context,
                      children: [
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle: 'Log out of your account on this device',
                          isDestructive: true,
                          trailing: const SizedBox.shrink(),
                          onTap: () => openLogoutDialogBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCardGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
    );
  }

  Widget _buildStatsRow(BuildContext context, ProfileController controller) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            title: 'Enquiries',
            count: '${controller.enquiryCount.value}',
            icon: Icons.query_builder_rounded,
            color: Colors.blue,
            onTap: () => Get.toNamed(AppRoutes.enquiry),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            title: 'Orders',
            count: '${controller.orderCount.value}',
            icon: Icons.shopping_bag_outlined,
            color: Colors.green,
            onTap: () => Get.toNamed(AppRoutes.order),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            title: 'Cart',
            count: '${controller.cartCount.value}',
            icon: Icons.shopping_cart_outlined,
            color: Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.cart),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
