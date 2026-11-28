import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  bool _isSubmitting = false;
  bool _showPassword = false;

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthState>().login(_username, _password);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Login gagal. ${describeError(error)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(title: const Text('Login')),
      body: PageBody(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.s6),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: AppSpace.s16,
                      height: AppSpace.s16,
                      decoration: BoxDecoration(
                        gradient: t.heroGradient,
                        borderRadius: AppRadius.lgAll,
                      ),
                      child: Icon(
                        Icons.lock_open_rounded,
                        color: t.onBrand,
                        size: AppSpace.s8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s5),
                  Text('Masuk dulu, yuk', style: text.headlineMedium),
                  const SizedBox(height: AppSpace.s1),
                  Text(
                    'Gunakan akun Django-mu untuk mengubah portofolio.',
                    style: text.bodyMedium?.copyWith(color: t.textMuted),
                  ),
                  const SizedBox(height: AppSpace.s6),
                  TextFormField(
                    autofillHints: const [AutofillHints.username],
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    onChanged: (value) => _username = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Username cannot be empty!'
                        : null,
                  ),
                  const SizedBox(height: AppSpace.s4),
                  TextFormField(
                    autofillHints: const [AutofillHints.password],
                    obscureText: !_showPassword,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        tooltip: _showPassword
                            ? 'Sembunyikan password'
                            : 'Tampilkan password',
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    onChanged: (value) => _password = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password cannot be empty!'
                        : null,
                  ),
                  const SizedBox(height: AppSpace.s6),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox.square(
                            dimension: AppSpace.s5,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
