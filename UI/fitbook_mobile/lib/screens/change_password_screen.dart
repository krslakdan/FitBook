import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/requests/auth/user_login_request.dart';
import '../models/requests/user_account_change_own_password_request.dart';
import '../providers/auth_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/auth_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _serverError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateCurrent(String? value) {
    if (value == null || value.isEmpty) return 'Trenutna lozinka je obavezna.';
    return null;
  }

  String? _validateNew(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Nova lozinka je obavezna.';
    if (text.length < 8) return 'Nova lozinka mora imati najmanje 8 karaktera.';
    if (text == _currentController.text) {
      return 'Nova lozinka mora biti različita od trenutne.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Potvrda lozinke je obavezna.';
    if (value != _newController.text) return 'Lozinke se ne podudaraju.';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final auth = context.read<AuthProvider>();
    final username = auth.currentUsername;
    final newPassword = _newController.text;

    try {
      await context.read<UserAccountProvider>().changeOwnPassword(
        UserAccountChangeOwnPasswordRequest(
          currentPassword: _currentController.text,
          newPassword: newPassword,
        ),
      );
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverError = e.message;
        _saving = false;
      });
      return;
    }

    if (username != null) {
      await _reauthenticate(auth, username, newPassword);
    }

    if (!mounted) return;
    Navigator.of(context).pop('Lozinka je uspješno promijenjena.');
  }

  Future<void> _reauthenticate(AuthProvider auth, String username, String password) async {
    try {
      await auth.login(UserLoginRequest(username: username, password: password));
    } on ApiClientException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Promijeni lozinku',
      subtitle: 'Potvrdite trenutnu i unesite novu lozinku',
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
              _passwordField(
                controller: _currentController,
                label: 'Trenutna lozinka',
                obscure: _obscureCurrent,
                validator: _validateCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: _newController,
                label: 'Nova lozinka',
                obscure: _obscureNew,
                validator: _validateNew,
                helperText: 'Najmanje 8 karaktera.',
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: _confirmController,
                label: 'Potvrdi novu lozinku',
                obscure: _obscureConfirm,
                validator: _validateConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
                    : const Text('Sačuvaj lozinku'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required String? Function(String?) validator,
    required VoidCallback onToggle,
    String? helperText,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      obscureText: obscure,
      textInputAction: textInputAction,
      inputFormatters: [LengthLimitingTextInputFormatter(128)],
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
    );
  }
}
