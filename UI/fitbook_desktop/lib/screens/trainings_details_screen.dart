import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/training_insert_request.dart';
import '../models/requests/training_update_request.dart';
import '../models/responses/difficulty_level_response.dart';
import '../models/responses/training_category_response.dart';
import '../models/responses/training_response.dart';
import '../models/search_objects/difficulty_level_search_object.dart';
import '../models/search_objects/training_category_search_object.dart';
import '../providers/difficulty_level_provider.dart';
import '../providers/training_category_provider.dart';
import '../providers/training_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';

class TrainingsDetailsScreen extends StatefulWidget {
  const TrainingsDetailsScreen({super.key, this.training});

  final TrainingResponse? training;

  bool get isEdit => training != null;

  @override
  State<TrainingsDetailsScreen> createState() => _TrainingsDetailsScreenState();
}

class _TrainingsDetailsScreenState extends State<TrainingsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.training?.name ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.training?.description ?? '',
  );
  late final _durationController = TextEditingController(
    text: widget.training == null ? '' : '${widget.training!.durationMinutes}',
  );
  late final _maxParticipantsController = TextEditingController(
    text: widget.training == null ? '' : '${widget.training!.maxParticipants}',
  );

  late int? _trainingCategoryId = widget.training?.trainingCategoryId;
  late int? _difficultyLevelId = widget.training?.difficultyLevelId;
  late bool _isActive = widget.training?.isActive ?? true;

  List<TrainingCategoryResponse> _categories = const [];
  List<DifficultyLevelResponse> _levels = const [];
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
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final categories = await context.read<TrainingCategoryProvider>().get(
        filter: const TrainingCategorySearchObject(pageSize: 100),
      );
      if (!mounted) return;
      final levels = await context.read<DifficultyLevelProvider>().get(
        filter: const DifficultyLevelSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      setState(() {
        _categories = categories.items;
        _levels = levels.items;
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

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naziv je obavezno polje.';
    if (text.length < 2) return 'Naziv mora imati najmanje 2 karaktera.';
    if (text.length > 100) return 'Naziv ne smije biti duži od 100 karaktera.';
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Opis je obavezno polje.';
    if (text.length < 10) return 'Opis mora imati najmanje 10 karaktera.';
    return null;
  }

  String? _validatePositiveInt(String? value, String field) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field je obavezno polje.';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      return '$field mora biti pozitivan cijeli broj.';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<TrainingProvider>();
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final durationMinutes = int.parse(_durationController.text.trim());
      final maxParticipants = int.parse(
        _maxParticipantsController.text.trim(),
      );

      if (widget.isEdit) {
        await provider.update(
          widget.training!.id,
          TrainingUpdateRequest(
            name: name,
            description: description,
            durationMinutes: durationMinutes,
            maxParticipants: maxParticipants,
            isActive: _isActive,
            trainingCategoryId: _trainingCategoryId!,
            difficultyLevelId: _difficultyLevelId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Trening "$name" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          TrainingInsertRequest(
            name: name,
            description: description,
            durationMinutes: durationMinutes,
            maxParticipants: maxParticipants,
            isActive: _isActive,
            trainingCategoryId: _trainingCategoryId!,
            difficultyLevelId: _difficultyLevelId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Trening "$name" je uspješno dodan.');
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

  List<DropdownMenuItem<int>> _categoryItems() {
    final items = [
      for (final category in _categories)
        DropdownMenuItem(
          value: category.id,
          child: Text(
            category.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final training = widget.training;
    if (training != null &&
        !_categories.any((c) => c.id == training.trainingCategoryId)) {
      items.add(
        DropdownMenuItem(
          value: training.trainingCategoryId,
          child: Text(
            training.trainingCategoryName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> _levelItems() {
    final items = [
      for (final level in _levels)
        DropdownMenuItem(
          value: level.id,
          child: Text(
            level.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final training = widget.training;
    if (training != null &&
        !_levels.any((l) => l.id == training.difficultyLevelId)) {
      items.add(
        DropdownMenuItem(
          value: training.difficultyLevelId,
          child: Text(
            training.difficultyLevelName,
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
      title: widget.isEdit ? 'Izmjena treninga' : 'Dodaj novi trening',
      maxWidth: 640,
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
                  const FormFieldLabel('Naziv', required: true),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      hintText: 'Unesite naziv treninga',
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Opis', required: true),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_saving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Unesite opis treninga',
                    ),
                    validator: _validateDescription,
                  ),
                  const SizedBox(height: 14),
                  _fieldRow(
                    _labeledField(
                      'Kategorija',
                      required: true,
                      child: DropdownButtonFormField<int>(
                        initialValue: _trainingCategoryId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        hint: const Text(
                          'Odaberite kategoriju',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        items: _categoryItems(),
                        validator: (value) =>
                            value == null ? 'Kategorija je obavezna.' : null,
                        onChanged: _saving
                            ? null
                            : (value) =>
                                  setState(() => _trainingCategoryId = value),
                      ),
                    ),
                    _labeledField(
                      'Nivo težine',
                      required: true,
                      child: DropdownButtonFormField<int>(
                        initialValue: _difficultyLevelId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        hint: const Text(
                          'Odaberite nivo težine',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        items: _levelItems(),
                        validator: (value) =>
                            value == null ? 'Nivo težine je obavezan.' : null,
                        onChanged: _saving
                            ? null
                            : (value) =>
                                  setState(() => _difficultyLevelId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldRow(
                    _labeledField(
                      'Trajanje (minuta)',
                      required: true,
                      child: TextFormField(
                        controller: _durationController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Unesite trajanje (npr. 60)',
                        ),
                        validator: (v) => _validatePositiveInt(v, 'Trajanje'),
                      ),
                    ),
                    _labeledField(
                      'Max učesnika',
                      required: true,
                      child: TextFormField(
                        controller: _maxParticipantsController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Unesite maksimalan broj učesnika',
                        ),
                        validator: (v) =>
                            _validatePositiveInt(v, 'Max učesnika'),
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
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
