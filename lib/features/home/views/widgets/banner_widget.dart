import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/catalogue/models/product_model.dart';

import '../../../catalogue/controllers/catalogue_controller.dart';

class BannerWidget extends GetView<CatalogueController> {
  const BannerWidget({super.key, required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CORPORATE GIFTING',
              style: TextStyle(
                color: AppColors.primary,
                letterSpacing: 2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Thoughtful Gifts.\nStronger Business\nRelationships.',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: isMobile ? 26 : 50,
                height: 1.15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Personalised corporate gifts for teams, clients '
              'and partners, thoughtfully curated for every occasion.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.7,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.clearFilters();
                    controller.selectCategory(controller.categories.first);
                    Get.toNamed(AppRoutes.catalogue);
                  },
                  child: const Text('Explore Gifts'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.createEnquiry);
                  },
                  child: const Text('Request a Bulk Quote'),
                ),
              ],
            ),
          ],
        );

        final image = Obx(() {
          return SizedBox(
            height: isMobile ? 200 : 420,
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.zero,
              child: controller.bannerProducts.isEmpty
                  ? emptyBanner(context)
                  : BannerCarousel(
                      products: controller.bannerProducts,
                      height: isMobile ? 200 : 420,
                    ),
            ),
          );
        });

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 64,
            vertical: isMobile ? 32 : 60,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [image, const SizedBox(height: 32), content],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: content),
                    const SizedBox(width: 56),
                    Expanded(flex: 4, child: image),
                  ],
                ),
        );
      },
    );
  }

  Widget emptyBanner(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 76,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            'Thoughtfully curated gifts',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.products,
    required this.height,
  });

  final List<ProductModel> products;
  final double height;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final CarouselController _carouselController = CarouselController();

  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    if (widget.products.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.products.isEmpty) return;

      _currentIndex++;

      _carouselController.animateToItem(
        _currentIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.products.length != widget.products.length) {
      _currentIndex = 0;
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = MediaQuery.of(context).size.width;
        log('width $width');
        return SizedBox(
          height: widget.height,
          child: CarouselView.weightedBuilder(
            controller: _carouselController,
            itemCount: widget.products.length,
            flexWeights: width >= 700 && width < 1200
                ? const [1]
                : width >= 1200 && width < 1400
                ? [1, 2]
                : [1, 2, 3],
            infinite: true,
            // reverse: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => emptyWdget(context),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget emptyWdget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 76,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            'Thoughtfully curated gifts',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
