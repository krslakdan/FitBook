import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/trainer_insert_request.dart';
import '../models/requests/trainer_update_request.dart';
import '../models/responses/specialization_response.dart';
import '../models/responses/trainer_response.dart';
import '../models/responses/user_account_response.dart';
import '../models/search_objects/specialization_search_object.dart';
import '../models/search_objects/user_search_object.dart';
import '../providers/file_provider.dart';
import '../providers/specialization_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_roles.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/image_picker_field.dart';

class TrainersDetailsScreen extends StatefulWidget {
  const TrainersDetailsScreen({super.key, this.trainer});

  final TrainerResponse? trainer;

  bool get isEdit => trainer != null;

  @override
  State<TrainersDetailsScreen> createState() => _TrainersDetailsScreenState();
}

class _TrainersDetailsScreenState extends State<TrainersDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _firstNameController = TextEditingController(
    text: widget.trainer?.firstName ?? '',
  );
  late final _lastNameController = TextEditingController(
    text: widget.trainer?.lastName ?? '',
  );
  late final _biographyController = TextEditingController(
    text: widget.trainer?.biography ?? '',
  );

  late int? _specializationId = widget.trainer?.specializationId;
  int? _userAccountId;
  late bool _isAvailable = widget.trainer?.isAvailable ?? true;
  late bool _isActive = widget.trainer?.isActive ?? true;

  List<SpecializationResponse> _specializations = const [];
  List<UserAccountResponse> _trainerAccounts = const [];
  bool _lookupsLoading = true;

  bool _saving = false;
  String? _serverError;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final specializations = await context.read<SpecializationProvider>().get(
        filter: const SpecializationSearchObject(pageSize: 100),
      );
      if (!mounted) return;

      List<UserAccountResponse> trainerAccounts = const [];
      if (!widget.isEdit) {
        final users = await context.read<UserAccountProvider>().get(
          filter: const UserSearchObject(
            pageSize: 100,
            role: AppRoles.trainer,
            isActive: true,
          ),
        );
        trainerAccounts = users.items;
      }

      if (!mounted) return;
      setState(() {
        _specializations = specializations.items;
        _trainerAccounts = trainerAccounts;
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

  String? _requiredLength(
    String? value,
    String field, {
    int min = 2,
    int max = 100,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field je obavezno polje.';
    if (text.length < min) return '$field mora imati najmanje $min karaktera.';
    if (text.length > max)
      return '$field ne smije biti duže od $max karaktera.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      String? imageUrl = widget.trainer?.imageUrl;
      if (_pickedImageBytes != null) {
        imageUrl = await context.read<FileProvider>().uploadImage(
          bytes: _pickedImageBytes!,
          fileName: _pickedImageName!,
          folder: 'trainers',
        );
      }

      if (!mounted) return;
      final provider = context.read<TrainerProvider>();
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final biography = _biographyController.text.trim();

      if (widget.isEdit) {
        await provider.update(
          widget.trainer!.id,
          TrainerUpdateRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            specializationId: _specializationId!,
            biography: biography.isEmpty ? null : biography,
            imageUrl: imageUrl,
            isAvailable: _isAvailable,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Trener "$fullName" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          TrainerInsertRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            specializationId: _specializationId!,
            biography: biography.isEmpty ? null : biography,
            imageUrl: imageUrl,
            isAvailable: _isAvailable,
            isActive: _isActive,
            userAccountId: _userAccountId!,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Trener "$fullName" je uspješno dodan.');
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

  Widget _switchField(
    String label,
    bool value,
    String onLabel,
    String offLabel,
    ValueChanged<bool> onChanged,
  ) {
    return _labeledField(
      label,
      required: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SwitchListTile(
          value: value,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          title: Text(
            value ? onLabel : offLabel,
            style: const TextStyle(fontSize: 13.5),
          ),
          activeTrackColor: AppColors.primary,
          onChanged: _saving ? null : onChanged,
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _specializationItems() {
    final items = [
      for (final specialization in _specializations)
        DropdownMenuItem(
          value: specialization.id,
          child: Text(
            specialization.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
    ];
    final trainer = widget.trainer;
    if (trainer != null &&
        !_specializations.any((s) => s.id == trainer.specializationId)) {
      items.add(
        DropdownMenuItem(
          value: trainer.specializationId,
          child: Text(
            trainer.specializationName,
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
      title: widget.isEdit ? 'Izmjena trenera' : 'Dodaj novog trenera',
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: ImagePickerField(
                      label: 'Slika trenera',
                      enabled: !_saving,
                      pickedBytes: _pickedImageBytes,
                      existingImageUrl: widget.trainer?.imageUrl,
                      errorText: _imageError,
                      onPicked: (bytes, name) {
                        setState(() {
                          if (bytes.length > FileProvider.maxFileSizeBytes) {
                            _imageError =
                                'Slika je prevelika. Maksimalna veličina je 5 MB.';
                            return;
                          }
                          _imageError = null;
                          _pickedImageBytes = bytes;
                          _pickedImageName = name;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldRow(
                          _labeledField(
                            'Ime',
                            required: true,
                            child: TextFormField(
                              controller: _firstNameController,
                              enabled: !_saving,
                              decoration: const InputDecoration(
                                hintText: 'Unesite ime',
                              ),
                              validator: (v) => _requiredLength(v, 'Ime'),
                            ),
                          ),
                          _labeledField(
                            'Prezime',
                            required: true,
                            child: TextFormField(
                              controller: _lastNameController,
                              enabled: !_saving,
                              decoration: const InputDecoration(
                                hintText: 'Unesite prezime',
                              ),
                              validator: (v) => _requiredLength(v, 'Prezime'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _fieldRow(
                          _labeledField(
                            'Specijalizacija',
                            required: true,
                            child: DropdownButtonFormField<int>(
                              initialValue: _specializationId,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(10),
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                              hint: const Text(
                                'Odaberite specijalizaciju',
                                style: TextStyle(fontSize: 13.5),
                              ),
                              items: _specializationItems(),
                              validator: (value) => value == null
                                  ? 'Specijalizacija je obavezna.'
                                  : null,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(
                                      () => _specializationId = value,
                                    ),
                            ),
                          ),
                          widget.isEdit
                              ? _labeledField(
                                  'Korisnički nalog',
                                  child: TextFormField(
                                    enabled: false,
                                    initialValue:
                                        widget.trainer!.fullName,
                                  ),
                                )
                              : _labeledField(
                                  'Korisnički nalog',
                                  required: true,
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _userAccountId,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(10),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                    ),
                                    hint: const Text(
                                      'Odaberite korisnički nalog',
                                      style: TextStyle(fontSize: 13.5),
                                    ),
                                    items: [
                                      for (final user in _trainerAccounts)
                                        DropdownMenuItem(
                                          value: user.id,
                                          child: Text(
                                            '${user.firstName} ${user.lastName} (${user.username})',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                    validator: (value) => value == null
                                        ? 'Korisnički nalog je obavezan.'
                                        : null,
                                    onChanged: _saving
                                        ? null
                                        : (value) => setState(
                                            () => _userAccountId = value,
                                          ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 14),
                        const FormFieldLabel('Biografija'),
                        TextFormField(
                          controller: _biographyController,
                          enabled: !_saving,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Unesite biografiju trenera (opcionalno)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        _fieldRow(
                          _switchField(
                            'Dostupnost',
                            _isAvailable,
                            'Dostupan',
                            'Nedostupan',
                            (value) => setState(() => _isAvailable = value),
                          ),
                          _switchField(
                            'Status',
                            _isActive,
                            'Aktivan',
                            'Neaktivan',
                            (value) => setState(() => _isActive = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
