import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/ambient_background.dart';

/// Placeholder for primary nav destinations whose features land in later phases
/// (Cart → Fase 3, Chat AI → Fase 4B). Kept in the adaptive shell so the bottom
/// bar / rail stays complete and consistent on every surface (§4.4, §7.3).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.tab,
    required this.title,
    required this.message,
    required this.icon,
  });

  final AppTab tab;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentTab: tab,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(title)),
      body: AmbientBackground(
        hero: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: AppColors.brandGreen),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
