import 'package:flutter/material.dart';
import 'package:traveltrack/src/models/auth_form_validators.dart';
import 'package:traveltrack/src/viewmodels/auth_viewmodel.dart';
import 'package:traveltrack/src/widgets/auth_form_field.dart';
import 'package:traveltrack/src/widgets/auth_screen_header.dart';
import 'package:traveltrack/src/widgets/auth_submit_section.dart';

/// Affiché par le routeur au retour du lien de réinitialisation reçu par email.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Le routeur quitte cet écran dès que le mot de passe est enregistré.
    await authViewModel.updatePassword(_newPasswordController.text);
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
                const AuthScreenHeader(
                  title: 'Nouveau mot de passe',
                  subtitle: 'Choisis le mot de passe de ton compte',
                ),
                const SizedBox(height: 32),

                AuthFormField(
                  label: 'Nouveau mot de passe',
                  hintText: '••••••••',
                  controller: _newPasswordController,
                  isPassword: true,
                  onChanged: (_) => authViewModel.clearMessages(),
                  validator: AuthFormValidators.validateNewPassword,
                ),
                const SizedBox(height: 16),

                AuthFormField(
                  label: 'Confirmer le mot de passe',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  onChanged: (_) => authViewModel.clearMessages(),
                  validator: (enteredConfirmation) =>
                      AuthFormValidators.validatePasswordConfirmation(
                        enteredConfirmation,
                        _newPasswordController.text,
                      ),
                ),
                const SizedBox(height: 24),

                ListenableBuilder(
                  listenable: authViewModel,
                  builder: (context, _) => AuthSubmitSection(
                    label: 'Enregistrer',
                    onSubmit: _submit,
                    isLoading: authViewModel.isLoading,
                    errorMessage: authViewModel.errorMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
