import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/training_equipment_insert_request.dart';
import '../models/requests/training_equipment_update_request.dart';
import '../models/responses/equipment_response.dart';
import '../models/responses/training_equipment_response.dart';
import '../models/responses/training_response.dart';
import '../models/search_objects/equipment_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../providers/equipment_provider.dart';
import '../providers/training_equipment_provider.dart';
import '../providers/training_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class TrainingEquipmentDetailsScreen extends StatefulWidget {
  const TrainingEquipmentDetailsScreen({super.key, this.trainingEquipment});

  final TrainingEquipmentResponse? trainingEquipment;

  bool get isEdit => trainingEquipment != null;

  @override
  State<TrainingEquipmentDetailsScreen> createState() =>
      _TrainingEquipmentDetailsScreenState();
}

class _TrainingEquipmentDetailsScreenState
    extends State<TrainingEquipmentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _noteController = TextEditingController(
    text: widget.trainingEquipment?.note ?? '',
  );

  late int? _trainingId = widget.trainingEquipment?.trainingId;
  late int? _equipmentId = widget.trainingEquipment?.equipmentId;
  late bool _isRequired = widget.trainingEquipment?.isRequired ?? true;

  List<TrainingResponse> _trainings = const [];
  List<EquipmentResponse> _equipmentList = const [];
  bool _lookupsLoading = true;

  bool _saving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final trainings = await context.read<TrainingProvider>().get(
        filter: const TrainingSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      final equipment = await context.read<EquipmentProvider>().get(
        filter: const EquipmentSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      setState(() {
        _trainings = trainings.items;
        _equipmentList = equipment.items;
        _lookupsLoading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _lookupsLoading = false;
        _serverError = e.message;
      });
    }
  }

  String _selectedEquipmentName() {
    for (final equipment in _equipmentList) {
      if (equipment.id == _equipmentId) return equipment.name;
    }
    return widget.trainingEquipment?.equipmentName ?? '';
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<TrainingEquipmentProvider>();
      final note = _noteController.text.trim();
      final equipmentName = _selectedEquipmentName();

      if (widget.isEdit) {
        await provider.update(
          widget.trainingEquipment!.id,
          TrainingEquipmentUpdateRequest(
            isRequired: _isRequired,
            note: note.isEmpty ? null : note,
            trainingId: _trainingId!,
            equipmentId: _equipmentId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Oprema treninga "$equipmentName" je uspješno izmijenjena.');
      } else {
        await provider.insert(
          TrainingEquipmentInsertRequest(
            isRequired: _isRequired,
            note: note.isEmpty ? null : note,
            trainingId: _trainingId!,
            equipmentId: _equipmentId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Oprema "$equipmentName" je uspješno dodana treningu.');
      }
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<DropdownMenuItem<int>> _trainingItems() {
    final items = [
      for (final training in _trainings)
        DropdownMenuItem(
          value: training.id,
          child: Text(
            training.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final trainingEquipment = widget.trainingEquipment;
    if (trainingEquipment != null &&
        !_trainings.any((t) => t.id == trainingEquipment.trainingId)) {
      items.add(
        DropdownMenuItem(
          value: trainingEquipment.trainingId,
          child: Text(
            trainingEquipment.trainingName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> _equipmentItems() {
    final items = [
      for (final equipment in _equipmentList)
        DropdownMenuItem(
          value: equipment.id,
          child: Text(
            equipment.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final trainingEquipment = widget.trainingEquipment;
    if (trainingEquipment != null &&
        !_equipmentList.any((e) => e.id == trainingEquipment.equipmentId)) {
      items.add(
        DropdownMenuItem(
          value: trainingEquipment.equipmentId,
          child: Text(
            trainingEquipment.equipmentName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: widget.isEdit
          ? 'Izmjena opreme treninga'
          : 'Dodaj opremu treningu',
      maxWidth: 560,
      saving: _saving,
      serverError: _serverError,
      onSave: _lookupsLoading ? null : _save,
      child: _lookupsLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FormFieldLabel('Trening', required: true),
                  DropdownButtonFormField<int>(
                    initialValue: _trainingId,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    hint: const Text(
                      'Odaberite trening',
                      style: TextStyle(fontSize: 13.5),
                    ),
                    items: _trainingItems(),
                    validator: (value) =>
                        value == null ? 'Trening je obavezan.' : null,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _trainingId = value),
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Oprema', required: true),
                  DropdownButtonFormField<int>(
                    initialValue: _equipmentId,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    hint: const Text(
                      'Odaberite opremu',
                      style: TextStyle(fontSize: 13.5),
                    ),
                    items: _equipmentItems(),
                    validator: (value) =>
                        value == null ? 'Oprema je obavezna.' : null,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _equipmentId = value),
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Napomena'),
                  TextFormField(
                    controller: _noteController,
                    enabled: !_saving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Unesite napomenu (opcionalno)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Obavezna oprema', required: true),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SwitchListTile(
                      value: _isRequired,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      title: Text(
                        _isRequired ? 'Obavezna' : 'Opcionalna',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      activeTrackColor: AppColors.primary,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _isRequired = value),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
