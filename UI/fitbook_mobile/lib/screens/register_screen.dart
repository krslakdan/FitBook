import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/requests/auth/user_register_request.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final RegExp _emailPattern = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _phonePattern = RegExp(r'^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$');

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _serverError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Korisničko ime je obavezno.';
    if (trimmed.length < 3) return 'Korisničko ime mora imati najmanje 3 karaktera.';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Lozinka je obavezna.';
    if (text.length < 8) return 'Lozinka mora imati najmanje 8 karaktera.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Potvrda lozinke je obavezna.';
    if (value != _passwordController.text) return 'Lozinke se ne podudaraju.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final username = _usernameController.text.trim();
      await context.read<AuthProvider>().register(
        UserRegisterRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          username: username,
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(username);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Kreirajte nalog',
      subtitle: 'Pridružite se FitBook zajednici',
      onBack: _isSubmitting ? null : () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthCard(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_serverError != null) ...[
                      FormBanner(message: _serverError!),
                      const SizedBox(height: 18),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _firstNameController,
                            label: 'Ime',
                            validator: _validateFirstName,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.givenName],
                            maxLength: 100,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _lastNameController,
                            label: 'Prezime',
                            validator: _validateLastName,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.familyName],
                            maxLength: 100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: 'Email adresa',
                      icon: Icons.mail_outline,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      maxLength: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _phoneController,
                      label: 'Broj telefona',
                      icon: Icons.phone_outlined,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      maxLength: 30,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _usernameController,
                      label: 'Korisničko ime',
                      icon: Icons.person_outline,
                      validator: _validateUsername,
                      autofillHints: const [AutofillHints.newUsername],
                      maxLength: 100,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passwordController,
                      label: 'Lozinka',
                      icon: Icons.lock_outline,
                      validator: _validatePassword,
                      obscure: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      maxLength: 128,
                      helperText: 'Najmanje 8 karaktera.',
                      suffix: _visibilityToggle(
                        obscured: _obscurePassword,
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Potvrdi lozinku',
                      icon: Icons.lock_outline,
                      validator: _validateConfirmPassword,
                      obscure: _obscureConfirmPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      maxLength: 128,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      suffix: _visibilityToggle(
                        obscured: _obscureConfirmPassword,
                        onTap: () =>
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Kreiraj nalog'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Već imate nalog?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Prijavite se',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
    String? helperText,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    Iterable<String>? autofillHints,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: maxLength == null
          ? null
          : [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted ?? (_) => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _visibilityToggle({required bool obscured, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
      ),
      onPressed: onTap,
    );
  }
}
