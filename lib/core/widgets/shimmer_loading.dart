import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gifting/core/theme/app_colors.dart';

/// A reusable shimmering box placeholder for skeleton loading states.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1A2621)
        : const Color(0xFFE9EFEA);
    final shimmerColor = isDark
        ? const Color(0xFF2B3D35)
        : const Color(0xFFFAFBF9);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: shimmerColor.withValues(alpha: 0.65),
          curve: Curves.easeInOut,
        );
  }
}

/// A smooth skeleton loader mimicking the Dashboard layout while initial data loads.
class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;
        final horizontalPadding = isMobile ? 16.0 : 40.0;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: isMobile
                ? kToolbarHeight + MediaQuery.of(context).padding.top / 1.4
                : kToolbarHeight + 10,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Skeleton
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isMobile ? 16 : 28,
                ),
                child: isMobile
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            height: 200,
                            width: double.infinity,
                            borderRadius: 16,
                          ),
                          SizedBox(height: 20),
                          ShimmerBox(height: 18, width: 140, borderRadius: 20),
                          SizedBox(height: 12),
                          ShimmerBox(height: 32, width: double.infinity, borderRadius: 8),
                          SizedBox(height: 10),
                          ShimmerBox(height: 16, width: 220, borderRadius: 6),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              ShimmerBox(height: 42, width: 130, borderRadius: 10),
                              SizedBox(width: 12),
                              ShimmerBox(height: 42, width: 150, borderRadius: 10),
                            ],
                          ),
                        ],
                      )
                    : const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerBox(height: 24, width: 170, borderRadius: 20),
                                SizedBox(height: 20),
                                ShimmerBox(height: 48, width: 380, borderRadius: 8),
                                SizedBox(height: 12),
                                ShimmerBox(height: 48, width: 320, borderRadius: 8),
                                SizedBox(height: 18),
                                ShimmerBox(height: 18, width: 420, borderRadius: 6),
                                SizedBox(height: 8),
                                ShimmerBox(height: 18, width: 360, borderRadius: 6),
                                SizedBox(height: 28),
                                Row(
                                  children: [
                                    ShimmerBox(height: 46, width: 140, borderRadius: 10),
                                    SizedBox(width: 14),
                                    ShimmerBox(height: 46, width: 170, borderRadius: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 48),
                          Expanded(
                            flex: 4,
                            child: ShimmerBox(
                              height: 380,
                              width: double.infinity,
                              borderRadius: 18,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // Horizontal Products Section Skeleton
              _buildSectionSkeleton(
                titleWidth: 240,
                subtitleWidth: 320,
                horizontalPadding: horizontalPadding,
                child: SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    itemCount: isMobile ? 3 : 6,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => _buildProductCardSkeleton(),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Categories Grid Skeleton
              _buildSectionSkeleton(
                titleWidth: 280,
                subtitleWidth: 340,
                horizontalPadding: horizontalPadding,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 700 ? 2 : 4;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: constraints.maxWidth < 600 ? 1 : 1.2,
                        ),
                        itemBuilder: (_, index) => Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShimmerBox(height: 52, width: 52, borderRadius: 12),
                              SizedBox(height: 14),
                              ShimmerBox(height: 16, width: 90, borderRadius: 6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSectionSkeleton({
    required double titleWidth,
    required double subtitleWidth,
    required double horizontalPadding,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 22, width: titleWidth, borderRadius: 6),
              const SizedBox(height: 8),
              ShimmerBox(height: 14, width: subtitleWidth, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  static Widget _buildProductCardSkeleton() {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ShimmerBox(
              height: double.infinity,
              width: double.infinity,
              borderRadius: 14,
            ),
          ),
          Flexible(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShimmerBox(height: 10, width: 60, borderRadius: 4),
                  ShimmerBox(height: 14, width: 120, borderRadius: 4),
                  ShimmerBox(height: 12, width: 80, borderRadius: 4),
                  ShimmerBox(height: 28, width: double.infinity, borderRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A smooth skeleton loader for the Catalogue grid.
class CatalogueLoadingSkeleton extends StatelessWidget {
  const CatalogueLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1300
            ? 6
            : width >= 1000
                ? 4
                : width >= 650
                    ? 3
                    : width >= 400
                        ? 2
                        : 1;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: columns * 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: columns == 1 ? 1.3 : 0.68,
          ),
          itemBuilder: (_, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ShimmerBox(
                    height: double.infinity,
                    width: double.infinity,
                    borderRadius: 14,
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ShimmerBox(height: 10, width: 60, borderRadius: 4),
                        ShimmerBox(height: 15, width: 130, borderRadius: 4),
                        ShimmerBox(height: 12, width: 85, borderRadius: 4),
                        ShimmerBox(
                          height: 32,
                          width: double.infinity,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A smooth skeleton loader for the Enquiries list.
class EnquiriesLoadingSkeleton extends StatelessWidget {
  const EnquiriesLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;
        final isTab = constraints.maxWidth >= 750 && constraints.maxWidth < 1200;
        final cols = isMobile ? 1 : isTab ? 2 : 3;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cols * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 220,
          ),
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(height: 14, width: 100, borderRadius: 4),
                    ShimmerBox(height: 22, width: 70, borderRadius: 12),
                  ],
                ),
                ShimmerBox(height: 18, width: 160, borderRadius: 4),
                ShimmerBox(height: 14, width: 220, borderRadius: 4),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(height: 12, width: 90, borderRadius: 4),
                    ShimmerBox(height: 12, width: 70, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
