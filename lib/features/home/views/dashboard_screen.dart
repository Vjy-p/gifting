import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/core/widgets/retry_widget.dart';
import 'package:gifting/features/home/views/widgets/banner_widget.dart';
import 'package:gifting/features/home/views/widgets/bulk_order_widget.dart';
import 'package:gifting/features/home/views/widgets/category_screen.dart';
import 'package:gifting/features/home/views/widgets/features_widget.dart';
import 'package:gifting/features/home/views/widgets/footer_widget.dart';
import 'package:gifting/features/home/views/widgets/how_it_works_widget.dart';
import 'package:gifting/features/home/views/widgets/occasion_widget.dart';
import 'package:gifting/features/home/views/widgets/products_widget.dart';

import '../../catalogue/controllers/catalogue_controller.dart';

class DashboardScreen extends GetView<CatalogueController> {
  const DashboardScreen({super.key});

  static const _occasions = [
    ('Employee Onboarding', Icons.work_outline),
    ('Corporate Diwali Gifting', Icons.light_mode_outlined),
    ('New Year Gifts', Icons.celebration_outlined),
    ('Client and Vendor Gifting', Icons.handshake_outlined),
    ('Events and Trade Shows', Icons.event_outlined),
    ('Employee Recognition', Icons.workspace_premium_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              spacing: 8,
              children: [
                Icon(Icons.eco_outlined, color: AppColors.primary, size: 30),

                Text(
                  'TRIBE GREEN',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [if (isMobile) const ThemeToggleButton()],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.loadDashBoard();
            },
            child: Obx(() {
              return controller.isDashboardLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorDashboard.value
                  ? RetryWidget(
                      onPressed: () {
                        controller.loadDashBoard();
                      },
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          BannerWidget(isMobile: isMobile),
                          if (!isMobile) const FeaturesWidget(),
                          ProductsWidget(
                            title: 'Most Requested Corporate Gifts',
                            subTitle: 'Thoughtful products for every business occasion.',
                            products: controller.mostRequestedProducts,
                          ),
                          const CategoryWidget(),
                          ProductsWidget(
                            title: 'Trending Gifts',
                            subTitle: 'Thoughtful products for every business occasion.',
                            products: controller.trendingProducts,
                          ),
                          // ignore: prefer_const_constructors
                          OccasionWidget(occasions: _occasions),
                          ProductsWidget(
                            title: 'Top Gifts',
                            subTitle: 'Thoughtful products for every business occasion.',
                            products: controller.topProducts,
                          ),
                          ProductsWidget(
                            title: 'New Gifts',
                            subTitle: 'Thoughtful products for every business occasion.',
                            products: controller.bannerProducts,
                          ),
                          HowItWorksWidget(isMobile: isMobile),
                          BulkOrderWidget(isMobile: isMobile),
                          FooterWidget(isMobile: isMobile),
                        ],
                      ),
                    );
            }),
          ),
        );
      },
    );
  }
}
