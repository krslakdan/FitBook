import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/training_term_insert_request.dart';
import '../models/requests/training_term_update_request.dart';
import '../models/responses/hall_response.dart';
import '../models/responses/trainer_response.dart';
import '../models/responses/training_response.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/hall_search_object.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../providers/hall_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/training_provider.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/form_dialog.dart';

class TrainingTermsDetailsScreen extends StatefulWidget {
  const TrainingTermsDetailsScreen({super.key, this.term});

  final TrainingTermResponse? term;

  bool get isEdit => term != null;

  @override
  State<TrainingTermsDetailsScreen> createState() =>
      _TrainingTermsDetailsScreenState();
}

class _TrainingTermsDetailsScreenState
    extends State<TrainingTermsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late int? _trainingId = widget.term?.trainingId;
  late int? _trainerId = widget.term?.trainerId;
  late int? _hallId = widget.term?.hallId;
  late DateTime? _startTime = widget.term?.startTimeUtc.toLocal();
  late DateTime? _endTime = widget.term?.endTimeUtc.toLocal();
  late final _maxParticipantsController = TextEditingController(
    text: widget.term == null ? '' : '${widget.term!.maxParticipants}',
  );
  late bool _isActive = widget.term?.isActive ?? true;

  late final _startTimeController = TextEditingController(
    text: _startTime == null ? '' : _formatLocal(_startTime!),
  );
  late final _endTimeController = TextEditingController(
    text: _endTime == null ? '' : _formatLocal(_endTime!),
  );

  List<TrainingResponse> _trainings = const [];
  List<TrainerResponse> _trainers = const [];
  List<HallResponse> _halls = const [];
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
    _maxParticipantsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  static String _formatLocal(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(value.day)}.${two(value.month)}.${value.year}. ${two(value.hour)}:${two(value.minute)}';
  }

  Future<void> _loadLookups() async {
    try {
      List<TrainingResponse> trainings = const [];
      if (!widget.isEdit) {
        final result = await context.read<TrainingProvider>().get(
          filter: const TrainingSearchObject(pageSize: 100, isActive: true),
        );
        trainings = result.items;
      }
      if (!mounted) return;
      final trainers = await context.read<TrainerProvider>().get(
        filter: const TrainerSearchObject(pageSize: 100, isActive: true),
      );
      if (!mounted) return;
      final halls = await context.read<HallProvider>().get(
        filter: const HallSearchObject(pageSize: 100, isActive: true),
      );
      if (!mounted) return;
      setState(() {
        _trainings = trainings;
        _trainers = trainers.items;
        _halls = halls.items;
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

  Future<void> _pickDateTime({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
    );
    if (time == null) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String? _validateMaxParticipants(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Max učesnika je obavezno polje.';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      return 'Max učesnika mora biti pozitivan cijeli broj.';
    }
    return null;
  }

  String? _validateStartTime(String? _) {
    if (_startTime == null) return 'Vrijeme početka je obavezno.';
    return null;
  }

  String? _validateEndTime(String? _) {
    if (_endTime == null) return 'Vrijeme kraja je obavezno.';
    if (_startTime != null && !_endTime!.isAfter(_startTime!)) {
      return 'Kraj termina mora biti nakon početka.';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<TrainingTermProvider>();
      final maxParticipants = int.parse(
        _maxParticipantsController.text.trim(),
      );

      if (widget.isEdit) {
        await provider.update(
          widget.term!.id,
          TrainingTermUpdateRequest(
            startTimeUtc: _startTime!.toUtc(),
            endTimeUtc: _endTime!.toUtc(),
            maxParticipants: maxParticipants,
            isActive: _isActive,
            trainerId: _trainerId!,
            hallId: _hallId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Termin treninga "${widget.term!.trainingName}" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          TrainingTermInsertRequest(
            startTimeUtc: _startTime!.toUtc(),
            endTimeUtc: _endTime!.toUtc(),
            maxParticipants: maxParticipants,
            isActive: _isActive,
            trainingId: _trainingId!,
            trainerId: _trainerId!,
            hallId: _hallId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Termin treninga je uspješno dodan.');
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

  Widget _dateTimeField({
    required TextEditingController controller,
    required String hint,
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: !_saving,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
      ),
      onTap: () => _pickDateTime(
        current: current,
        onPicked: (value) {
          setState(() {
            onPicked(value);
            controller.text = _formatLocal(value);
          });
        },
      ),
      validator: validator,
    );
  }

  List<DropdownMenuItem<int>> _trainerItems() {
    final items = [
      for (final trainer in _trainers)
        DropdownMenuItem(
          value: trainer.id,
          child: Text(
            trainer.fullName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final term = widget.term;
    if (term != null && !_trainers.any((t) => t.id == term.trainerId)) {
      items.add(
        DropdownMenuItem(
          value: term.trainerId,
          child: Text(
            '${term.trainerFirstName} ${term.trainerLastName}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> _hallItems() {
    final items = [
      for (final hall in _halls)
        DropdownMenuItem(
          value: hall.id,
          child: Text(
            hall.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final term = widget.term;
    if (term != null && !_halls.any((h) => h.id == term.hallId)) {
      items.add(
        DropdownMenuItem(
          value: term.hallId,
          child: Text(
            term.hallName,
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
      title: widget.isEdit ? 'Izmjena termina' : 'Dodaj novi termin',
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
                  _fieldRow(
                    widget.isEdit
                        ? _labeledField(
                            'Trening',
                            child: TextFormField(
                              enabled: false,
                              initialValue: widget.term!.trainingName,
                            ),
                          )
                        : _labeledField(
                            'Trening',
                            required: true,
                            child: DropdownButtonFormField<int>(
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
                              items: [
                                for (final training in _trainings)
                                  DropdownMenuItem(
                                    value: training.id,
                                    child: Text(
                                      training.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13.5),
                                    ),
                                  ),
                              ],
                              validator: (value) => value == null
                                  ? 'Trening je obavezan.'
                                  : null,
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                        setState(() => _trainingId = value),
                            ),
                          ),
                    _labeledField(
                      'Trener',
                      required: true,
                      child: DropdownButtonFormField<int>(
                        initialValue: _trainerId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        hint: const Text(
                          'Odaberite trenera',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        items: _trainerItems(),
                        validator: (value) =>
                            value == null ? 'Trener je obavezan.' : null,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _trainerId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldRow(
                    _labeledField(
                      'Sala',
                      required: true,
                      child: DropdownButtonFormField<int>(
                        initialValue: _hallId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        hint: const Text(
                          'Odaberite salu',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        items: _hallItems(),
                        validator: (value) =>
                            value == null ? 'Sala je obavezna.' : null,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _hallId = value),
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
                        validator: _validateMaxParticipants,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldRow(
                    _labeledField(
                      'Početak',
                      required: true,
                      child: _dateTimeField(
                        controller: _startTimeController,
                        hint: 'Odaberite datum i vrijeme početka',
                        current: _startTime,
                        onPicked: (value) => _startTime = value,
                        validator: _validateStartTime,
                      ),
                    ),
                    _labeledField(
                      'Kraj',
                      required: true,
                      child: _dateTimeField(
                        controller: _endTimeController,
                        hint: 'Odaberite datum i vrijeme kraja',
                        current: _endTime,
                        onPicked: (value) => _endTime = value,
                        validator: _validateEndTime,
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
                  if (widget.isEdit) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Zakazano: ${formatDateTime(widget.term!.startTimeUtc)} — ${formatDateTime(widget.term!.endTimeUtc)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
