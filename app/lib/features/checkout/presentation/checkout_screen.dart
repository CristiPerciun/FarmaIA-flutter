import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../../cart/application/cart_providers.dart';
import '../../cart/presentation/widgets/order_summary.dart';
import '../application/checkout_providers.dart';
import '../domain/checkout_address.dart';

/// Step 3.2 — checkout: minimal address/contact form (guest-friendly) plus the
/// live order summary. "Continue to payment" persists the draft and advances.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();
  final _province = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill from the profile + any saved draft.
    final user = ref.read(appUserProvider).valueOrNull;
    if (user != null) {
      _name.text = user.displayName ?? '';
      _email.text = user.email;
    }
    final draft = ref.read(checkoutDraftProvider);
    if (draft != null) {
      _name.text = draft.fullName;
      _email.text = draft.email;
      _phone.text = draft.phone;
      _street.text = draft.street;
      _city.text = draft.city;
      _zip.text = draft.zip;
      _province.text = draft.province;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _street, _city, _zip, _province]) {
      c.dispose();
    }
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(checkoutDraftProvider.notifier)
        .set(
          CheckoutAddress(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            street: _street.text.trim(),
            city: _city.text.trim(),
            zip: _zip.text.trim(),
            province: _province.text.trim(),
          ),
        );
    context.push('/checkout/payment');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pricing = ref.watch(cartPricingProvider);
    final signedIn = ref.watch(currentUserProvider) != null;

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!signedIn)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GuestNote(text: l10n.checkoutGuestNote),
                    ),
                  Text(
                    l10n.checkoutContact,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.fieldFullName,
                    controller: _name,
                    validator: required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.emailLabel,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return v.contains('@') ? null : l10n.invalidEmail;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.fieldPhone,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: required,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.checkoutShippingAddress,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.fieldStreet,
                    controller: _street,
                    validator: required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.fieldCity,
                    controller: _city,
                    validator: required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.fieldZip,
                          controller: _zip,
                          keyboardType: TextInputType.number,
                          validator: required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: l10n.fieldProvince,
                          controller: _province,
                          validator: required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OrderSummary(pricing: pricing),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _continue,
                    child: Text(l10n.checkoutContinueToPayment),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestNote extends StatelessWidget {
  const _GuestNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ambientAzure,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.brandGreenDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
