import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/application/cart_providers.dart';
import '../../cart/presentation/widgets/order_summary.dart';
import '../application/checkout_providers.dart';
import '../domain/payment_method.dart';

/// Step 3.3 — payment method selection + pay. The charge itself runs
/// server-side via a sandbox provider that stands in for the real gateways
/// (ADR 0003); keys are never in the client.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.card;
  bool _processing = false;

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context)!;
    final address = ref.read(checkoutDraftProvider);
    if (address == null) {
      context.go('/checkout');
      return;
    }
    setState(() => _processing = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final placed = await ref
          .read(checkoutServiceProvider)
          .placeOrder(address: address, method: _method);
      ref.read(checkoutDraftProvider.notifier).clear();
      if (!mounted) return;
      router.go('/order/confirmed', extra: placed.orderNumber);
    } catch (_) {
      if (!mounted) return;
      setState(() => _processing = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.paymentFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pricing = ref.watch(cartPricingProvider);
    final code = Localizations.localeOf(context).languageCode;
    final total = pricing.totals.total.formatMoney(localeCode: code);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.paymentMethod,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                RadioGroup<PaymentMethod>(
                  groupValue: _method,
                  onChanged: (v) {
                    if (!_processing && v != null) {
                      setState(() => _method = v);
                    }
                  },
                  child: Column(
                    children: [
                      for (final method in PaymentMethod.values)
                        RadioListTile<PaymentMethod>(
                          value: method,
                          activeColor: AppColors.brandGreen,
                          title: Text(method.label(l10n)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _SandboxNotice(text: l10n.paymentSandboxNotice),
                const SizedBox(height: 16),
                OrderSummary(pricing: pricing),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _processing ? null : _pay,
                  child: _processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.paymentPay(total)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SandboxNotice extends StatelessWidget {
  const _SandboxNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: AppColors.brandGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
