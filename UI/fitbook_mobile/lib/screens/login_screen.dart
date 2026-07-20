import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/auth/user_login_request.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/auth_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _serverError;
  String? _successMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Korisničko ime je obavezno.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lozinka je obavezna.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _serverError = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().login(
        UserLoginRequest(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openRegister() async {
    final registeredUsername = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    if (!mounted || registeredUsername == null) return;

    setState(() {
      _usernameController.text = registeredUsername;
      _passwordController.clear();
      _serverError = null;
      _successMessage = 'Nalog je uspješno kreiran. Prijavite se da nastavite.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Dobrodošli nazad',
      subtitle: 'Prijavite se na svoj FitBook nalog',
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
                    if (_successMessage != null) ...[
                      FormBanner(message: _successMessage!, tone: BannerTone.success),
                      const SizedBox(height: 18),
                    ],
                    if (_serverError != null) ...[
                      FormBanner(message: _serverError!),
                      const SizedBox(height: 18),
                    ],
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isSubmitting,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Korisničko ime',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateUsername,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isSubmitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Lozinka',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
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
                          : const Text('Prijavi se'),
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
                'Nemate nalog?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : _openRegister,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Registrujte se',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
