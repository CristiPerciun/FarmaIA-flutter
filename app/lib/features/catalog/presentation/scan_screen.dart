import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_support.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../application/catalog_providers.dart';

/// Step 2.5 — scan a product EAN and jump to its detail page. On mobile the
/// camera drives the lookup; on desktop/web (no `mobile_scanner`) the screen
/// falls back to manual EAN entry (§2.5, §4.4 platform guard).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _handling = false;
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _lookup(String rawCode) async {
    final code = rawCode.trim();
    if (_handling || code.isEmpty) return;
    setState(() => _handling = true);

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final product = await ref
        .read(productRepositoryProvider)
        .fetchPublishedProductByBarcode(code);
    if (!mounted) return;

    if (product != null) {
      router.pushReplacement('/product/${product.id}');
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.scanNotFound(code))));
    setState(() => _handling = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: Column(
        children: [
          if (PlatformSupport.barcodeScanner)
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final code = capture.barcodes.isNotEmpty
                      ? capture.barcodes.first.rawValue
                      : null;
                  if (code != null) _lookup(code);
                },
              ),
            )
          else
            Expanded(child: _UnsupportedHint(message: l10n.scanNotSupported)),
          _ManualEntry(
            controller: _manualController,
            enabled: !_handling,
            onSubmit: _lookup,
          ),
        ],
      ),
    );
  }
}

class _UnsupportedHint extends StatelessWidget {
  const _UnsupportedHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.keyboard_alt_outlined,
                size: 56,
                color: AppColors.brandGreen,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  const _ManualEntry({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmit,
                decoration: InputDecoration(
                  labelText: l10n.scanManualTitle,
                  hintText: l10n.scanManualHint,
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                minimumSize: const Size(72, 56),
              ),
              onPressed: enabled ? () => onSubmit(controller.text) : null,
              child: Text(l10n.scanManualSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
