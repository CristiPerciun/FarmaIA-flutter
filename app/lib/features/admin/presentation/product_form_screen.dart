import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/localized_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_support.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/category.dart';
import '../../catalog/domain/product.dart';
import '../application/admin_product_providers.dart';
import '../application/ai_pipeline_providers.dart';
import 'admin_labels.dart';

/// Steps 4.1 + 4.4 — create a draft (with photo → Storage) and, once created,
/// review/edit its AI-generated content and publish it (§10). No product is
/// ever visible to customers before a pharmacist clicks "Pubblica".
class ProductFormScreen extends ConsumerWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (productId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminNewProductTitle)),
        body: const _CreateDraftForm(),
      );
    }
    final async = ref.watch(adminProductProvider(productId!));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminEditProductTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.genericErrorRetry)),
        data: (product) => product == null
            ? Center(child: Text(l10n.productNotFound))
            : _EditProductForm(product: product),
      ),
    );
  }
}

// --- 4.1: create a minimal draft -------------------------------------------

class _CreateDraftForm extends ConsumerStatefulWidget {
  const _CreateDraftForm();

  @override
  ConsumerState<_CreateDraftForm> createState() => _CreateDraftFormState();
}

class _CreateDraftFormState extends ConsumerState<_CreateDraftForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameIt = TextEditingController();
  final _nameEn = TextEditingController();
  final _priceList = TextEditingController();
  final _priceSale = TextEditingController(text: '0');
  final _vatRate = TextEditingController(text: '22');
  ProductType _type = ProductType.parafarmaco;
  String? _categoryRef;
  _PickedImage? _image;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_nameIt, _nameEn, _priceList, _priceSale, _vatRate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(adminProductRepositoryProvider);
    try {
      final id = await repo.createDraft(
        name: LocalizedText(
          it: _nameIt.text.trim(),
          en: _nameEn.text.trim().isEmpty
              ? _nameIt.text.trim()
              : _nameEn.text.trim(),
        ),
        type: _type,
        categoryRef: _categoryRef ?? '',
        priceList: int.tryParse(_priceList.text.trim()) ?? 0,
        priceSale: int.tryParse(_priceSale.text.trim()) ?? 0,
        vatRate: int.tryParse(_vatRate.text.trim()) ?? 22,
      );
      if (_image != null) {
        await repo.uploadRawImage(
          productId: id,
          bytes: _image!.bytes,
          fileName: _image!.name,
          contentType: _image!.contentType,
        );
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminDraftCreated)));
      router.pushReplacement('/admin/products/$id');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericErrorRetry)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];

    String? req(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ImagePickerField(
                image: _image,
                onPicked: (img) => setState(() => _image = img),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.adminProductNameIt,
                controller: _nameIt,
                validator: req,
              ),
              const SizedBox(height: 12),
              AppTextField(label: l10n.adminProductNameEn, controller: _nameEn),
              const SizedBox(height: 12),
              _TypeDropdown(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 12),
              _CategoryDropdown(
                categories: categories,
                value: _categoryRef,
                onChanged: (c) => setState(() => _categoryRef = c),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.adminPriceList,
                      controller: _priceList,
                      keyboardType: TextInputType.number,
                      validator: req,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: l10n.adminPriceSale,
                      controller: _priceSale,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.adminVatRate,
                controller: _vatRate,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const _WhiteSpinner()
                    : Text(l10n.adminCreateDraft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4.4: edit AI content, review and publish ------------------------------

class _EditProductForm extends ConsumerStatefulWidget {
  const _EditProductForm({required this.product});

  final Product product;

  @override
  ConsumerState<_EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends ConsumerState<_EditProductForm> {
  late final Map<String, TextEditingController> _c;
  late bool _ceMarking;
  late bool _available;
  late bool _assistantEligible;
  bool _generating = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _c = {
      'shortIt': TextEditingController(text: p.shortDescription.it),
      'shortEn': TextEditingController(text: p.shortDescription.en),
      'descIt': TextEditingController(text: p.description.it),
      'descEn': TextEditingController(text: p.description.en),
      'ingIt': TextEditingController(text: p.activeIngredient.it),
      'ingEn': TextEditingController(text: p.activeIngredient.en),
      'posIt': TextEditingController(text: p.posology.it),
      'posEn': TextEditingController(text: p.posology.en),
      'contraIt': TextEditingController(text: p.contraindications.it),
      'contraEn': TextEditingController(text: p.contraindications.en),
      'warnIt': TextEditingController(text: p.warnings.it),
      'warnEn': TextEditingController(text: p.warnings.en),
      'stock': TextEditingController(text: '${p.stockQty}'),
    };
    _ceMarking = p.ceMarking;
    _available = p.available;
    _assistantEligible = p.assistantEligible;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  LocalizedText _lt(String itKey, String enKey) =>
      LocalizedText(it: _c[itKey]!.text.trim(), en: _c[enKey]!.text.trim());

  Map<String, dynamic> _formData() => {
    'shortDescription': _lt('shortIt', 'shortEn').toJson(),
    'description': _lt('descIt', 'descEn').toJson(),
    'activeIngredient': _lt('ingIt', 'ingEn').toJson(),
    'posology': _lt('posIt', 'posEn').toJson(),
    'contraindications': _lt('contraIt', 'contraEn').toJson(),
    'warnings': _lt('warnIt', 'warnEn').toJson(),
    'ceMarking': _ceMarking,
    'available': _available,
    'assistantEligible': _assistantEligible,
    'stockQty': int.tryParse(_c['stock']!.text.trim()) ?? 0,
  };

  Future<void> _run(Future<void> Function() action, String okMsg) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(okMsg)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.genericErrorRetry),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() {
    final repo = ref.read(adminProductRepositoryProvider);
    return _run(
      () => repo.update(widget.product.id, _formData()),
      AppLocalizations.of(context)!.adminSaved,
    );
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(aiPipelineServiceProvider)
          .generateTexts(widget.product.id);
      // The function writes to the doc; adminProductProvider re-streams it.
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminTextsGenerated)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericErrorRetry)));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;
    // Enforce the medicine publishing rule against the *current form* content.
    final p = widget.product;
    final draft = Product.fromJson({...p.toJson(), ..._formData()}, p.id);
    if (!draft.meetsMedicinePublishingRule) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminCannotPublishMedicine)));
      return;
    }
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    final repo = ref.read(adminProductRepositoryProvider);
    await _run(() async {
      await repo.update(p.id, _formData());
      await repo.publish(p.id, uid);
    }, l10n.adminPublished);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.product;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusHeader(product: p),
            const SizedBox(height: 12),
            if (p.images.isNotEmpty)
              _ImagePreview(url: p.images.first.url, status: p.aiImageStatus),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _generating
                    ? l10n.adminGeneratingTexts
                    : l10n.adminGenerateTexts,
              ),
            ),
            const SizedBox(height: 8),
            if (p.aiGenerated)
              Text(
                l10n.adminReviewNote,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.brandCrimson),
              ),
            const Divider(height: 32),
            _SectionTitle(l10n.adminSectionTexts),
            _BilingualField(
              label: l10n.adminFieldShortDescription,
              itC: _c['shortIt']!,
              enC: _c['shortEn']!,
            ),
            _BilingualField(
              label: l10n.adminFieldDescription,
              itC: _c['descIt']!,
              enC: _c['descEn']!,
              maxLines: 3,
            ),
            _BilingualField(
              label: l10n.adminFieldActiveIngredient,
              itC: _c['ingIt']!,
              enC: _c['ingEn']!,
            ),
            _BilingualField(
              label: l10n.adminFieldPosology,
              itC: _c['posIt']!,
              enC: _c['posEn']!,
              maxLines: 2,
            ),
            _BilingualField(
              label: l10n.adminFieldContraindications,
              itC: _c['contraIt']!,
              enC: _c['contraEn']!,
              maxLines: 2,
            ),
            _BilingualField(
              label: l10n.adminFieldWarnings,
              itC: _c['warnIt']!,
              enC: _c['warnEn']!,
              maxLines: 2,
            ),
            const Divider(height: 32),
            _SectionTitle(l10n.adminSectionPublish),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.adminStock,
                    controller: _c['stock']!,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminAvailable),
              value: _available,
              activeThumbColor: AppColors.brandGreen,
              onChanged: (v) => setState(() => _available = v),
            ),
            // Pharmacist opt-out from AI suggestions (§12.3-12.4, step 4B.7).
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminAssistantEligible),
              subtitle: Text(l10n.adminAssistantEligibleHint),
              value: _assistantEligible,
              activeThumbColor: AppColors.brandGreen,
              onChanged: (v) => setState(() => _assistantEligible = v),
            ),
            if (p.type == ProductType.dispositivoMedico)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminCeMarking),
                value: _ceMarking,
                activeThumbColor: AppColors.brandGreen,
                onChanged: (v) => setState(() => _ceMarking = v),
              ),
            if (p.reviewedBy != null && p.reviewedBy!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.adminReviewedBy(p.reviewedBy!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreenDark,
                  ),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.adminSave),
                ),
                if (p.status != ProductStatus.published)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                    ),
                    onPressed: _busy ? null : _publish,
                    icon: const Icon(Icons.publish_outlined),
                    label: Text(l10n.adminPublish),
                  ),
                if (p.status == ProductStatus.published)
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(adminProductRepositoryProvider)
                                .unpublish(p.id),
                            l10n.adminSaved,
                          ),
                    icon: const Icon(Icons.unpublished_outlined),
                    label: Text(l10n.adminUnpublish),
                  ),
                if (p.status != ProductStatus.archived)
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(adminProductRepositoryProvider)
                                .archive(p.id),
                            l10n.adminArchived,
                          ),
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(l10n.adminArchive),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- shared bits ------------------------------------------------------------

