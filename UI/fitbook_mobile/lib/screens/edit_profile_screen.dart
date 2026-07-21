import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/requests/user_account_update_request.dart';
import '../models/responses/user_account_response.dart';
import '../providers/file_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/profile_avatar_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserAccountResponse user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static final RegExp _emailPattern = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _phonePattern = RegExp(r'^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$');

  final _formKey = GlobalKey<FormState>();
  late final _firstNameController = TextEditingController(text: widget.user.firstName);
  late final _lastNameController = TextEditingController(text: widget.user.lastName);
  late final _emailController = TextEditingController(text: widget.user.email);
  late final _phoneController = TextEditingController(text: widget.user.phoneNumber);

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    String pick(String value) => value.trim().isEmpty ? '' : value.trim()[0].toUpperCase();
    final initials = '${pick(_firstNameController.text)}${pick(_lastNameController.text)}';
    if (initials.isNotEmpty) return initials;
    return pick(widget.user.username).isEmpty ? '?' : pick(widget.user.username);
  }

  String? _validateFirstName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ime je obavezno.';
    if (trimmed.length < 2) return 'Ime mora imati najmanje 2 karaktera.';
    return null;
  }

  String? _validateLastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Prezime je obavezno.';
    if (trimmed.length < 2) return 'Prezime mora imati najmanje 2 karaktera.';
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email adresa je obavezna.';
    if (!_emailPattern.hasMatch(trimmed)) return 'Email adresa nije u ispravnom formatu.';
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Broj telefona je obavezan.';
    if (!_phonePattern.hasMatch(trimmed)) return 'Broj telefona nije u ispravnom formatu.';
    return null;
  }

  void _onImagePicked(Uint8List bytes, String fileName) {
    if (bytes.length > FileProvider.maxFileSizeBytes) {
      setState(() => _serverError = 'Slika je prevelika. Maksimalna veličina je 5 MB.');
      return;
    }
    setState(() {
      _serverError = null;
      _pickedImageBytes = bytes;
      _pickedImageName = fileName;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      String? imageUrl;
      if (_pickedImageBytes != null) {
        imageUrl = await context.read<FileProvider>().uploadImage(
          bytes: _pickedImageBytes!,
          fileName: _pickedImageName!,
          folder: 'users',
        );
      }

      if (!mounted) return;
      await context.read<UserAccountProvider>().update(
        widget.user.id,
        UserAccountUpdateRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          profileImageUrl: imageUrl,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop('Profil je uspješno ažuriran.');
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Uredi profil',
      subtitle: 'Ažurirajte svoje lične podatke',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_serverError != null) ...[
                FormBanner(message: _serverError!),
                const SizedBox(height: 18),
              ],
              ProfileAvatarPicker(
                initials: _initials,
                enabled: !_saving,
                pickedBytes: _pickedImageBytes,
                existingImageUrl: widget.user.profileImageUrl,
                onPicked: _onImagePicked,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dodirnite ikonicu za promjenu slike',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _field(
                controller: _firstNameController,
                label: 'Ime',
                icon: Icons.person_outline,
                validator: _validateFirstName,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _lastNameController,
                label: 'Prezime',
                icon: Icons.person_outline,
                validator: _validateLastName,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _emailController,
                label: 'Email adresa',
                icon: Icons.mail_outline,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _phoneController,
                label: 'Broj telefona',
                icon: Icons.phone_outlined,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                maxLength: 30,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.username,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Korisničko ime',
                  prefixIcon: Icon(Icons.badge_outlined),
                  helperText: 'Korisničko ime se ne može mijenjati.',
                ),
              ),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Sačuvaj izmjene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    IconData? icon,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: TextInputAction.next,
      inputFormatters: maxLength == null ? null : [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      validator: validator,
    );
  }
}
