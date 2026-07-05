import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';

/// Admin area landing (§2.2, §7.4). Reachable only by staff — enforced by the
/// router guard (route protection) and, for data, by the security rules
/// (§5.5). Feature cards fill in during later phases (Admin AI = Fase 4).
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appUser = ref.watch(appUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAreaTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.adminWelcome(appUser?.displayName ?? ''),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          _AdminCard(
            icon: Icons.add_a_photo_outlined,
            title: l10n.adminAddProduct,
            subtitle: l10n.adminNewProductTitle,
            onTap: () => context.push('/admin/products/new'),
          ),
          _AdminCard(
            icon: Icons.inventory_2_outlined,
            title: l10n.adminManageCatalog,
            subtitle: l10n.adminCatalogTitle,
            onTap: () => context.push('/admin/catalog'),
          ),
          _AdminCard(
            icon: Icons.support_agent_outlined,
            title: l10n.adminAssistantTitle,
            subtitle: l10n.adminAssistantSubtitle,
            onTap: () => context.push('/admin/assistant'),
          ),
          _AdminCard(
            icon: Icons.receipt_long_outlined,
            title: l10n.adminManageOrders,
            subtitle: l10n.comingSoonPhase3,
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? AppColors.brandGreen : AppColors.textSecondary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: enabled ? const Icon(Icons.chevron_right) : null,
        enabled: enabled,
        onTap: onTap,
      ),
    );
  }
}
