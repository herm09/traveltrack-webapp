import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveltrack/src/models/auth_form_validators.dart';
import 'package:traveltrack/src/viewmodels/auth_viewmodel.dart';
import 'package:traveltrack/src/widgets/auth_form_field.dart';
import 'package:traveltrack/src/widgets/auth_link_row.dart';
import 'package:traveltrack/src/widgets/auth_screen_header.dart';
import 'package:traveltrack/src/widgets/auth_submit_section.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await authViewModel.sendPasswordResetEmail(_emailController.text.trim());
  }

  void _goToLogin() {
    authViewModel.clearMessages();
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goToLogin,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 16),

                const AuthScreenHeader(
                  title: 'Mot de passe oublié',
                  subtitle:
                      'Saisis ton email pour recevoir un lien de réinitialisation',
                ),
                const SizedBox(height: 32),

                AuthFormField(
                  label: 'Email',
                  hintText: 'exemple@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => authViewModel.clearMessages(),
                  validator: AuthFormValidators.validateEmail,
                ),
                const SizedBox(height: 24),

                ListenableBuilder(
                  listenable: authViewModel,
                  builder: (context, _) => AuthSubmitSection(
                    label: 'Envoyer le lien',
                    onSubmit: _submit,
                    isLoading: authViewModel.isLoading,
                    errorMessage: authViewModel.errorMessage,
                    successMessage: authViewModel.successMessage,
                  ),
                ),
                const SizedBox(height: 20),

                AuthLinkRow(
                  message: 'Tu t\'en souviens ?',
                  linkLabel: 'Se connecter',
                  onLinkPressed: _goToLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
