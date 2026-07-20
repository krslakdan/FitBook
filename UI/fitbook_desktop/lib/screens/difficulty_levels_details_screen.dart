import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/difficulty_level_insert_request.dart';
import '../models/requests/difficulty_level_update_request.dart';
import '../models/responses/difficulty_level_response.dart';
import '../providers/difficulty_level_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class DifficultyLevelsDetailsScreen extends StatefulWidget {
  const DifficultyLevelsDetailsScreen({super.key, this.level});

  final DifficultyLevelResponse? level;

  bool get isEdit => level != null;

  @override
  State<DifficultyLevelsDetailsScreen> createState() =>
      _DifficultyLevelsDetailsScreenState();
}

class _DifficultyLevelsDetailsScreenState
    extends State<DifficultyLevelsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.level?.name ?? '',
  );
  late final _sortOrderController = TextEditingController(
    text: widget.level == null ? '' : '${widget.level!.sortOrder}',
  );

  late bool _isActive = widget.level?.isActive ?? true;

  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naziv je obavezno polje.';
    if (text.length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
    if (text.length > 100) return 'Naziv ne smije biti duži od 100 karaktera.';
    return null;
  }

  String? _validateSortOrder(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Redoslijed je obavezno polje.';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      return 'Redoslijed mora biti pozitivan cijeli broj.';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<DifficultyLevelProvider>();
      final name = _nameController.text.trim();
      final sortOrder = int.parse(_sortOrderController.text.trim());

      if (widget.isEdit) {
        await provider.update(
          widget.level!.id,
          DifficultyLevelUpdateRequest(
            name: name,
            sortOrder: sortOrder,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Nivo težine "$name" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          DifficultyLevelInsertRequest(
            name: name,
            sortOrder: sortOrder,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Nivo težine "$name" je uspješno dodan.');
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
      title: widget.isEdit ? 'Izmjena nivoa težine' : 'Dodaj novi nivo težine',
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
                hintText: 'Unesite naziv nivoa težine',
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 14),
            const FormFieldLabel('Redoslijed', required: true),
            TextFormField(
              controller: _sortOrderController,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Unesite redoslijed prikaza (npr. 1)',
              ),
              validator: _validateSortOrder,
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
