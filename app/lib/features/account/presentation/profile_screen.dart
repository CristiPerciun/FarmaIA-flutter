import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';

/// Profile hub (§7.4). Signed-out users see login/registration CTAs; signed-in
/// users see their account, consents, and — for staff — the Cliente/Admin view
/// switch and a link to the admin area (§2.2).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: user == null ? _GuestView(l10n: l10n) : _AccountView(l10n: l10n),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 72,
                color: AppColors.brandGreen,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.guestProfileMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.signIn,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: l10n.createAccount,
                variant: AppButtonVariant.outlined,
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountView extends ConsumerWidget {
  const _AccountView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider).valueOrNull;
    final isStaff = ref.watch(isStaffProvider);
    final viewMode = ref.watch(viewModeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: AppColors.brandGreen,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(appUser?.displayName ?? l10n.profileTitle),
          subtitle: Text(appUser?.email ?? ''),
          trailing: _RoleBadge(role: appUser?.role ?? UserRole.customer),
        ),
        const Divider(height: 32),

        // Cliente/Admin view switch — staff only (§2.2).
        if (isStaff) ...[
          Text(
            l10n.viewModeLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ViewMode>(
            segments: [
              ButtonSegment(
                value: ViewMode.customer,
                label: Text(l10n.viewAsCustomer),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              ButtonSegment(
                value: ViewMode.admin,
                label: Text(l10n.viewAsAdmin),
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (s) =>
                ref.read(viewModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 12),
          if (viewMode == ViewMode.admin)
            AppButton(
              label: l10n.adminAreaTitle,
              icon: Icons.dashboard_outlined,
              onPressed: () => context.go('/admin'),
            ),
          const Divider(height: 32),
        ],

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.consentsTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/account/consents'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text(l10n.ordersTitle),
          subtitle: Text(l10n.comingSoonPhase3),
          enabled: false,
        ),
        const Divider(height: 32),
        AppButton(
          label: l10n.signOut,
          variant: AppButtonVariant.outlined,
          icon: Icons.logout,
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go('/');
          },
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (role) {
      UserRole.admin => l10n.roleAdmin,
      UserRole.pharmacist => l10n.rolePharmacist,
      UserRole.customer => l10n.roleCustomer,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: role.isStaff ? AppColors.brandGreenDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: role.isStaff ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
