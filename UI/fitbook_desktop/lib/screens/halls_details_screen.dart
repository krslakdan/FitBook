import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/hall_insert_request.dart';
import '../models/requests/hall_update_request.dart';
import '../models/responses/hall_response.dart';
import '../providers/hall_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class HallsDetailsScreen extends StatefulWidget {
  const HallsDetailsScreen({super.key, this.hall});

  final HallResponse? hall;

  bool get isEdit => hall != null;

  @override
  State<HallsDetailsScreen> createState() => _HallsDetailsScreenState();
}

class _HallsDetailsScreenState extends State<HallsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.hall?.name ?? '',
  );
  late final _capacityController = TextEditingController(
    text: widget.hall == null ? '' : '${widget.hall!.capacity}',
  );
  late final _locationController = TextEditingController(
    text: widget.hall?.locationDescription ?? '',
  );

  late bool _isActive = widget.hall?.isActive ?? true;

  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naziv je obavezno polje.';
    if (text.length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
    if (text.length > 100) return 'Naziv ne smije biti duži od 100 karaktera.';
    return null;
  }

  String? _validateCapacity(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Kapacitet je obavezno polje.';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      return 'Kapacitet mora biti pozitivan cijeli broj.';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<HallProvider>();
      final name = _nameController.text.trim();
      final capacity = int.parse(_capacityController.text.trim());
      final location = _locationController.text.trim();

      if (widget.isEdit) {
        await provider.update(
          widget.hall!.id,
          HallUpdateRequest(
            name: name,
            capacity: capacity,
            locationDescription: location.isEmpty ? null : location,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Sala "$name" je uspješno izmijenjena.');
      } else {
        await provider.insert(
          HallInsertRequest(
            name: name,
            capacity: capacity,
            locationDescription: location.isEmpty ? null : location,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Sala "$name" je uspješno dodana.');
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
      title: widget.isEdit ? 'Izmjena sale' : 'Dodaj novu salu',
      maxWidth: 560,
      saving: _saving,
      serverError: _serverError,
      onSave: _save,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormFieldLabel('Naziv', required: true),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          hintText: 'Unesite naziv sale',
                        ),
                        validator: _validateName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormFieldLabel('Kapacitet', required: true),
                      TextFormField(
                        controller: _capacityController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Unesite kapacitet',
                        ),
                        validator: _validateCapacity,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FormFieldLabel('Opis lokacije'),
            TextFormField(
              controller: _locationController,
              enabled: !_saving,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Unesite opis lokacije sale (opcionalno)',
              ),
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
