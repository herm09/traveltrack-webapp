import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveltrack/src/models/auth_form_validators.dart';
import 'package:traveltrack/src/viewmodels/auth_viewmodel.dart';
import 'package:traveltrack/src/widgets/auth_form_field.dart';
import 'package:traveltrack/src/widgets/auth_link_row.dart';
import 'package:traveltrack/src/widgets/auth_screen_header.dart';
import 'package:traveltrack/src/widgets/auth_submit_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Pas de navigation manuelle ici : GoRouter réagit automatiquement au
    // changement de session via `refreshListenable` + `redirect` (voir
    // app_router.dart) et nous enverra sur /map dès que la connexion réussit.
    await authViewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _navigateTo(String location) {
    authViewModel.clearMessages();
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthScreenHeader(
                  title: 'Bienvenue sur\nTravelTrack',
                  subtitle: 'Connecte-toi pour explorer le monde',
                ),
                const SizedBox(height: 40),

                AuthFormField(
                  label: 'Email',
                  hintText: 'exemple@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => authViewModel.clearMessages(),
                  validator: AuthFormValidators.validateEmail,
                ),
                const SizedBox(height: 20),

                AuthFormField(
                  label: 'Mot de passe',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  onChanged: (_) => authViewModel.clearMessages(),
                  validator: AuthFormValidators.validateExistingPassword,
                ),
                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _navigateTo('/auth/forgot-password'),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 24),

                ListenableBuilder(
                  listenable: authViewModel,
                  builder: (context, _) {
                    final isLoading = authViewModel.isLoading;
                    return Column(
                      children: [
                        AuthSubmitSection(
                          label: 'Se connecter',
                          onSubmit: _submit,
                          isLoading: isLoading,
                          errorMessage: authViewModel.errorMessage,
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: colorScheme.outlineVariant),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: colorScheme.outlineVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Login Buttons
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : authViewModel.signInWithGoogle,
                            icon: const Text('G'),
                            label: const Text('Continuer avec Google'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : authViewModel.signInWithFacebook,
                            icon: const Text('f'),
                            label: const Text('Continuer avec Facebook'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                AuthLinkRow(
                  message: 'Tu n\'as pas de compte ?',
                  linkLabel: 'Créer un compte',
                  onLinkPressed: () => _navigateTo('/auth/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
