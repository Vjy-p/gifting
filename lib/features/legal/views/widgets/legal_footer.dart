import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      // spacing: AppSpacing.lg,
      children: [
        Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            )
            .animate()
            .fadeIn(delay: 1200.ms, duration: 900.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              duration: 900.ms,
              curve: Curves.easeOutCubic,
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 10, 32),
          child: Text(
            '© 2026 Card Game. All rights reserved.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
