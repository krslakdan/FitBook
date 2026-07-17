import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/equipment_insert_request.dart';
import '../models/requests/equipment_update_request.dart';
import '../models/responses/equipment_response.dart';
import '../providers/equipment_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  const EquipmentDetailsScreen({super.key, this.equipment});

  final EquipmentResponse? equipment;

  bool get isEdit => equipment != null;

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.equipment?.name ?? '',
  );

  late bool _isActive = widget.equipment?.isActive ?? true;

  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naziv je obavezno polje.';
    if (text.length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
    if (text.length > 100) return 'Naziv ne smije biti duži od 100 karaktera.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<EquipmentProvider>();
      final name = _nameController.text.trim();

      if (widget.isEdit) {
        await provider.update(
          widget.equipment!.id,
          EquipmentUpdateRequest(name: name, isActive: _isActive),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Oprema "$name" je uspješno izmijenjena.');
      } else {
        await provider.insert(
          EquipmentInsertRequest(name: name, isActive: _isActive),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Oprema "$name" je uspješno dodana.');
      }
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: widget.isEdit ? 'Izmjena opreme' : 'Dodaj novu opremu',
      maxWidth: 520,
      saving: _saving,
      serverError: _serverError,
      onSave: _save,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FormFieldLabel('Naziv', required: true),
            TextFormField(
              controller: _nameController,
              enabled: !_saving,
              decoration: const InputDecoration(
                hintText: 'Unesite naziv opreme',
              ),
              validator: _validateName,
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
                  _isActive ? 'Aktivna' : 'Neaktivna',
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