class _PickedImage {
  const _PickedImage({
    required this.bytes,
    required this.name,
    required this.contentType,
  });
  final Uint8List bytes;
  final String name;
  final String contentType;
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({required this.image, required this.onPicked});

  final _PickedImage? image;
  final ValueChanged<_PickedImage> onPicked;

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 2000);
    if (file == null) return;
    onPicked(
      _PickedImage(
        bytes: await file.readAsBytes(),
        name: file.name,
        contentType: file.mimeType ?? 'image/jpeg',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ambientAzure.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (image != null) ...[
            SizedBox(
              height: 140,
              child: Image.memory(image!.bytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(l10n.adminImageSelected),
            const SizedBox(height: 8),
          ] else
            const Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: AppColors.brandGreen,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.adminPickImage),
              ),
              // Camera capture is mobile-only (§4.4 platform guard).
              if (PlatformSupport.isMobile)
                OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.adminTakePhoto),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url, required this.status});

  final String url;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
        if (status != null)
          Text(
            '${l10n.adminAiImageStatusLabel}: $status',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            product.name.it,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (product.aiGenerated)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              visualDensity: VisualDensity.compact,
              backgroundColor: AppColors.brandGold.withValues(alpha: 0.2),
              label: Text(l10n.adminAiGeneratedBadge),
            ),
          ),
        Chip(
          visualDensity: VisualDensity.compact,
          label: Text(product.status.label(l10n)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.brandGreenDark,
      ),
    ),
  );
}

class _BilingualField extends StatelessWidget {
  const _BilingualField({
    required this.label,
    required this.itC,
    required this.enC,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController itC;
  final TextEditingController enC;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: itC,
              maxLines: maxLines,
              decoration: InputDecoration(labelText: '$label (IT)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: enC,
              maxLines: maxLines,
              decoration: InputDecoration(labelText: '$label (EN)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});

  final ProductType value;
  final ValueChanged<ProductType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<ProductType>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.adminProductType),
      items: [
        for (final t in ProductType.values)
          DropdownMenuItem(value: t, child: Text(t.label(l10n))),
      ],
      onChanged: (t) => t == null ? null : onChanged(t),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.catalogFilterCategory),
      items: [
        for (final c in categories)
          DropdownMenuItem(value: c.id, child: Text(c.name.it)),
      ],
      onChanged: onChanged,
    );
  }
}

class _WhiteSpinner extends StatelessWidget {
  const _WhiteSpinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );
}
