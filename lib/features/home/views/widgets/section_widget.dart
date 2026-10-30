import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 20 : 44,
          ),
          child: Align(
            alignment: isMobile
                ? AlignmentGeometry.centerStart
                : AlignmentGeometry.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                spacing: isMobile ? 6 : 12,
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: isMobile ? TextAlign.start : TextAlign.center,
                    style: isMobile
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    subtitle,
                    style: isMobile
                        ? Theme.of(context).textTheme.bodyMedium
                        : Theme.of(context).textTheme.bodySmall,
                    textAlign: isMobile ? TextAlign.start : TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 10 : 28),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
