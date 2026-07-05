import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/admin_assistant_providers.dart';

/// Pharmacist-curated guardrail lists (§12.4, step 4B.7): extra red-flag
/// terms and Rx terms on `config/assistant`, effective at the next chat turn
/// — no deploy. The built-in server defaults always stay active; these lists
/// only ADD terms.
class AdminAssistantGuardrailsScreen extends ConsumerStatefulWidget {
  const AdminAssistantGuardrailsScreen({super.key});

  @override
  ConsumerState<AdminAssistantGuardrailsScreen> createState() =>
      _AdminAssistantGuardrailsScreenState();
}

class _AdminAssistantGuardrailsScreenState
    extends ConsumerState<AdminAssistantGuardrailsScreen> {
  List<String>? _redFlags;
  List<String>? _rxTerms;
  bool _busy = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(adminAssistantRepositoryProvider)
          .saveGuardrailConfig(
            redFlags: _redFlags ?? const [],
            rxTerms: _rxTerms ?? const [],
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericErrorRetry)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(adminAssistantGuardrailsProvider).valueOrNull;
    // Local editable copies, seeded once from the stream.
    _redFlags ??= config == null ? null : [...config.redFlags];
    _rxTerms ??= config == null ? null : [...config.rxTerms];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAssistantGuardrails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _redFlags == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.adminAssistantBuiltinNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _TermListEditor(
                  title: l10n.adminAssistantRedFlagList,
                  icon: Icons.emergency_outlined,
                  color: AppColors.alert,
                  terms: _redFlags!,
                  addHint: l10n.adminAssistantAddTerm,
                  onChanged: (terms) => setState(() => _redFlags = terms),
                ),
                const SizedBox(height: 24),
                _TermListEditor(
                  title: l10n.adminAssistantRxList,
                  icon: Icons.receipt_outlined,
                  color: AppColors.brandCrimson,
                  terms: _rxTerms!,
                  addHint: l10n.adminAssistantAddTerm,
                  onChanged: (terms) => setState(() => _rxTerms = terms),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.adminSave),
                ),
              ],
            ),
    );
  }
}

class _TermListEditor extends StatefulWidget {
  const _TermListEditor({
    required this.title,
    required this.icon,
    required this.color,
    required this.terms,
    required this.addHint,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> terms;
  final String addHint;
  final void Function(List<String>) onChanged;

  @override
  State<_TermListEditor> createState() => _TermListEditorState();
}

class _TermListEditorState extends State<_TermListEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final term = _controller.text.trim().toLowerCase();
    if (term.isEmpty || widget.terms.contains(term)) return;
    _controller.clear();
    widget.onChanged([...widget.terms, term]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 20, color: widget.color),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in widget.terms)
              Chip(
                label: Text(term),
                onDeleted: () => widget.onChanged([
                  for (final t in widget.terms)
                    if (t != term) t,
                ]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.addHint,
                  isDense: true,
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _add,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
