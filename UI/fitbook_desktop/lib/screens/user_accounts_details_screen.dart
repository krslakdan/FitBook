import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/user_account_admin_password_reset_request.dart';
import '../models/requests/user_account_insert_request.dart';
import '../models/requests/user_account_update_request.dart';
import '../models/responses/user_account_response.dart';
import '../providers/file_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_roles.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/image_picker_field.dart';

class UserAccountsDetailsScreen extends StatefulWidget {
  const UserAccountsDetailsScreen({super.key, this.user});

  final UserAccountResponse? user;

  bool get isEdit => user != null;

  @override
  State<UserAccountsDetailsScreen> createState() =>
      _UserAccountsDetailsScreenState();
}

class _UserAccountsDetailsScreenState extends State<UserAccountsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _firstNameController = TextEditingController(
    text: widget.user?.firstName ?? '',
  );
  late final _lastNameController = TextEditingController(
    text: widget.user?.lastName ?? '',
  );
  late final _emailController = TextEditingController(
    text: widget.user?.email ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.user?.phoneNumber ?? '',
  );
  late final _usernameController = TextEditingController(
    text: widget.user?.username ?? '',
  );
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  late String? _role = widget.user?.role;
  late bool _isActive = widget.user?.isActive ?? true;

  bool _changePassword = false;
  bool _obscurePassword = true;
  bool _saving = false;
  String? _serverError;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _imageError;

  static final _phonePattern = RegExp(
    r'^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$',
  );
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
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

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email adresa je obavezna.';
    if (!_emailPattern.hasMatch(text)) {
      return 'Email adresa nije u ispravnom formatu (npr. ime@domena.com).';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Broj telefona je obavezan.';
    if (!_phonePattern.hasMatch(text)) {
      return 'Broj telefona nije u ispravnom formatu (npr. +387 61 123 456).';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (widget.isEdit && !_changePassword) return null;
    final text = value ?? '';
    if (text.isEmpty) return 'Lozinka je obavezna.';
    if (text.length < 8) return 'Lozinka mora imati najmanje 8 karaktera.';
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (!_changePassword) return null;
    if ((value ?? '') != _passwordController.text)
      return 'Lozinke se ne podudaraju.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate() || _role == null) {
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _saving = true);

    try {
      String? imageUrl = widget.user?.profileImageUrl;
      if (_pickedImageBytes != null) {
        imageUrl = await context.read<FileProvider>().uploadImage(
          bytes: _pickedImageBytes!,
          fileName: _pickedImageName!,
          folder: 'users',
        );
      }

      if (!mounted) return;
      final provider = context.read<UserAccountProvider>();
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      if (widget.isEdit) {
        await provider.update(
          widget.user!.id,
          UserAccountUpdateRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            username: _usernameController.text.trim(),
            role: _role,
            profileImageUrl: imageUrl,
            isActive: _isActive,
          ),
        );

        if (_changePassword) {
          await provider.adminResetPassword(
            widget.user!.id,
            UserAccountAdminPasswordResetRequest(
              newPassword: _passwordController.text,
            ),
          );
        }

        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Korisnik "$fullName" je uspješno izmijenjen.');
      } else {
        await provider.insert(
          UserAccountInsertRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            role: _role!,
            profileImageUrl: imageUrl,
            isActive: _isActive,
          ),
        );

        if (!mounted) return;
        Navigator.of(context).pop('Korisnik "$fullName" je uspješno dodan.');
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
      title: widget.isEdit ? 'Izmjena korisnika' : 'Dodaj novog korisnika',
      saving: _saving,
      serverError: _serverError,
      onSave: _save,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: ImagePickerField(
                label: 'Profilna slika',
                enabled: !_saving,
                pickedBytes: _pickedImageBytes,
                existingImageUrl: widget.user?.profileImageUrl,
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
                      'Email',
                      required: true,
                      child: TextFormField(
                        controller: _emailController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          hintText: 'Unesite email adresu',
                        ),
                        validator: _validateEmail,
                      ),
                    ),
                    _labeledField(
                      'Telefon',
                      required: true,
                      child: TextFormField(
                        controller: _phoneController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          hintText: 'Unesite broj telefona',
                        ),
                        validator: _validatePhone,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _fieldRow(
                    _labeledField(
                      'Korisničko ime',
                      required: true,
                      child: TextFormField(
                        controller: _usernameController,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          hintText: 'Unesite korisničko ime',
                        ),
                        validator: (v) =>
                            _requiredLength(v, 'Korisničko ime', min: 3),
                      ),
                    ),
                    _labeledField(
                      'Uloga',
                      required: true,
                      child: DropdownButtonFormField<String>(
                        initialValue: _role,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        hint: const Text(
                          'Odaberite ulogu',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        items: [
                          for (final role in AppRoles.all)
                            DropdownMenuItem(
                              value: role,
                              child: Text(AppRoles.displayName(role)),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? 'Uloga je obavezna.' : null,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _role = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!widget.isEdit)
                    _fieldRow(
                      _labeledField(
                        'Lozinka',
                        required: true,
                        child: _passwordField(
                          _passwordController,
                          'Unesite lozinku',
                          _validatePassword,
                        ),
                      ),
                      _statusSwitch(),
                    )
                  else ...[
                    _fieldRow(
                      _labeledField(
                        'Lozinka',
                        child: CheckboxListTile(
                          value: _changePassword,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          title: const Text(
                            'Izmijeni lozinku',
                            style: TextStyle(fontSize: 13.5),
                          ),
                          onChanged: _saving
                              ? null
                              : (value) => setState(() {
                                  _changePassword = value ?? false;
                                  if (!_changePassword) {
                                    _passwordController.clear();
                                    _passwordConfirmController.clear();
                                  }
                                }),
                        ),
                      ),
                      _statusSwitch(),
                    ),
                    if (_changePassword) ...[
                      const SizedBox(height: 14),
                      _fieldRow(
                        _labeledField(
                          'Nova lozinka',
                          required: true,
                          child: _passwordField(
                            _passwordController,
                            'Unesite novu lozinku',
                            _validatePassword,
                          ),
                        ),
                        _labeledField(
                          'Potvrda nove lozinke',
                          required: true,
                          child: TextFormField(
                            controller: _passwordConfirmController,
                            enabled: !_saving,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Ponovite novu lozinku',
                            ),
                            validator: _validatePasswordConfirm,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String hint,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: validator,
    );
  }

  Widget _statusSwitch() {
    return _labeledField(
      'Status',
      required: true,
      child: Container(
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
    );
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
}
