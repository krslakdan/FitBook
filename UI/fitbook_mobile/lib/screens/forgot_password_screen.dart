import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/requests/auth/forgot_password_request.dart';
import '../models/requests/auth/reset_password_request.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailPattern = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _serverError;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'E-mail adresa je obavezna.';
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Unesite validnu e-mail adresu u formatu: ime@domena.com.';
    }
    return null;
  }

  String? _validateCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Kod za reset lozinke je obavezan.';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(trimmed)) {
      return 'Kod za reset lozinke mora sadržavati tačno 6 cifara.';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Nova lozinka je obavezna.';
    if (text.length < 8) return 'Nova lozinka mora imati najmanje 8 karaktera.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Potvrda lozinke je obavezna.';
    if (value != _newPasswordController.text) return 'Lozinke se ne podudaraju.';
    return null;
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _serverError = null;
      _infoMessage = null;
    });

    if (_validateEmail(_emailController.text) != null) {
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().forgotPassword(
        ForgotPasswordRequest(email: _emailController.text.trim()),
      );

      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _infoMessage =
            'Ako nalog sa unesenom e-mail adresom postoji, poslali smo Vam 6-cifreni kod. Provjerite e-mail (uključujući spam).';
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().resetPassword(
        ResetPasswordRequest(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _changeEmail() {
    setState(() {
      _codeSent = false;
      _serverError = null;
      _infoMessage = null;
      _codeController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset lozinke',
      subtitle: _codeSent
          ? 'Unesite kod i postavite novu lozinku'
          : 'Unesite e-mail za dobivanje koda',
      onBack: _isSubmitting ? null : () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthCard(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_infoMessage != null) ...[
                    FormBanner(message: _infoMessage!, tone: BannerTone.success),
                    const SizedBox(height: 18),
                  ],
                  if (_serverError != null) ...[
                    FormBanner(message: _serverError!),
                    const SizedBox(height: 18),
                  ],
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmitting,
                    readOnly: _codeSent,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    inputFormatters: [LengthLimitingTextInputFormatter(256)],
                    decoration: const InputDecoration(
                      labelText: 'E-mail adresa',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _codeSent ? null : _sendCode(),
                  ),
                  if (!_codeSent) ...[
                    const SizedBox(height: 26),
                    _primaryButton(label: 'Pošalji kod', onPressed: _sendCode),
                  ],
                  if (_codeSent) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Kod za reset (6 cifara)',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: _validateCode,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      enabled: !_isSubmitting,
                      obscureText: _obscureNewPassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      inputFormatters: [LengthLimitingTextInputFormatter(128)],
                      decoration: InputDecoration(
                        labelText: 'Nova lozinka',
                        helperText: 'Najmanje 8 karaktera.',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: _visibilityToggle(
                          obscured: _obscureNewPassword,
                          onTap: () =>
                              setState(() => _obscureNewPassword = !_obscureNewPassword),
                        ),
                      ),
                      validator: _validateNewPassword,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_isSubmitting,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      inputFormatters: [LengthLimitingTextInputFormatter(128)],
                      decoration: InputDecoration(
                        labelText: 'Potvrdi novu lozinku',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: _visibilityToggle(
                          obscured: _obscureConfirmPassword,
                          onTap: () =>
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _resetPassword(),
                    ),
                    const SizedBox(height: 26),
                    _primaryButton(label: 'Resetuj lozinku', onPressed: _resetPassword),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting ? null : _changeEmail,
                          style: _linkStyle(),
                          child: const Text('Promijeni e-mail'),
                        ),
                        TextButton(
                          onPressed: _isSubmitting ? null : _sendCode,
                          style: _linkStyle(),
                          child: const Text('Pošalji ponovo'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sjetili ste se lozinke?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                style: _linkStyle(),
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

  Widget _primaryButton({required String label, required VoidCallback onPressed}) {
    return FilledButton(
      onPressed: _isSubmitting ? null : onPressed,
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
          : Text(label),
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

  ButtonStyle _linkStyle() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
