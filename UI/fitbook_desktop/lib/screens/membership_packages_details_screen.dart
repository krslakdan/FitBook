import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/membership_package_insert_request.dart';
import '../models/requests/membership_package_update_request.dart';
import '../models/responses/membership_package_response.dart';
import '../providers/membership_package_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class MembershipPackagesDetailsScreen extends StatefulWidget {
  const MembershipPackagesDetailsScreen({super.key, this.package});

  final MembershipPackageResponse? package;

  bool get isEdit => package != null;

  @override
  State<MembershipPackagesDetailsScreen> createState() =>
      _MembershipPackagesDetailsScreenState();
}

class _MembershipPackagesDetailsScreenState
    extends State<MembershipPackagesDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.package?.name ?? '',
  );
  late final _durationController = TextEditingController(
    text: widget.package == null ? '' : '${widget.package!.durationDays}',
  );
  late final _priceController = TextEditingController(
    text: widget.package == null
        ? ''
        : widget.package!.price.toStringAsFixed(2),
  );
  late final _savingsController = TextEditingController(
    text: widget.package?.savingsAmount == null
        ? ''
        : widget.package!.savingsAmount!.toStringAsFixed(2),
  );
  late final _benefitsController = TextEditingController(
    text: widget.package?.includedBenefits ?? '',
  );

  late bool _isActive = widget.package?.isActive ?? true;

  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _savingsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naziv je obavezno polje.';
    if (text.length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
    if (text.length > 100) return 'Naziv ne smije biti duži od 100 karaktera.';
    return null;
  }

  String? _validateDuration(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Trajanje je obavezno polje.';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      return 'Trajanje mora biti pozitivan cijeli broj dana.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final text = (value?.trim() ?? '').replaceAll(',', '.');
    if (text.isEmpty) return 'Cijena je obavezno polje.';
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Cijena mora biti pozitivan broj.';
    }
    return null;
  }

  String? _validateSavings(String? value) {
    final text = (value?.trim() ?? '').replaceAll(',', '.');
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) {
      return 'Ušteda mora biti pozitivan broj.';
    }
    return null;
  }

  String? _validateBenefits(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Pogodnosti su obavezno polje.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<MembershipPackageProvider>();
      final name = _nameController.text.trim();
      final durationDays = int.parse(_durationController.text.trim());
      final price = double.parse(
        _priceController.text.trim().replaceAll(',', '.'),
      );
      final savingsText = _savingsController.text.trim().replaceAll(',', '.');
      final savingsAmount = savingsText.isEmpty
          ? null
          : double.parse(savingsText);
      final benefits = _benefitsController.text.trim();

      if (widget.isEdit) {
        await provider.update(
          widget.package!.id,
          MembershipPackageUpdateRequest(
            name: name,
            durationDays: durationDays,
            price: price,
            savingsAmount: savingsAmount,
            includedBenefits: benefits,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Paket članarine "$name" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          MembershipPackageInsertRequest(
            name: name,
            durationDays: durationDays,
            price: price,
            savingsAmount: savingsAmount,
            includedBenefits: benefits,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Paket članarine "$name" je uspješno dodan.');
      }
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _fieldRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _labeledField(
    String label, {
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label, required: required),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: widget.isEdit
          ? 'Izmjena paketa članarine'
          : 'Dodaj novi paket članarine',
      maxWidth: 640,
      saving: _saving,
      serverError: _serverError,
      onSave: _save,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fieldRow(
              _labeledField(
                'Naziv',
                required: true,
                child: TextFormField(
                  controller: _nameController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    hintText: 'Unesite naziv paketa',
                  ),
                  validator: _validateName,
                ),
              ),
              _labeledField(
                'Trajanje (dana)',
                required: true,
                child: TextFormField(
                  controller: _durationController,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Unesite broj dana (npr. 30)',
                  ),
                  validator: _validateDuration,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _fieldRow(
              _labeledField(
                'Cijena (KM)',
                required: true,
                child: TextFormField(
                  controller: _priceController,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Unesite cijenu (npr. 49.99)',
                  ),
                  validator: _validatePrice,
                ),
              ),
              _labeledField(
                'Ušteda (KM)',
                child: TextFormField(
                  controller: _savingsController,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Unesite uštedu (opcionalno)',
                  ),
                  validator: _validateSavings,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const FormFieldLabel('Pogodnosti', required: true),
            TextFormField(
              controller: _benefitsController,
              enabled: !_saving,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Unesite pogodnosti uključene u paket',
              ),
              validator: _validateBenefits,
            ),
            const SizedBox(height: 14),
            const FormFieldLabel('Status', required: true),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                value: _isActive,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                title: Text(
                  _isActive ? 'Aktivan' : 'Neaktivan',
                  style: const TextStyle(fontSize: 13.5),
                ),
                activeTrackColor: AppColors.primary,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _isActive = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
