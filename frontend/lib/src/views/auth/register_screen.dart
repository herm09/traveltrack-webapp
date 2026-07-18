import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) return;
    if (!_formKey.currentState!.validate()) return;

    // Pas de navigation manuelle ici : GoRouter réagit automatiquement au
    // changement de session via `refreshListenable` + `redirect` (voir
    // app_router.dart) et nous enverra sur /map dès que l'inscription réussit.
    await authViewModel.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: ListenableBuilder(
              listenable: authViewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/auth/login'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rejoins-nous et commence l\'aventure',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // First Name Field
                    Text(
                      'Prénom',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'Jean',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Prénom requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field
                    Text(
                      'Nom',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Dupont',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'exemple@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Email requis' : null,
                    ),
                    if (authViewModel.emailErrorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        authViewModel.emailErrorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Password Field
                    Text(
                      'Mot de passe',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Mot de passe requis';
                        if (value.length < 6) return 'Au moins 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    Text(
                      'Confirmer le mot de passe',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirmation requise';
                        if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Terms & Conditions Checkbox
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      title: RichText(
                        text: TextSpan(
                          text: 'J\'accepte les ',
                          style: TextStyle(color: Colors.grey[700]),
                          children: [
                            TextSpan(
                              text: 'conditions d\'utilisation',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (authViewModel.errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        authViewModel.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: (_acceptedTerms && !authViewModel.isLoading) ? _submit : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authViewModel.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Créer un compte'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Tu as déjà un compte ? ',
                            style: TextStyle(color: Colors.grey[700]),
                            children: [
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
